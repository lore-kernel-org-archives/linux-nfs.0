Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46503 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756211Ab1DVQqu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Apr 2011 12:46:50 -0400
From: andros@netapp.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] nfsd v4.1 lOCKT clientid field must be ignored
Date: Fri, 22 Apr 2011 12:45:59 -0400
Message-Id: <1303490759-2646-2-git-send-email-andros@netapp.com>
In-Reply-To: <1303490759-2646-1-git-send-email-andros@netapp.com>
References: <1303490759-2646-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

RFC 5661 Section 18.11.3

   The clientid field of the owner MAY be set to any value by the client
   and MUST be ignored by the server.  The reason the server MUST ignore
   the clientid field is that the server MUST derive the client ID from
   the session ID from the SEQUENCE operation of the COMPOUND request.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4xdr.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index abdd42d..eb234df 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -591,8 +591,6 @@ nfsd4_decode_lockt(struct nfsd4_compoundargs *argp, struct nfsd4_lockt *lockt)
 	READ_BUF(lockt->lt_owner.len);
 	READMEM(lockt->lt_owner.data, lockt->lt_owner.len);
 
-	if (argp->minorversion && !zero_clientid(&lockt->lt_clientid))
-		return nfserr_inval;
 	DECODE_TAIL;
 }
 
-- 
1.7.2.3

