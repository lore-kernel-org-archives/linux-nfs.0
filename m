Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48732 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934384AbZIDWts (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 18:49:48 -0400
Subject: Re: Reading NFS file without copying to user-space?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4AA19520.70305@candelatech.com>
References: <4AA16F25.6050700@candelatech.com>
	 <1252096543.2402.4.camel@heimdal.trondhjem.org>
	 <4AA17D62.9020404@candelatech.com>
	 <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no>
	 <4AA18D32.50507@candelatech.com>
	 <1252102506.5274.7.camel@heimdal.trondhjem.org>
	 <4AA19520.70305@candelatech.com>
Content-Type: text/plain
Date: Fri, 04 Sep 2009 18:49:42 -0400
Message-Id: <1252104582.5274.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-09-04 at 15:30 -0700, Ben Greear wrote:
> On 09/04/2009 03:15 PM, Trond Myklebust wrote:
> > On Fri, 2009-09-04 at 14:57 -0700, Ben Greear wrote:
> >> On 09/04/2009 01:58 PM, Trond Myklebust wrote:
> >>
> >>> You're missing the point. O_DIRECT does not copy data from the kernel
> >>> into userspace. The data is placed directly into the user buffer from
> >>> the socket.
> >>>
> >>> The only faster alternative would be to directly discard the data in the
> >>> socket, and we offer no option to do that.
> >>
> >> I was thinking I might be clever and use sendfile to send an nfs
> >> file to /dev/zero, but unfortunately it seems sendfile can only send
> >> to a destination that is a socket....
> >
> > Why do you think that would be any faster than standard O_DIRECT? It
> > should be slower, since it involves an extra copy.
> 
> I was thinking that the kernel might take the data received in the skb's from
> the file-server and send it to /dev/null, ie basically just immediately
> discard the received data.  If it could do that, it would be a zero-copy
> read:  The only copying would be the NIC DMA'ing the packet into the skb.

No... The RPC layer will always copy the data from the socket into a
buffer. If you are using O_DIRECT reads, then that buffer will be the
same one that you supplied in userland (the kernel just uses page table
trickery to map those pages into the kernel address space). If you are
using any other type of read (even if it is being piped using sendfile()
or splice()) then it will copy that data into the NFS filesystem's page
cache.

> It would also seem to me that if one allowed sendfile to copy between
> files, it could do the same trick saving to a real file and save user-space
> having to read the file in and then write it out again to disk.

As I said above, sendfile and splice don't work that way. They both use
the page cache as the source, so the filesystem needs to fill the page
cache first.

> Out of curiosity, any one have any benchmarks for NFS on 10G hardware?

I'm not aware of any public figures. I'd be interested to hear how you
max out.

> Based on testing against another vendor's nfs server, it seems that the client
> is loosing packets (the server shows tcp retransmits).

Is the data being lost at the client, the switch or the server? Assuming
that you are using a managed switch, then a look at its statistics
should be able to answer that question.


