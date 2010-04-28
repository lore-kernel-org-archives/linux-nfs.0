Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44758 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754835Ab0D1UYk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Apr 2010 16:24:40 -0400
Subject: Re: NULL pointer dereference in 2.6.32.12 on mount attempt
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Robert Henney <robh@rut.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100428191758.GA16717@rut.org>
References: <20100428191758.GA16717@rut.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Apr 2010 16:24:23 -0400
Message-ID: <1272486263.2864.57.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-04-28 at 15:17 -0400, Robert Henney wrote: 
> this bug has so far been reproducible.
> 
> I have an nfs server running Debian lenny with the stock 2.6.26-2-686
> kernel, and a client machine also running Debian lenny but with a
> 2.6.32.12 kernel (kernel config attached).
> 
> /etc/exports on the server, possibly bogus although the server never
> complains and still probably shouldn't trigger a NULL dereference in 
> the client:
>   /stow *(ro,fsid=0,crossmnt,no_subtree_check)
>   /stow -mp,ro,all_squash,async,no_subtree_check \
>     199.125.85.51  \
>     199.125.85.134 \
>     66.55.209.223

You probably want to add at least a 'fsid=0' option to that second line.

> /etc/fstab on the client:
>   199.125.85.39:/stow /stow nfs4 noatime

Should be

199.125.85.39:/ /stow nfs4


> the OOPS (attached below) occurs when attempting a mount from the client
> 
>   # mount /stow
>   # echo $?
>   2
> 
> the mount command never outputs but has a return code of 2 and the mount
> is not successful.

That looks like a stack overflow to me, but it's hard to tell.

What happens if you do

echo 1025 > /proc/sys/sunrpc/nfs_debug

prior to trying the mount?

Cheers
   Trond
