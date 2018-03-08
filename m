Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44222 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750885AbeCHV0B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 16:26:01 -0500
Date: Thu, 8 Mar 2018 16:26:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Guillem Jover <gjover@sipwise.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
Message-ID: <20180308212600.GB16485@fieldses.org>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org>
 <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
 <CAFMMQGv03UmmsyXF4BOrwgW9ngpeO=dLjv=Qt=YiPpvgxfo85A@mail.gmail.com>
 <D9BFFDFE-B80F-4220-9A54-F09F882BD0A1@gmail.com>
 <CAFMMQGtt_u19RoCyQAQEaSZRXu3WQ-YSKu4u1BtKtJnaTQbKYw@mail.gmail.com>
 <20180308202423.GA16485@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180308202423.GA16485@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 08, 2018 at 03:24:23PM -0500, bfields wrote:
> Looks like knfsd's not helpful here, though: the export option
> ("secure"/"insecure") defaults to "secure", which always requires a low
> port.  It should be easy to modify "secure" to mean "require low ports
> only for auth_sys/auth_null", and that's probably the right thing to do.

Disclaimer: totally untested.

--b.

commit ddc2a5f5ce98
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 8 15:49:48 2018 -0500

    nfsd: don't require low ports for gss requests
    
    In a traditional NFS deployment using auth_unix, the clients are trusted
    to correctly report the credentials of their logged-in users.  The
    server assumes that only root on client machines is allowed to send
    requests from low-numbered ports, so it can use the originating port
    number to distinguish "real" NFS clients from NFS clients run by
    ordinary users, to prevent ordinary users from spoofing credentials.
    
    The originating port number on a gss-authenticated request is less
    important.  The authentication ties the request to a user, and we take
    it as proof that that user authorized the request.  The low port number
    check no longer adds much.
    
    So, don't enforce low port numbers in the auth_gss case.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 8aa011820c4a..764e6cae6533 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -87,13 +87,23 @@ nfsd_mode_check(struct svc_rqst *rqstp, struct dentry *dentry,
 	return nfserr_inval;
 }
 
+static bool nfsd_originating_port_ok(struct svc_rqst *rqstp, int flags)
+{
+	if (flags & NFSEXP_INSECURE_PORT)
+		return true;
+	/* We don't require gss requests to use low ports: */
+	if (rqstp->rq_cred.cr_flavor >= RPC_AUTH_GSS)
+		return true;
+	return test_bit(RQ_SECURE, &rqstp->rq_flags);
+}
+
 static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 					  struct svc_export *exp)
 {
 	int flags = nfsexp_flags(rqstp, exp);
 
 	/* Check if the request originated from a secure port. */
-	if (!test_bit(RQ_SECURE, &rqstp->rq_flags) && !(flags & NFSEXP_INSECURE_PORT)) {
+	if (!nfsd_originating_port_ok(rqstp, flags)) {
 		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 		dprintk("nfsd: request from insecure port %s!\n",
 		        svc_print_addr(rqstp, buf, sizeof(buf)));
