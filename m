Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:65270 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752327AbdGDMxq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 08:53:46 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, peterz@infradead.org,
        keescook@chromium.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-nfs@vger.kernel.org, zyan@redhat.com,
        sage@redhat.com, bfields@fieldses.org, jlayton@poochiereds.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        santosh.shilimkar@oracle.com, jreuter@yaina.de,
        Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/36] v2 net subsystem misc refcounter conversions
Date: Tue,  4 Jul 2017 15:52:55 +0300
Message-Id: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes in v2:
 * rebase on top of net-next
 * currently by default refcount_t = atomic_t (*) and uses all 
   atomic standard operations unless CONFIG_REFCOUNT_FULL is enabled.
   This is a compromise for the systems that are critical on
   performance (such as net) and cannot accept even slight delay
   on the refcounter operations.

This series, for various misc network components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.
These are the last networking-related conversions with the exception of
network drivers (to be send separately).

Please excuse the long patch set, but seems like breaking it up
won't save that much on CC list and most of the changes are
trivial.

The patches are fully independent and can be cherry-picked separately.
In order to try with refcount functionality enabled in run-time,
CONFIG_REFCOUNT_FULL must be enabled.

NOTE: automatic kernel builder for some reason doesn't like all my
network branches and regularly times out the builds on these branches.
Suggestion for "waiting a day for a good coverage" doesn't work, as
we have seen with generic network conversions. So please wait for the
full report from kernel test rebot before merging further up.
This has been compile-tested in 116 configs, but 71 timed out (including
all s390-related configs again). I am trying to see if they can fix
build coverage for me in meanwhile.

* The respective change is currently merged into -next as
  "locking/refcount: Create unchecked atomic_t implementation".

Elena Reshetova (36):
  net, llc: convert llc_sap.refcnt from atomic_t to refcount_t
  net, l2tp: convert l2tp_tunnel.ref_count from atomic_t to refcount_t
  net, l2tp: convert l2tp_session.ref_count from atomic_t to refcount_t
  net, vxlan: convert vxlan_sock.refcnt from atomic_t to refcount_t
  net, decnet: convert dn_fib_info.fib_clntref from atomic_t to
    refcount_t
  net, atm: convert atm_dev.refcnt from atomic_t to refcount_t
  net, atm: convert lec_arp_table.usage from atomic_t to refcount_t
  net, atm: convert in_cache_entry.use from atomic_t to refcount_t
  net, atm: convert eg_cache_entry.use from atomic_t to refcount_t
  net, bridge: convert net_bridge_vlan.refcnt from atomic_t to
    refcount_t
  net, calipso: convert calipso_doi.refcount from atomic_t to refcount_t
  net, sched: convert Qdisc.refcnt from atomic_t to refcount_t
  net, lapb: convert lapb_cb.refcnt from atomic_t to refcount_t
  net, ipx: convert ipx_interface.refcnt from atomic_t to refcount_t
  net, ipx: convert ipx_route.refcnt from atomic_t to refcount_t
  net, netrom: convert nr_neigh.refcount from atomic_t to refcount_t
  net, netrom: convert nr_node.refcount from atomic_t to refcount_t
  net, sunrpc: convert gss_cl_ctx.count from atomic_t to refcount_t
  net, sunrpc: convert gss_upcall_msg.count from atomic_t to refcount_t
  net, rds: convert rds_ib_device.refcount from atomic_t to refcount_t
  net, rds: convert rds_incoming.i_refcount from atomic_t to refcount_t
  net, rds: convert rds_mr.r_refcount from atomic_t to refcount_t
  net, rds: convert rds_message.m_refcount from atomic_t to refcount_t
  net, x25: convert x25_route.refcnt from atomic_t to refcount_t
  net, x25: convert x25_neigh.refcnt from atomic_t to refcount_t
  net, xfrm: convert xfrm_state.refcnt from atomic_t to refcount_t
  net, xfrm: convert xfrm_policy.refcnt from atomic_t to refcount_t
  net, xfrm: convert sec_path.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_auth_bytes.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_datamsg.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_chunk.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_transport.refcnt from atomic_t to refcount_t
  net, sctp: convert sctp_ep_common.refcnt from atomic_t to refcount_t
  net, ax25: convert ax25_uid_assoc.refcount from atomic_t to refcount_t
  net, ax25: convert ax25_route.refcount from atomic_t to refcount_t
  net, ax25: convert ax25_cb.refcount from atomic_t to refcount_t

 drivers/net/vxlan.c             | 10 +++++-----
 include/linux/atmdev.h          |  7 ++++---
 include/linux/sunrpc/auth_gss.h |  3 ++-
 include/net/ax25.h              | 20 ++++++++++----------
 include/net/calipso.h           |  4 ++--
 include/net/dn_fib.h            |  5 +++--
 include/net/ipx.h               | 13 +++++++------
 include/net/lapb.h              |  3 ++-
 include/net/llc.h               |  6 +++---
 include/net/netrom.h            | 13 +++++++------
 include/net/sch_generic.h       |  3 ++-
 include/net/sctp/auth.h         |  5 +++--
 include/net/sctp/structs.h      |  8 ++++----
 include/net/vxlan.h             |  2 +-
 include/net/x25.h               | 13 +++++++------
 include/net/xfrm.h              | 21 +++++++++++----------
 net/atm/lec.c                   |  6 +++---
 net/atm/lec_arpc.h              |  2 +-
 net/atm/mpoa_caches.c           | 26 +++++++++++++-------------
 net/atm/mpoa_caches.h           |  5 +++--
 net/atm/proc.c                  |  2 +-
 net/atm/resources.c             |  2 +-
 net/ax25/af_ax25.c              |  2 +-
 net/ax25/ax25_route.c           |  2 +-
 net/ax25/ax25_uid.c             |  2 +-
 net/bridge/br_private.h         |  3 ++-
 net/bridge/br_vlan.c            |  8 ++++----
 net/decnet/dn_fib.c             |  6 +++---
 net/ipv6/calipso.c              | 12 ++++++------
 net/ipx/af_ipx.c                |  6 +++---
 net/ipx/ipx_proc.c              |  2 +-
 net/ipx/ipx_route.c             |  2 +-
 net/key/af_key.c                |  2 +-
 net/l2tp/l2tp_core.c            | 16 ++++++++--------
 net/l2tp/l2tp_core.h            | 13 +++++++------
 net/l2tp/l2tp_debugfs.c         |  4 ++--
 net/l2tp/l2tp_ppp.c             |  2 +-
 net/lapb/lapb_iface.c           |  6 +++---
 net/llc/llc_core.c              |  2 +-
 net/netrom/nr_route.c           |  6 +++---
 net/rds/ib.c                    | 12 ++++++------
 net/rds/ib.h                    |  2 +-
 net/rds/ib_rdma.c               |  4 ++--
 net/rds/message.c               | 12 ++++++------
 net/rds/rdma.c                  | 10 +++++-----
 net/rds/rds.h                   |  9 +++++----
 net/rds/recv.c                  | 12 ++++++------
 net/sched/sch_api.c             |  8 ++++----
 net/sched/sch_generic.c         |  8 ++++----
 net/sctp/associola.c            |  6 +++---
 net/sctp/auth.c                 |  4 ++--
 net/sctp/chunk.c                |  6 +++---
 net/sctp/endpointola.c          |  6 +++---
 net/sctp/sm_make_chunk.c        |  6 +++---
 net/sctp/transport.c            |  8 ++++----
 net/sunrpc/auth_gss/auth_gss.c  | 28 ++++++++++++++--------------
 net/x25/x25_link.c              |  2 +-
 net/x25/x25_route.c             |  2 +-
 net/xfrm/xfrm_input.c           |  4 ++--
 net/xfrm/xfrm_policy.c          |  4 ++--
 net/xfrm/xfrm_state.c           |  4 ++--
 61 files changed, 223 insertions(+), 209 deletions(-)

-- 
2.7.4

