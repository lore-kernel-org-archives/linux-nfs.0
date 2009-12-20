From: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: Re: Problem with 2.6.33-rc1 and insecure flag
Date: Sun, 20 Dec 2009 10:46:26 +0100
Message-ID: <20091220094625.GA2159@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:35447
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752484AbZLTJqd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Dec 2009 04:46:33 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think I figured out the problem. 

Apparently the code checked if insecure was set, while it should check if it was NOT set.

Kind regards,
Michael

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 1c12177..55c8e63 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -89,7 +89,7 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
        int flags = nfsexp_flags(rqstp, exp);
 
        /* Check if the request originated from a secure port. */
-       if (!rqstp->rq_secure && (flags & NFSEXP_INSECURE_PORT)) {
+       if (!rqstp->rq_secure && !(flags & NFSEXP_INSECURE_PORT)) {
                RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
                dprintk(KERN_WARNING
                       "nfsd: request from insecure port %s!\n",



