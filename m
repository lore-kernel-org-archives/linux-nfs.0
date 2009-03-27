From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Problems with default ACLs over NFS
Date: Thu, 26 Mar 2009 17:05:13 -0700
Message-ID: <20090326170513.4e7d377a.akpm@linux-foundation.org>
References: <20090323222427.00bb24e7@werewolf.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
To: =?ISO-8859-1?Q? "J.A._Magall=F3n" ?= <jamagallon-sh/6fXdz2Rs@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58952 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932697AbZC0AHE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 20:07:04 -0400
In-Reply-To: <20090323222427.00bb24e7-BIo4oXGMtDgJmsy6czSMtA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc linux-nfs)

On Mon, 23 Mar 2009 22:24:27 +0100 "J.A. Magall__n" <jamagallon-sh/6fXdz2Rs@public.gmane.org> wrote:

> Hi all...
> 
> I have a strange problem with 2.6.29-rc8-git3.
> It looks like a kernel bug... ?
> 
> I have a box with NFS autofs-mounted home directories. Server is a
> Solaris 10 system. This worked in previous kernel versions, so I
> don't blame Solaris, at this moment.
> 
> With this acls set in my home:
> 
> 
> prometeo:~> getfacl .  
> 
> # file: .
> # owner: magallon
> # group: giga
> user::rwx
> user:webservd:r-x       #effective:r-x
> group::--x      #effective:--x
> mask:r-x
> other:--x
> default:user::rwx
> default:group::--x
> default:other:--x
> 
> I get this strange message in the linux client:
> 
> cicely:~> mkdir kk  
> mkdir: cannot create directory `kk': Invalid argument
> 
> But the directory is created, and its ACLs are correct:
> 
> prometeo:~> getfacl kk  
> 
> # file: kk
> # owner: magallon
> # group: giga
> user::rwx
> group::--x      #effective:--x
> other:--x
> default:user::rwx
> default:group::--x
> default:other:--x
> 
> If I remove the 'default' entries, the error message goes away.
> 
> With strace, I get this:
> 
> mkdir("kk", 0777)                       = -1 EINVAL (Invalid argument)
> 
> Mount info from /proc/mounts:
> 
> ldap:danae-nfs:automountMapName=auto_home,o=diis /home autofs rw,fd=7,pgrp=3165,timeout=600,minproto=5,maxproto=5,indirect 0 0
> 
> danae-nfs:/export/home/usuarios/giga/magallon /home/magallon nfs rw,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=155.210.152.202,mountvers=3,mountproto=tcp,addr=155.210.152.202 0 0
> 
> It happens the same If I try to create a file with "> kk", or try to cp -r one
> other dir, but "touch kk" works.
> 
> Any idea ?
> 

