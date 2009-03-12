From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/14] nfsd4: fix do_probe_callback errors
Date: Thu, 12 Mar 2009 17:41:35 -0400
Message-ID: <20090312214135.GA9377@fieldses.org>
References: <1236731222-3294-6-git-send-email-bfields@fieldses.org> <1236731222-3294-7-git-send-email-bfields@fieldses.org> <1236731222-3294-8-git-send-email-bfields@fieldses.org> <1236731222-3294-9-git-send-email-bfields@fieldses.org> <1236731222-3294-10-git-send-email-bfields@fieldses.org> <1236731222-3294-11-git-send-email-bfields@fieldses.org> <1236731222-3294-12-git-send-email-bfields@fieldses.org> <1236731222-3294-13-git-send-email-bfields@fieldses.org> <1236731222-3294-14-git-send-email-bfields@fieldses.org> <49B8EA2E.4050707@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:45066 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbZCLVlo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 17:41:44 -0400
In-Reply-To: <49B8EA2E.4050707@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 12, 2009 at 12:55:42PM +0200, Benny Halevy wrote:
> On Mar. 11, 2009, 2:27 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > The errors returned aren't used.  Just return 0 and make them available
> 
> Wouldn't it be better to change the function to return void
> so justice would be seen to be done?

Yeah, but for now since this is passed to kthread_start() this is
probably needed to keep the compiler happy.

> > @@ -405,7 +403,8 @@ static int do_probe_callback(void *data)
> >  	/* Create RPC client */
> >  	client = rpc_create(&args);
> >  	if (IS_ERR(client)) {
> > -		dprintk("NFSD: couldn't create callback client\n");
> > +		dprintk("NFSD: couldn't create callback client: %d\n",
> > +			PTR_ERR(client));
> >  		status = PTR_ERR(client);
> 
> How about reversing the order and dprintk status instead of PTR_ERR(client)?

OK.

> 
> >  		goto out_err;
> >  	}
> > @@ -422,10 +421,10 @@ static int do_probe_callback(void *data)
> >  out_release_client:
> >  	rpc_shutdown_client(client);
> >  out_err:
> > -	dprintk("NFSD: warning: no callback path to client %.*s\n",
> > -		(int)clp->cl_name.len, clp->cl_name.data);
> > +	dprintk("NFSD: warning: no callback path to client %.*: error %ds\n",
> 
> seems like a typo. ": error %d" was pasted one char too soon...
> should be:
>  +	dprintk("NFSD: warning: no callback path to client %.*s: error %d\n",

Whoops, thanks.  How did that ever compile?  Oh, I see, I must have only
tested the comiple after the next patch, as it looks like I incorrectly
merged a half-fix there....

--b.
