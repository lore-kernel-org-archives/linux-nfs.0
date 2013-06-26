Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f172.google.com ([209.85.214.172]:50823 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab3FZOgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 10:36:08 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so13599951obc.31
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 07:36:08 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfs: allow NFSv3 to fall back to AUTH_UNIX if initial auth selection fails
Date: Wed, 26 Jun 2013 10:36:01 -0400
Message-Id: <1372257363-28148-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I got a report of a regression in recent kernels. Windows 2012 servers
support v3 and v4.1. They also return a list of authflavors that starts
with AUTH_GSS flavors and ends with AUTH_SYS.

Since commit 4580a92 (NFS: Use server-recommended security flavor by
default (NFSv3)) mounting this server with nfsv3 fails unless you
specify sec=sys.

NFSv4.0 has code that allows it to fall back to using AUTH_SYS if the
initial attempt to use AUTH_GSS fails (in
nfs4_discover_server_trunking()). This is an attempt to make the v3
mounting code just as resilient in the same situation.

Jeff Layton (2):
  nfs: make nfs_select_flavor take a list of authflavors and a length
  nfs: allow NFSv3 to fall back to using AUTH_UNIX automatically if
    available

 fs/nfs/super.c | 51 +++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 37 insertions(+), 14 deletions(-)

-- 
1.8.1.4

