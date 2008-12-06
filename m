From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/27] Remaining IPv6 NSM patches for 2.6.29
Date: Fri, 05 Dec 2008 19:01:48 -0500
Message-ID: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:30333 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbYLFACY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:02:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

A little light reading for the weekend.

These are all the IPv6-related patches for NSM I have.  I'll post the
NFSD patches next week.

The first six patches convert the NSM client's upcalls to use xdr_stream
based XDR encoders and decoders.  I figure we won't be back in this area
for a while, but eventually we will want all the client XDR functions to
be based on xdr_stream.  So while this is still fresh in my mind, I did
the conversion.

The next thirteen patches reorganize the kernel's NSM implementation to
allow us to replace the current contents of NSMPROC_MON's "priv"
argument with something not based on an IP address.

Then one patch that does that replacement.

This is followed by four clean up patches, and the final three patches
take the wraps off IPv6 support for lockd.

---

Chuck Lever (27):
      lockd: Enable NLM use of AF_INET6
      NLM: Rewrite IPv4 privileged requester's check
      NLM: nlm_privileged_requester() doesn't recognize mapped loopback address
      NSM: Move nsm_create()
      NSM: Move nsm_use_hostnames to mon.c
      NSM: Move nsm_addr() to fs/lockd/mon.c
      NSM: Remove include/linux/lockd/sm_inter.h
      NSM: Replace IP address as our nlm_reboot lookup key
      NSM: More clean up of nsm_get_handle()
      NSM: Refactor nsm_handle creation into a helper function
      NLM: Remove "create" argument from nsm_find()
      NLM: Call nsm_reboot_lookup() instead of nsm_find()
      NSM: Add nsm_lookup() function
      NLM: Decode "priv" argument of NLMPROC_SM_NOTIFY as an opaque
      NLM: Change nlm_host_rebooted() to take a single nlm_reboot argument
      NSM: Encode the new "priv" cookie for NSMPROC_MON requests
      NSM: Generate NSMPROC_MON's "priv" argument when nsm_handle is created
      NSM: Remove !nsm check from nsm_release()
      NSM: Remove NULL pointer check from nsm_find()
      NSM: Add dprintk() calls in nsm_find and nsm_release
      NSM: Move nsm_find() to fs/lockd/mon.c
      NSM: Remove unused old-style XDR functions
      NSM: Switch over to the new-style XDR functions
      NSM: Add xdr_stream-based XDR encoders
      NSM: Add xdr_stream-based XDR encoders
      NSM: Move NSM program and procedure numbers to fs/lockd/mon.c
      NSM: Move NSM-related XDR data structures to lockd's xdr.h


 fs/lockd/clntproc.c            |    1 
 fs/lockd/host.c                |  168 +-------------
 fs/lockd/mon.c                 |  491 ++++++++++++++++++++++++++++++++--------
 fs/lockd/svc.c                 |   15 +
 fs/lockd/svc4proc.c            |   13 -
 fs/lockd/svcproc.c             |   13 -
 fs/lockd/svcsubs.c             |    1 
 fs/lockd/xdr.c                 |    5 
 fs/lockd/xdr4.c                |    5 
 include/linux/lockd/lockd.h    |   39 ++-
 include/linux/lockd/sm_inter.h |   46 ----
 include/linux/lockd/xdr.h      |   15 +
 12 files changed, 457 insertions(+), 355 deletions(-)
 delete mode 100644 include/linux/lockd/sm_inter.h

-- 
Chuck Lever
