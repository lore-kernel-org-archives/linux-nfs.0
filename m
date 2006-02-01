From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] nfs version 2 broken
Date: Wed, 01 Feb 2006 20:19:22 +0100
Message-ID: <43E109BA.2070004@t-online.de>
References: <43E05031.2000107@t-online.de>	 <1138774519.7861.4.camel@lade.trondhjem.org>  <43E0567F.20004@t-online.de>	 <1138775744.7875.0.camel@lade.trondhjem.org> <43E05FA1.6070407@t-online.de> <1138812065.7858.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422884AbWBATTE@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138812065.7858.6.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:

>Does it do the same if you mount the same partition normally (i.e. not
>through nfsroot) in some other directory?
>
>  
>

That also fails. Same error message.

Unlike the nfsroot code at least my version of mount
does not use nfs version 2 as the default. I had to force
a v2 nfs mount attempt with mount -o nfsvers=2 ...

Would it be a good idea to change the default nfs version
nfsroot uses? I think nfsroot and mount defaults should
be identical.

BTW: Google shows some related old threads, e.g. "Madhan" writes on
2 Aug. 2001 06:55  "There has been a change in the NFS Client
behaviour in Linux Kernel  2.4.3 onwards.  There are 2 issues here,
1. as traces show new clients expect link count '1' and NetWare
NFS has  been sending '0' for volumes. ..."

cu,
 Knut
