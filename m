From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/5] nfs-utils: convert gssd to TI-RPC and add IPv6 support (try #3)
Date: Sun,  5 Apr 2009 09:42:58 -0400
Message-ID: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, kwc@citi.umich.edu
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54326 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754766AbZDENnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Apr 2009 09:43:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is a second attempt at adding support for IPv6 to
rpc.gssd. The main changes from the first set are some minor fixes and
changes suggested by Chuck Lever and a change to use common code to
spawn a new RPC client. This set is also based on mainline nfs-utils
since the requisite patches for it are now there.

The series should be fully bisectable, but I've only really tested the
end result for anything other than to see if it compiles. With these
patches I've been able to mount an OpenSolaris server using
NFSv3/4 + IPv6 + krb5 auth. I've also done testing with builds with
only TIRPC enabled and with TIRPC and IPv6 both disabled and haven't
seen any regressions.

Specific changes from the last set:
- check the validity of port given by an upcall
- check return code from snprintf()
- switched gssd to use nfs_get_rpcclient()
- pare down hints passed to getaddrinfo() in populate_port()

Jeff Layton (5):
  nfs-utils: make getnameinfo() required for --enable-gss
  nfs-utils: store the address given in the upcall for later use
  nfs-utils: skip getaddrinfo in create_auth_rpc_client unless we need
    port
  nfs-utils: switch gssd to use standard function for getting an RPC
    client
  nfs-utils: add IPv6 code to gssd

 configure.ac           |    2 +
 utils/gssd/gssd.h      |    2 +-
 utils/gssd/gssd_proc.c |  285 +++++++++++++++++++++++++++++++++---------------
 3 files changed, 202 insertions(+), 87 deletions(-)

