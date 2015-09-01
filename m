Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48348 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbbIARnh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2015 13:43:37 -0400
Date: Tue, 1 Sep 2015 13:43:35 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Mkrtchyan, Tigran'" <tigran.mkrtchyan@desy.de>,
        "'Ulrich Gemkow'" <ulrich.gemkow@ikr.uni-stuttgart.de>,
        linux-nfs@vger.kernel.org
Subject: Re: NFSv4 mount fails on Sun Solaris 10 after reboot of client
Message-ID: <20150901174335.GB32692@fieldses.org>
References: <201508241452.57718.ulrich.gemkow@ikr.uni-stuttgart.de>
 <20150824201401.GA401@fieldses.org>
 <201508251928.06201.ulrich.gemkow@ikr.uni-stuttgart.de>
 <20150825215456.GF8579@fieldses.org>
 <824431189.4182121.1440657831497.JavaMail.zimbra@desy.de>
 <20150827182922.GB11819@fieldses.org>
 <008901d0e108$13caa520$3b5fef60$@mindspring.com>
 <20150828180612.GC10468@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150828180612.GC10468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2015 at 02:06:12PM -0400, 'J. Bruce Fields' wrote:
> On Thu, Aug 27, 2015 at 01:36:38PM -0700, Frank Filz wrote:
> > If the creds don't match, the return should be NFS4ERR_CLID_INUSE per
> > section 16.34.5. IMPLEMENTATION first bullet after DRC discussion.
> > 
> > At least the way I read RFC 7530...
> 
> I assumed that was only the case when the long-form client-provided
> client identifier matched, but here we're looking at records matched by
> the shorthand server-generated clientid.  Very weird that that we'd get
> to this case (and without hitting CLID_INUSE on the setclientid?).
> There's something we don't understand.
> 
> Anyway, looking at the SETCLIENTID_CONFIRM description in 7530, I think
> you're right, they're recommending CLIDN_INUSE for this case.  Doubt
> that would actually help in Ulrich's case, though.

May as well fix that anyway, I guess.--b.

commit 3d70e158ea9b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Sep 1 13:40:53 2015 -0400

    nfsd: return CLID_INUSE for unexpected SETCLIENTID_CONFIRM case
    
    Somebody with a Solaris client was hitting this case.  We haven't
    figured out why yet, and don't have a reproducer.  Meanwhile Frank
    noticed that RFC 7530 actually recommends CLID_INUSE for this case.
    Unlikely to help the original reporter, but may as well fix it.
    
    Reported-by: Frank Filz <ffilzlnx@mindspring.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 416f32e34a33..08746ec1d44a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3111,10 +3111,11 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	/*
 	 * We try hard to give out unique clientid's, so if we get an
 	 * attempt to confirm the same clientid with a different cred,
-	 * there's a bug somewhere.  Let's charitably assume it's our
-	 * bug.
+	 * the client may be buggy; this should never happen.
+	 *
+	 * Nevertheless, RFC 7530 recommends INUSE for this case:
 	 */
-	status = nfserr_serverfault;
+	status = nfserr_clid_inuse;
 	if (unconf && !same_creds(&unconf->cl_cred, &rqstp->rq_cred))
 		goto out;
 	if (conf && !same_creds(&conf->cl_cred, &rqstp->rq_cred))
