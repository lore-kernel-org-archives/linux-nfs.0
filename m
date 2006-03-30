From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 09:50:52 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0603300949000.18696@p34>
References: <Pine.LNX.4.64.0603300813270.18696@p34>
 <1143728720.8074.41.camel@lade.trondhjem.org>  <Pine.LNX.4.64.0603300929340.18696@p34>
 <1143729766.8074.49.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750708AbWC3Ouy@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1143729766.8074.49.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

I tried an exportfs -rv and it did not help.  Any other suggestions?

On Thu, 30 Mar 2006, Trond Myklebust wrote:

> On Thu, 2006-03-30 at 09:30 -0500, Justin Piszcz wrote:
>
>> The kernel version in question is  2.4.21-31.ELa1smp.
>
> I take it that the standard 'exportfs -rv' doesn't help? Normally, that
> should suffice to stuff /proc/fs/nfs/exports with the entries
> in /etc/exports.
>
> Cheers,
>  Trond
>
