Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32493 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797Ab1G2Rdg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 13:33:36 -0400
Subject: Re: a BUG in mknod(./node_1077,0100777,0),
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Mrbuddy <buddy_sz@hotmail.com>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 29 Jul 2011 13:33:19 -0400
In-Reply-To: <SNT124-W56CFCEE312AD1F54B60803F7370@phx.gbl>
References: <SNT124-W56CFCEE312AD1F54B60803F7370@phx.gbl>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311960799.16078.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-29 at 15:56 +0000, Mrbuddy wrote: 
> 
> HI:
>  
> When I use mknod(./node_1077,0100777,0), it return a error       errno=2:No such file or directory.
> Mode 0100777 means create a common file.so I compared it with touch.
>  
> I found that when calling nfs4_do_open,in touch the flag is 0x8482,but in mknod,the flag is 0x40.
> When calling mknod,the flag come from function nfs_create,
> 
> if((nd->flags & LOOKUP_CREATE) !=0)
>      open_flags = nd->intent.open.flags;
> 
> so i guess can I add a flags at here as below:
> 
> if((nd->flags & LOOKUP_CREATE) !=0)
>      open_flags = nd->intent.open.flags | O_CREAT | F_WRLCK;
> 
> with this change, mknod(./node_1077,0100777,0) return success.
> look forward to your reply. 		 	   		  

Isn't this issue already fixed in mainline by commit f7c85868fc (fix
mknod() on nfs4 (hopefully))?

  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

