Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ferdi.naasa.net ([87.106.227.76]:49523 "EHLO ferdi.naasa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab2FKNe2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 09:34:28 -0400
References: <4FD47D4E.9070307@naasa.net> <1339340441.4751.1.camel@lade.trondhjem.org> <20120611121634.GB7654@fieldses.org> <20120611083932.24e27e39@corrin.poochiereds.net> <20120611091338.1c88e6d0@corrin.poochiereds.net>
In-Reply-To: <20120611091338.1c88e6d0@corrin.poochiereds.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=utf-8
Message-Id: <E49E5D8F-3647-4B3D-989E-FE4476D37607@naasa.net>
Cc: bfields <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Hans de Bruin <jmdebruin@xmsnet.nl>
From: =?utf-8?Q?J=C3=B6rg_Platte?= <jplatte@naasa.net>
Subject: Re: Kernel 3.4.X NFS server regression
Date: Mon, 11 Jun 2012 15:25:55 +0200
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am 11.06.2012 um 15:13 schrieb Jeff Layton <jlayton@redhat.com>:

> 
> Ahh, I think I see the bug. From rpc_timeout_upcall_queue:
> 
> -----------------------[snip]--------------------------
>        dentry = dget(pipe->dentry);
>        spin_unlock(&pipe->lock);
>        if (dentry) {
>                rpc_purge_list(&RPC_I(dentry->d_inode)->waitq,
>                               &free_list, destroy_msg, -ETIMEDOUT);
>                dput(dentry);
>        }
> -----------------------[snip]--------------------------
> 
> ...when there is no dentry (as there wouldn't be when rpc_pipefs isn't
> mounted), then the rpc_purge_list won't run. FWIW, you'd probably see
> similar problems if you attempted a sec=krb5 mount without having
> rpc_pipefs mounted.
> 
> I'm still looking at the code to see what the right fix is. For now,
> making sure you have a /var/lib/nfs/v4recoverydir is probably the
> easiest workaround.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>

On my computer that shows the bug there is indeed no v4recovery directory. There is one on the other machine that does not show this bug. I'll test the latest kernel with this directory created  today afternoon. 

Thank you for the analysis!

Jörg 