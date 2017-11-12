Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47201 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750951AbdKLT1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Nov 2017 14:27:16 -0500
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v5 00/13] exit_net checks for objects initialized in net_init
 hook
To: netdev@vger.kernel.org
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Remi Denis-Courmont <courmisch@gmail.com>,
        linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
References: <cb06dace-88a8-fecf-92ad-02920920a0d3@virtuozzo.com>
Message-ID: <a09a38cb-4aa3-ace5-3e0f-759d14cdef71@virtuozzo.com>
Date: Sun, 12 Nov 2017 22:26:44 +0300
MIME-Version: 1.0
In-Reply-To: <cb06dace-88a8-fecf-92ad-02920920a0d3@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OpenVz kernel team have a long history of fighting against namespace-related bugs,
some of them could be prevented by using simple checks described below.

One of typical errors is related to live cycle of namespaces:
usually objects created for some namespace should not live longer than namespace itself.

Such kind of issues can be invisible on usual systems where additional namespaces
are not used, because initial namespaces usually lives forever and never destroyed.

However in systems with namespaces it can lead to memory leaks or to use-after-free.
Both of them are critical for systems with running containers.
As you knows it's quite hard to find the reason of such issues,
especially in rarely-triggered scenarios on production nodes on default kernels
without specially enabled debug settings. Any additional hints can be useful here.

This patch set should help to detect some of these issues.
It is based on assumption that objects initialized in init hook of pernet_operations
should return to initial state until end of exit hook.

Many drivers and subsystems already have such checks, however I've found number
of places where list_empty check would be useful at least as smoke test.

These checks are useful for long-term stable kernels,
they allows to detect problems related to incomplete or incorrectly
backported patches.

Changes:
v5:
- fixed nit pointed by Florian Westphal
- netfilter patches are send separately to netfilter-devel@

v4:
- excluded grace and lockd patches taken by Bruce Fields
- let's use WARN_ON_ONCE without any extra messages
   adobriyan@ is right, output of net Id gives nothing to host admin,
   and developers in any case will extract information from core dump
- updated description in cover letter
- dropped nfs4blocklayout patch: waitqueue check does not look useful
- patches was reordered to be per-subsystem grouped
- cover letter should be sent to all people included into cc: of any patches
- minor cosmetic changes in some patches

v3:
- use net->ns.inum as net Id
- removed patches for hashlimit and recent,
    they handle tables list in exit_net hook.
- added patches for grace and lockd

v2:
- net pointer removed from output
- fixed compilation for phonet driver


Vasily Averin (13):
  af_key: replace BUG_ON on WARN_ON in net_exit hook
  geneve: exit_net cleanup check added
  packet: exit_net cleanup check added
  vxlan: exit_net cleanup checks added
  netdev: exit_net cleanup check added
  fib_notifier: exit_net cleanup check added
  fib_rules: exit_net cleanup check added
  l2tp: exit_net cleanup check added
  nfs client: exit_net cleanup check added
  sunrpc: exit_net cleanup check added
  phonet: exit_net cleanup check added
  ppp: exit_net cleanup checks added
  xfrm6_tunnel: exit_net cleanup check added

 drivers/net/geneve.c          | 1 +
 drivers/net/ppp/ppp_generic.c | 2 ++
 drivers/net/vxlan.c           | 4 ++++
 fs/nfs/inode.c                | 4 ++++
 net/core/dev.c                | 2 ++
 net/core/fib_notifier.c       | 6 ++++++
 net/core/fib_rules.c          | 6 ++++++
 net/ipv6/xfrm6_tunnel.c       | 8 ++++++++
 net/key/af_key.c              | 2 +-
 net/l2tp/l2tp_core.c          | 4 ++++
 net/packet/af_packet.c        | 1 +
 net/phonet/pn_dev.c           | 3 +++
 net/sunrpc/sunrpc_syms.c      | 3 +++
 13 files changed, 45 insertions(+), 1 deletion(-)

-- 
2.7.4

