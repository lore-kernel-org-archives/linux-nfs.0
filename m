From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/16] NLM clean-ups for IPv6 support
Date: Mon, 30 Jun 2008 18:58:05 -0400
Message-ID: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:16347 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755153AbYF3W62 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:58:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Trond -

This patch series prepares the kernel NLM implementation to support IPv6
network addresses.  These should not cause any disruption for legacy IPv4
support, and shouldn't depend on the previous 15 patches I just posted.

Please consider these for 2.6.27.  I think it would be reasonable for this
work to get some exercise with IPv4 before we finish the IPv6
implementation.

I have about 10 more patches that add NSM support for IPv6 and expose NLM's
IPv6 capability.  However, we haven't been able to test these yet because
we don't have an IPv6-capable user space rpc.statd yet.  I think they can wait
for 2.6.28.

---

Chuck Lever (16):
      lockd: change nlmclnt_grant() to take a "struct sockaddr *"
      lockd: Adjust nlmsvc_lookup_host() to accomodate non-AF_INET
      lockd: Adjust nlmclnt_lookup_host() signature to accomodate non-AF_INET
      lockd: Support non-AF_INET addresses in nlm_lookup_host()
      lockd: Update nsm_find() to support non-AF_INET addresses
      lockd: Combine __nsm_find() and nsm_find().
      lockd: Support AF_INET6 when hashing addresses in nlm_lookup_host
      lockd: Teach nlm_cmp_addr() to support AF_INET6 addresses
      NSM: Use sockaddr_storage for sm_addr field
      lockd: Use sockaddr_storage for h_saddr field
      lockd: Use sockaddr_storage + length for h_addr field
      SUNRPC: Make svc_addr's argument a constant
      lockd: Add address family-agnostic helper for zeroing the port number
      lockd: Specify address family for source address
      lockd: address-family independent printable addresses
      lockd: Pass "struct sockaddr *" to new failover-by-IP function


 fs/lockd/clntlock.c         |    9 +
 fs/lockd/host.c             |  341 +++++++++++++++++++++++++++++++------------
 fs/lockd/mon.c              |    2 
 fs/lockd/svc4proc.c         |    2 
 fs/lockd/svcproc.c          |    2 
 fs/lockd/svcsubs.c          |   39 +++--
 fs/nfsd/nfsctl.c            |   15 +-
 include/linux/lockd/lockd.h |   99 +++++++++++-
 include/linux/sunrpc/svc.h  |    6 -
 9 files changed, 379 insertions(+), 136 deletions(-)

-- 
Chuck Lever
chu ckl eve rat ora cle dot com
