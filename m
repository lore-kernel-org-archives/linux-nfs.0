From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: use nfs client rpc callback program
Date: Wed, 17 Sep 2008 19:10:18 -0400
Message-ID: <20080917231018.GA5723@fieldses.org>
References: <48D15DF0.4000406@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	pnfs mailing list <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36449 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbYIQXKd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 19:10:33 -0400
In-Reply-To: <48D15DF0.4000406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 17, 2008 at 02:43:44PM -0500, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> since commit ff7d9756b501744540be65e172d27ee321d86103
> "nfsd: use static memory for callback program and stats"
> do_probe_callback uses a static callback program
> (NFS4_CALLBACK) rather than the one set in clp->cl_callback.cb_prog
> as passed in by the client in setclientid (4.0)
> or create_session (4.1).

Ugh, yes, sorry about that.  (I wonder why pynfs testing didn't catch
this?  Oh, I guess it's because NFS4_CALLBACK is the program number our
client always gives us.)

> @@ -371,6 +356,8 @@ static int do_probe_callback(void *data)
>  		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
>  		.to_exponential	= 1,
>  	};
> +	static struct rpc_stat	cb_stats;
> +	struct rpc_program	cb_program;
>  	struct rpc_create_args args = {
>  		.protocol	= IPPROTO_TCP,
>  		.address	= (struct sockaddr *)&addr,
> @@ -394,6 +381,20 @@ static int do_probe_callback(void *data)
>  	addr.sin_port = htons(cb->cb_port);
>  	addr.sin_addr.s_addr = htonl(cb->cb_addr);
>  
> +	/* Initialize rpc_program */
> +	memset(&cb_program, 0, sizeof(cb_program));
> +	cb_program.name = "nfs4_cb";
> +	cb_program.number = clp->cl_callback.cb_prog;
> +	cb_program.nrvers = ARRAY_SIZE(nfs_cb_version);
> +	cb_program.version = nfs_cb_version;
> +	cb_program.stats = &cb_stats;
> +	memset(&cb_stats, 0, sizeof(cb_stats));
> +	cb_stats.program = &cb_program;

You don't want a pointer to data on the stack here, do you?

--b.
