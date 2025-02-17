/**
 * Copyright (C) 2020 Xilinx, Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may
 * not use this file except in compliance with the License. A copy of the
 * License is located at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

#ifndef EDGE_DEVICE_LINUX_H
#define EDGE_DEVICE_LINUX_H

#include "xrt.h"
#include "core/common/ishim.h"
#include "core/edge/common/device_edge.h"

namespace xrt_core {

// concrete class derives from device_edge, but mixes in
// shim layer functions for access through base class
class device_linux : public shim<device_edge>
{
public:
  device_linux(handle_type device_handle, id_type device_id, bool user);

  // query functions
  virtual void read_dma_stats(boost::property_tree::ptree& pt) const;

  virtual void read(uint64_t addr, void* buf, uint64_t len) const;
  virtual void write(uint64_t addr, const void* buf, uint64_t len) const;
  virtual void reset(const query::reset_type) const;

  ////////////////////////////////////////////////////////////////
  // Custom ishim implementation
  // Redefined from xrt_core::ishim for functions that are not
  // universally implemented by all shims
  ////////////////////////////////////////////////////////////////
  void
  set_cu_read_range(cuidx_type ip_index, uint32_t start, uint32_t size) override;

  ////////////////////////////////////////////////////////////////
  // Custom ip interrupt handling
  // Redefined from xrt_core::ishim
  ////////////////////////////////////////////////////////////////
  virtual xclInterruptNotifyHandle
  open_ip_interrupt_notify(unsigned int ip_index)
  {
    return xclOpenIPInterruptNotify(get_device_handle(), ip_index, 0);
  }
  
  virtual void
  close_ip_interrupt_notify(xclInterruptNotifyHandle handle)
  {
    xclCloseIPInterruptNotify(get_device_handle(), handle);
  }

  virtual void
  enable_ip_interrupt(xclInterruptNotifyHandle);

  virtual void
  disable_ip_interrupt(xclInterruptNotifyHandle);

  virtual void
  wait_ip_interrupt(xclInterruptNotifyHandle);
  ////////////////////////////////////////////////////////////////

private:
  // Private look up function for concrete query::request
  virtual const query::request&
  lookup_query(query::key_type query_key) const;
};

}

#endif /* EDGE_DEVICE_LINUX_H */
