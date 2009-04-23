From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/19] Proposed server-side patches for 2.6.31
Date: Thu, 23 Apr 2009 19:31:16 -0400
Message-ID: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:28267 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbZDWXc2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce -

Here are some patches I'd like to propose for 2.6.31.  Please review
and consider them for linux-next.  They've seen a little testing here
on x86_64, but they should get some public exercise.

The first 17 are updated versions of patches I submitted for 2.6.30,
but were dropped at the last minute to simplify things.  They provide
some clean-up for the nfsctl API, and a little more IPv6 support in
that area as well, in preparation for full-on IPv6-related changes to
come.  I think I've addressed earlier review comments.

As usual, it would be most helpful if you would drop the whole series
if you have issues with any of these patches.

Patch 18 addresses a long-standing problem with our NLM/NSM
implementation.  If lockd.ko isn't loaded before statd starts up
(which is the typical case for both our server and client) then
lockd's NSM state number is never set.  We then end up sending a zero
state number in all NLM requests.  This is also the case if lockd.ko
is unloaded and reloaded during normal operation -- the NSM state
number is reset to zero.  See the patch description for further
detail.

Patch 19 provides a little more 64-bit alignment clean up in
nsm_init_private() .

These two are independent of all the others and either or both can be
applied as you see fit.

---

Chuck Lever (19):
      lockd: clean up 64-bit alignment fix in nsm_init_private()
      lockd: Update NSM state from SM_MON replies
      NFSD: Stricter buffer size checking in fs/nfsd/nfsctl.c
      NFSD: Stricter buffer size checking in write_versions()
      NFSD: Stricter buffer size checking in write_recoverydir()
      SUNRPC: Clean up one_sock_name()
      SUNRPC: Support PF_INET6 in one_sock_name()
      SUNRPC: Switch one_sock_name() to use snprintf()
      SUNRPC: pass buffer size to svc_sock_names()
      SUNRPC: pass buffer size to svc_addsock()
      NFSD: Prevent a buffer overflow in svc_xprt_names()
      NFSD: move lockd_up() before svc_addsock()
      NFSD: Finish refactoring __write_ports()
      NFSD: Note an additional requirement when passing TCP sockets to portlist
      NFSD: Refactor socket creation out of __write_ports()
      NFSD: Refactor portlist socket closing into a helper
      NFSD: Refactor transport addition out of __write_ports()
      NFSD: Refactor transport removal out of __write_ports()
      SUNRPC: Fix error return value of svc_addr_len()


 fs/lockd/clntproc.c             |    2 
 fs/lockd/mon.c                  |   18 +-
 fs/nfsd/nfsctl.c                |  284 ++++++++++++++++++++++++---------------
 include/linux/sunrpc/svc_xprt.h |    7 +
 include/linux/sunrpc/svcsock.h  |    7 +
 net/sunrpc/svc_xprt.c           |   56 +++++---
 net/sunrpc/svcsock.c            |   87 +++++++++---
 7 files changed, 299 insertions(+), 162 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
