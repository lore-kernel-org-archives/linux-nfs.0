Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52141 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758395Ab3ENVqM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:46:12 -0400
Date: Tue, 14 May 2013 17:46:09 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd4: implement minimal SP4_MACH_CRED
Message-ID: <20130514214609.GC16811@fieldses.org>
References: <1368565973-16739-1-git-send-email-bfields@redhat.com>
 <1368565973-16739-4-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368565973-16739-4-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 14, 2013 at 05:12:53PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Do a minimal SP4_MACH_CRED implementation suggested by Trond, ignoring
> the client-provided spo_must_* arrays and just enforcing credential
> checks for the minimum required operations.

Reviewing myself:

> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |   66 +++++++++++++++++++++++++++++++++++++++++----------
>  fs/nfsd/nfs4xdr.c   |   22 +++++++++++++++++
>  fs/nfsd/state.h     |    1 +
>  3 files changed, 77 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 52f9e92..4e50a2d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1265,6 +1265,23 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
>  	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
>  }
>  
> +static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
> +{
> +	struct svc_cred *cr = &rqstp->rq_cred;
> +	u32 service;
> +
> +	if (!cl->cl_mach_cred)
> +		return true;
> +	if (cl->cl_cred.cr_gss_mech != cr->cr_gss_mech)
> +		return false;
> +	service = gss_pseudoflavor_to_service(cr->cr_gss_mech, cr->cr_flavor);
> +	if (service != RPC_AUTH_GSS_KRB5I && service != RPC_AUTH_GSS_KRB5P)

Whoops, those constants are pseudoflavors, not service types.

Also, I'm assuming here that if cl_mach_cred is true then the client's
gss_mechanism and principal are non-null.  But that's not necessarily
true since I forgot to enforce the requirement that the exchange_id also
be sent with integrity or privacy in the SP4_MACH_CRED case.

So, I need the following.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4e50a2d..293ffbe 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1265,17 +1265,25 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
 }
 
-static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
+static bool svc_rqst_integrity_protected(struct svc_rqst *rqstp)
 {
 	struct svc_cred *cr = &rqstp->rq_cred;
 	u32 service;
 
+	service = gss_pseudoflavor_to_service(cr->cr_gss_mech, cr->cr_flavor);
+	return service == RPC_GSS_SVC_INTEGRITY ||
+	       service == RPC_GSS_SVC_PRIVACY;
+}
+
+static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
+{
+	struct svc_cred *cr = &rqstp->rq_cred;
+
 	if (!cl->cl_mach_cred)
 		return true;
 	if (cl->cl_cred.cr_gss_mech != cr->cr_gss_mech)
 		return false;
-	service = gss_pseudoflavor_to_service(cr->cr_gss_mech, cr->cr_flavor);
-	if (service != RPC_AUTH_GSS_KRB5I && service != RPC_AUTH_GSS_KRB5P)
+	if (!svc_rqst_integrity_protected(rqstp))
 		return false;
 	if (!cr->cr_principal)
 		return false;
@@ -1661,6 +1669,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	switch (exid->spa_how) {
 	case SP4_MACH_CRED:
+		if (!svc_rqst_integrity_protected(rqstp))
+			return nfserr_inval;
 	case SP4_NONE:
 		break;
 	default:				/* checked by xdr code */
