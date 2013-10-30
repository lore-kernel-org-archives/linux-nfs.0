Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab3J3Pcy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Oct 2013 11:32:54 -0400
Date: Wed, 30 Oct 2013 11:32:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 (For real this time)] NFSD: Combine decode operations
 for v4 and v4.1
Message-ID: <20131030153252.GF3227@fieldses.org>
References: <1383141620-11158-1-git-send-email-bjschuma@netapp.com>
 <20131030140459.GD3227@fieldses.org>
 <527124E3.3070101@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <527124E3.3070101@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 30, 2013 at 11:25:23AM -0400, Anna Schumaker wrote:
> On 10/30/2013 10:04 AM, J. Bruce Fields wrote:
> > On Wed, Oct 30, 2013 at 10:00:20AM -0400, Anna Schumaker wrote:
> >> We were using a different array of function pointers to represent each
> >> minor version.  This makes adding a new minor version tedious, since it
> >> needs a step to copy, paste and modify a new version of the same
> >> functions.
> >>
> >> This patch combines the v4 and v4.1 arrays into a single instance and
> >> will check minor version support inside each decoder function.
> > 
> > Thanks, Anna.  Applying pending some quick testing.
> > 
> > --b.
> > 
> >>
> >> Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
> >> ---
> >>  fs/nfsd/nfs4xdr.c | 98 +++++++++++++++++++++++--------------------------------
> >>  1 file changed, 40 insertions(+), 58 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index d9454fe..99bebea 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -945,13 +945,16 @@ static __be32
> >>  nfsd4_decode_open_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_open_confirm *open_conf)
> >>  {
> >>  	DECODE_HEAD;
> >> -		    
> >> +
> >> +	if (argp->minorversion >= 1)
> >> +		return nfserr_notsupp;
> >> +
> >>  	status = nfsd4_decode_stateid(argp, &open_conf->oc_req_stateid);
> >>  	if (status)
> >>  		return status;
> >>  	READ_BUF(4);
> >>  	READ32(open_conf->oc_seqid);
> >> -						        
> >> +
> >>  	DECODE_TAIL;
> >>  }
> >>  
> >> @@ -991,6 +994,14 @@ nfsd4_decode_putfh(struct nfsd4_compoundargs *argp, struct nfsd4_putfh *putfh)
> >>  }
> >>  
> >>  static __be32
> >> +nfsd4_decode_putpubfh(struct nfsd4_compoundargs *argp, void *p)
> >> +{
> >> +	if (argp->minorversion == 0)
> >> +		return nfs_ok;
> >> +	return nfserr_notsupp;
> >> +}
> >> +
> >> +static __be32
> >>  nfsd4_decode_read(struct nfsd4_compoundargs *argp, struct nfsd4_read *read)
> >>  {
> >>  	DECODE_HEAD;
> >> @@ -1061,6 +1072,9 @@ nfsd4_decode_renew(struct nfsd4_compoundargs *argp, clientid_t *clientid)
> >>  {
> >>  	DECODE_HEAD;
> >>  
> >> +	if (argp->minorversion >= 1)
> >> +		return nfserr_notsupp;
> >> +
> >>  	READ_BUF(sizeof(clientid_t));
> >>  	COPYMEM(clientid, sizeof(clientid_t));
> >>  
> >> @@ -1111,6 +1125,9 @@ nfsd4_decode_setclientid(struct nfsd4_compoundargs *argp, struct nfsd4_setclient
> >>  {
> >>  	DECODE_HEAD;
> >>  
> >> +	if (argp->minorversion >= 1)
> >> +		return nfserr_notsupp;
> >> +
> >>  	READ_BUF(NFS4_VERIFIER_SIZE);
> >>  	COPYMEM(setclientid->se_verf.data, NFS4_VERIFIER_SIZE);
> >>  
> >> @@ -1137,6 +1154,9 @@ nfsd4_decode_setclientid_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_s
> >>  {
> >>  	DECODE_HEAD;
> >>  
> >> +	if (argp->minorversion >= 1)
> >> +		return nfserr_notsupp;
> >> +
> >>  	READ_BUF(8 + NFS4_VERIFIER_SIZE);
> >>  	COPYMEM(&scd_c->sc_clientid, 8);
> >>  	COPYMEM(&scd_c->sc_confirm, NFS4_VERIFIER_SIZE);
> >> @@ -1220,6 +1240,9 @@ nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_rel
> >>  {
> >>  	DECODE_HEAD;
> >>  
> >> +	if (argp->minorversion >= 1)
> >> +		return nfserr_notsupp;
> >> +
> >>  	READ_BUF(12);
> >>  	COPYMEM(&rlockowner->rl_clientid, sizeof(clientid_t));
> >>  	READ32(rlockowner->rl_owner.len);
> >> @@ -1519,7 +1542,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
> >>  	[OP_OPEN_CONFIRM]	= (nfsd4_dec)nfsd4_decode_open_confirm,
> >>  	[OP_OPEN_DOWNGRADE]	= (nfsd4_dec)nfsd4_decode_open_downgrade,
> >>  	[OP_PUTFH]		= (nfsd4_dec)nfsd4_decode_putfh,
> >> -	[OP_PUTPUBFH]		= (nfsd4_dec)nfsd4_decode_noop,
> >> +	[OP_PUTPUBFH]		= (nfsd4_dec)nfsd4_decode_putpubfh,
> >>  	[OP_PUTROOTFH]		= (nfsd4_dec)nfsd4_decode_noop,
> >>  	[OP_READ]		= (nfsd4_dec)nfsd4_decode_read,
> >>  	[OP_READDIR]		= (nfsd4_dec)nfsd4_decode_readdir,
> >> @@ -1536,46 +1559,6 @@ static nfsd4_dec nfsd4_dec_ops[] = {
> >>  	[OP_VERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
> >>  	[OP_WRITE]		= (nfsd4_dec)nfsd4_decode_write,
> >>  	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_release_lockowner,
> >> -};
> >> -
> >> -static nfsd4_dec nfsd41_dec_ops[] = {
> >> -	[OP_ACCESS]		= (nfsd4_dec)nfsd4_decode_access,
> >> -	[OP_CLOSE]		= (nfsd4_dec)nfsd4_decode_close,
> >> -	[OP_COMMIT]		= (nfsd4_dec)nfsd4_decode_commit,
> >> -	[OP_CREATE]		= (nfsd4_dec)nfsd4_decode_create,
> >> -	[OP_DELEGPURGE]		= (nfsd4_dec)nfsd4_decode_notsupp,
> >> -	[OP_DELEGRETURN]	= (nfsd4_dec)nfsd4_decode_delegreturn,
> >> -	[OP_GETATTR]		= (nfsd4_dec)nfsd4_decode_getattr,
> >> -	[OP_GETFH]		= (nfsd4_dec)nfsd4_decode_noop,
> >> -	[OP_LINK]		= (nfsd4_dec)nfsd4_decode_link,
> >> -	[OP_LOCK]		= (nfsd4_dec)nfsd4_decode_lock,
> >> -	[OP_LOCKT]		= (nfsd4_dec)nfsd4_decode_lockt,
> >> -	[OP_LOCKU]		= (nfsd4_dec)nfsd4_decode_locku,
> >> -	[OP_LOOKUP]		= (nfsd4_dec)nfsd4_decode_lookup,
> >> -	[OP_LOOKUPP]		= (nfsd4_dec)nfsd4_decode_noop,
> >> -	[OP_NVERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
> >> -	[OP_OPEN]		= (nfsd4_dec)nfsd4_decode_open,
> >> -	[OP_OPENATTR]		= (nfsd4_dec)nfsd4_decode_notsupp,
> >> -	[OP_OPEN_CONFIRM]	= (nfsd4_dec)nfsd4_decode_notsupp,
> >> -	[OP_OPEN_DOWNGRADE]	= (nfsd4_dec)nfsd4_decode_open_downgrade,
> >> -	[OP_PUTFH]		= (nfsd4_dec)nfsd4_decode_putfh,
> >> -	[OP_PUTPUBFH]		= (nfsd4_dec)nfsd4_decode_notsupp,
> >> -	[OP_PUTROOTFH]		= (nfsd4_dec)nfsd4_decode_noop,
> >> -	[OP_READ]		= (nfsd4_dec)nfsd4_decode_read,
> >> -	[OP_READDIR]		= (nfsd4_dec)nfsd4_decode_readdir,
> >> -	[OP_READLINK]		= (nfsd4_dec)nfsd4_decode_noop,
> >> -	[OP_REMOVE]		= (nfsd4_dec)nfsd4_decode_remove,
> >> -	[OP_RENAME]		= (nfsd4_dec)nfsd4_decode_rename,
> >> -	[OP_RENEW]		= (nfsd4_dec)nfsd4_decode_notsupp,
> >> -	[OP_RESTOREFH]		= (nfsd4_dec)nfsd4_decode_noop,
> >> -	[OP_SAVEFH]		= (nfsd4_dec)nfsd4_decode_noop,
> >> -	[OP_SECINFO]		= (nfsd4_dec)nfsd4_decode_secinfo,
> >> -	[OP_SETATTR]		= (nfsd4_dec)nfsd4_decode_setattr,
> >> -	[OP_SETCLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
> >> -	[OP_SETCLIENTID_CONFIRM]= (nfsd4_dec)nfsd4_decode_notsupp,
> >> -	[OP_VERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
> >> -	[OP_WRITE]		= (nfsd4_dec)nfsd4_decode_write,
> >> -	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_notsupp,
> >>  
> >>  	/* new operations for NFSv4.1 */
> >>  	[OP_BACKCHANNEL_CTL]	= (nfsd4_dec)nfsd4_decode_backchannel_ctl,
> >> @@ -1599,23 +1582,23 @@ static nfsd4_dec nfsd41_dec_ops[] = {
> >>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
> >>  };
> >>  
> >> -struct nfsd4_minorversion_ops {
> >> -	nfsd4_dec *decoders;
> >> -	int nops;
> >> -};
> >> -
> >> -static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
> >> -	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
> >> -	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> >> -	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> >> -};
> >> +static inline bool
> >> +nfsd4_opnum_in_range(struct nfsd4_compoundargs *argp, struct nfsd4_op *op)
> >> +{
> >> +	if (op->opnum < FIRST_NFS4_OP || op->opnum > LAST_NFS4_OP)
> >> +		return false;
> >> +	else if (argp->minorversion == 0 && op->opnum > OP_RELEASE_LOCKOWNER)
> >> +		return false;
> >> +	else if (argp->minorversion == 1 && op->opnum > OP_RECLAIM_COMPLETE)
> >> +		return false;
> >> +	return true;
> >> +}
> 
> Hmm... would it be better to keep a "last ops" array that I can index into using minorversion for this check?  Something like:

I think what we have is OK as-is, but:

> 
> static nfs_opnum4 nfsd4_last_ops[] = {
> 	[0] = OP_RELEASE_LOCKOWNER,
> 	[1] = OP_RECLAIM_COMPLETE,
> 	[2] = OP_IO_ADVISE,
> };

If we were going to do something like that, sticking it next to the list
of ops in include/linux/nfs4.h might be nice.  And defines might be
sufficient:

	#define LAST_NFS40_OP OP_RELEASE_LOCKOWNER
	#define LAST_NFS41_OP OP_RECLAIM_COMPLETE

Oh, hah, now that I go to look at that file I see that it already
defines FIRST_NFS4_OP and LAST_NFS4_OP, it just doesn't do the latter
for minor versions.  How about just adding a couple new defines there?

If you do that, make it an incremental patch.

--b.
