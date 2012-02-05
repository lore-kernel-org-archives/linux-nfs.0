Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:35971 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2BEJ1R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 04:27:17 -0500
Message-ID: <4F2E4B50.5040701@steve-ss.com>
Date: Sun, 05 Feb 2012 10:26:40 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: Liam Gretton <liam.gretton@leicester.ac.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com> <4F2D9A0E.6010503@leicester.ac.uk>
In-Reply-To: <4F2D9A0E.6010503@leicester.ac.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/02/12 21:50, Liam Gretton wrote:
> I have a related question, and like the OP I was reluctant to ask here 
> as it's not a dev question, but I can't find any other suitable forum.
>
> Has ANYBODY got kerberised NFS working where the KDC is Active 
> Directory on a Windows 2008 R2 system? With 2008 R2, DES encryption 
> for Kerberos is no longer enabled.
>
> Our AD admins are understandably not keen to go against the 
> recommended behaviour and enable DES just for this service (it needs 
> to be enabled globally across the domain).
>
> I can't find any documentation about Kerberised NFS that looks more 
> recent than about 2006. That coupled with what I can see in the 
> sources suggest that there's little development in this area, so I 
> suspect the answer is that nobody has managed what I'm trying to do.
>
Hi Liam
I am the OP. We really do need some down to earth and up to date info on 
NFS4. More to the point, it needs to be all in one place, rather than 
having snippets all around the Internet. I'm not a tecchie but maybe I 
could put together a readable howto if there was enough demand.

We have kerberized nfs4 working against Samba 4. There seem to be 
different flavours of des. The Samba 4 Kerberos produced these server 
keys for our test domain:

    1 nfs/hh3.hh3.site@HH3.SITE (des-cbc-crc)
    1 nfs/hh3.hh3.site@HH3.SITE (des-cbc-md5)
    1 nfs/hh3.hh3.site@HH3.SITE (arcfour-hmac)

We put together a howto which includes the nfs4 stuff here:
http://linuxcostablanca.blogspot.com/p/samba-4.html

HTH a little
Cheers,
Steve
