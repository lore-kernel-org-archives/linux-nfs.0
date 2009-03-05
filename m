From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Further nfs-utils clean ups
Date: Wed, 04 Mar 2009 19:02:31 -0500
Message-ID: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:16952 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbZCEADm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 19:03:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here are six more patches that clean up various issues to prepare for
the widespread use of TI-RPC in nfs-utils.

We discovered a type width mismatch issue between our legacy RPC
headers and the TI-RPC run-time that will be addressed in a subsequent
patch series by using TI-RPC to build all of nfs-utils.  This issue
should be addressed before the next release of nfs-utils is published.

The idea will be to build nfs-utils with either glibc's legacy RPC
implementation and the legacy RPC headers (as it is today in 1.1.3),
or with libtirpc and TI-RPC's headers, based on the setting of
--enable-tirpc (which defaults to --disable-tirpc).

This further insulates ongoing IPv6 work from folks who need to use
today's up-to-date version of nfs-utils, while easily allowing us to
test a version built with complete TI-RPC integration.

---

Chuck Lever (6):
      gssd: include gssapi/gssapi.h before write_bytes.h
      gssd: Use same style for including config.h that rest of nfs-utils uses
      mount.nfs: squelch compiler warning for TI-RPC builds
      nfs-utils: Provide type-checked version of svc_getcaller()
      configure: Remove CPPFLAGS substitution
      nfs-utils: Replace getservbyname(3)


 configure.ac                   |    1 
 support/include/nfsrpc.h       |    6 --
 support/include/rpcmisc.h      |    9 +++
 support/nfs/getport.c          |  105 ++++++++++++++++++++++++----------------
 support/nfs/rpc_socket.c       |   46 ------------------
 utils/gssd/context.c           |    5 ++
 utils/gssd/context_heimdal.c   |    4 +-
 utils/gssd/context_lucid.c     |   10 ++--
 utils/gssd/context_mit.c       |    4 +-
 utils/gssd/context_spkm3.c     |    5 ++
 utils/gssd/err_util.c          |    4 ++
 utils/gssd/gss_clnt_send_err.c |    4 ++
 utils/gssd/gss_oids.c          |    4 ++
 utils/gssd/gss_util.c          |    6 ++
 utils/gssd/gssd.c              |    4 +-
 utils/gssd/gssd_main_loop.c    |    5 ++
 utils/gssd/gssd_proc.c         |    6 ++
 utils/gssd/krb5_util.c         |    6 ++
 utils/gssd/svcgssd.c           |    4 +-
 utils/gssd/svcgssd_main_loop.c |    4 ++
 utils/gssd/svcgssd_mech2file.c |    4 +-
 utils/gssd/svcgssd_proc.c      |    4 ++
 utils/mount/network.c          |    5 +-
 utils/mountd/mount_dispatch.c  |    7 ++-
 utils/mountd/mountd.c          |   20 +++-----
 utils/statd/callback.c         |    9 ++-
 utils/statd/monitor.c          |    5 ++
 utils/statd/simu.c             |   12 ++++-
 utils/statd/statd.c            |    6 ++
 29 files changed, 179 insertions(+), 135 deletions(-)

-- 
Chuck Lever
