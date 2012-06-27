Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29130 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709Ab2F0UFo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 16:05:44 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] SUNRPC handle EKEYEXPIRED in call_refreshresult
Date: Wed, 27 Jun 2012 16:05:34 -0400
Message-Id: <1340827535-3062-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Without this patch attempting to access a Kerberos mount with expired or no
credentials resulted in the NFS client hanging while retrying to refresh creds
for ever.

I tested NFSv3/v4/v4.1 sec=krb5 mounts. With expired or non-existent user
Kerberos credentials, trying to ls the mountpoint, or cd into the mountpoint
resulted in three failed upcalls to gssd (due to tk_cred_retry being set to 2)
then the 'Operation not permitted' message is returned to the user.

I think this patch should go into the stable kernel.

Andy Adamson (1):
  SUNRPC handle EKEYEXPIRED in call_refreshresult

 fs/nfs/nfs4proc.c |    2 --
 net/sunrpc/clnt.c |    4 ++++
 2 files changed, 4 insertions(+), 2 deletions(-)

-- 
1.7.7.6

