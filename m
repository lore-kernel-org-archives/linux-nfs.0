From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Reading NFS file without copying to user-space?
Date: Fri, 04 Sep 2009 18:15:06 -0400
Message-ID: <1252102506.5274.7.camel@heimdal.trondhjem.org>
References: <4AA16F25.6050700@candelatech.com>
	 <1252096543.2402.4.camel@heimdal.trondhjem.org>
	 <4AA17D62.9020404@candelatech.com>
	 <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no>
	 <4AA18D32.50507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41336 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933995AbZIDWPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 18:15:07 -0400
In-Reply-To: <4AA18D32.50507@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-04 at 14:57 -0700, Ben Greear wrote:
> On 09/04/2009 01:58 PM, Trond Myklebust wrote:
> 
> > You're missing the point. O_DIRECT does not copy data from the kernel
> > into userspace. The data is placed directly into the user buffer from
> > the socket.
> >
> > The only faster alternative would be to directly discard the data in the
> > socket, and we offer no option to do that.
> 
> I was thinking I might be clever and use sendfile to send an nfs
> file to /dev/zero, but unfortunately it seems sendfile can only send
> to a destination that is a socket....

Why do you think that would be any faster than standard O_DIRECT? It
should be slower, since it involves an extra copy.

Trond


