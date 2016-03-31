Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654AbcCaRyq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Mar 2016 13:54:46 -0400
Date: Thu, 31 Mar 2016 13:54:44 -0400
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 credential choice for the CLOSE operation
Message-ID: <20160331175444.GC22462@fieldses.org>
References: <87twjns6wf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87twjns6wf.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 31, 2016 at 01:44:32PM +1100, NeilBrown wrote:
> In NFSv4.1 the client can request, in the EXCHANGE_ID operation,
> permission to use machine credentials to validate a CLOSE operation.
> When the server gives that permission, it does *not* include implicit
> permission to use the machine credentials for the PUTFH operation which
> must precede CLOSE in the same request.
> 
> At least, I cannot see that RFC5661 gives that implicit permission and a
> customer has a server that doesn't give that permission.

Ugh.  Yeah, the first section I thought to check was

	http://tools.ietf.org/html/rfc5661#section-2.6.3

which allows deferring checks until an operation following the putfh in
some cases, but not in this case.  I haven't reviewed the state
protection sections.

It sounds like a protocol bug to me.

I wonder why CLOSE takes a filehandle at all.  The server can look up
the stateid without the filehandle.  And permissions to close should be
deterined by who "owns" that open, not by file permissions.

--b.

> 
> So I conclude that it is only safe to use the machine credentials if
> NFS_SP4_MACH_CRED_CLEANUP is set *and* the security tuple for the
> machine credential is a tuple which is permitted for the file handle.
> 
> So I came up with the following patch which I suspect is very wrong but
> at least shows where I am looking.  And compiles :-)
> 
> Details of the problem situation is that even though kerberos is
> configured and usable, the NFS client is mounting with sec=sys and the
> server is exporting with a similar setting.
> So kerberos is used to provide a machine credential and to validate
> state management, but AUTH_SYS is used for all file accesses.
> 
> In this context here is no *need* to use the machine credential to
> validate CLOSE because AUTH_SYS credentials never expire.  But the linux
> NFS client does anyway, and the server rejects the PUT_FH because it
> wasn't authenticated with AUTH_SYS.
> 
> Can anyone suggest what a better fix would be - or explain to me how I
> have misread the RFC?
> 
> Thanks a lot,
> NeilBrown
> 
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 4afdee420d25..b1694890feb1 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -297,7 +297,9 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
>  	struct rpc_cred *newcred = NULL;
>  	rpc_authflavor_t flavor;
>  
> -	if (test_bit(sp4_mode, &clp->cl_sp4_flags)) {
> +	if (test_bit(sp4_mode, &clp->cl_sp4_flags) &&
> +	    (*clntp)->cl_auth->au_flavor
> +	    == clp->cl_rpcclient->cl_auth->au_flavor) {
>  		spin_lock(&clp->cl_lock);
>  		if (clp->cl_machine_cred != NULL)
>  			/* don't call get_rpccred on the machine cred -


