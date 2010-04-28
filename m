Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:42788 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932269Ab0D1W3i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 18:29:38 -0400
Subject: Re: NULL pointer dereference in 2.6.32.12 on mount attempt
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Robert Henney <robh@rut.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100428222339.GA3490@rut.org>
References: <20100428191758.GA16717@rut.org>
	 <1272486263.2864.57.camel@localhost.localdomain>
	 <20100428222339.GA3490@rut.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Apr 2010 18:29:33 -0400
Message-ID: <1272493773.2864.73.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-04-28 at 18:23 -0400, Robert Henney wrote: 
> On Wed, Apr 28, 2010 at 04:24:23PM -0400, Trond Myklebust wrote:
> > What happens if you do
> > 
> > echo 1025 > /proc/sys/sunrpc/nfs_debug
> > 
> > prior to trying the mount?
> 
> the client becomes slow enough to be unusable after the value of nfs_debug
> is changed to 1025, which is probably due to it being a diskless client.  
> although the root filesystem is not the mount causing the issue, I can
> try and get a dedicated test machine set up soon to aid further testing.

I was thinking more about what the contents of your kernel syslog.

IOW: if you do

dmesg -s 900000 > /tmp/dmesg.txt

what are the contents of the file /tmp/dmesg.txt?

Cheers
  Trond

