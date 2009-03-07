From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] nfs-utils: fix memory usage problems in gssd
Date: Sat,  7 Mar 2009 07:45:25 -0500
Message-ID: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55530 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753838AbZCGMph (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Mar 2009 07:45:37 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset fixes a compiler warning and some problems noticed while
running gssd under valgrind. With this, valgrind now reports no warnings
or significant memory leaks when run under a simple test that repeatedly
mounts and unmounts an export with sec=krb5.

Jeff Layton (3):
  nfs-utils: initialize fakeseed in prepare_krb5_rfc1964_buffer
  nfs-utils: NULL-terminate buffer after read in read_service_info
  nfs-utils: free buffer allocated by gssd_k5_err_msg

 utils/gssd/context_heimdal.c |   25 ++++++----
 utils/gssd/context_lucid.c   |    6 ++-
 utils/gssd/gssd_proc.c       |    1 +
 utils/gssd/krb5_util.c       |  105 +++++++++++++++++++++++++-----------------
 utils/gssd/krb5_util.h       |    3 +-
 5 files changed, 83 insertions(+), 57 deletions(-)

