From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Reading NFS file without copying to user-space?
Date: Fri, 4 Sep 2009 16:58:30 -0400
Message-ID: <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no>
References: <4AA16F25.6050700@candelatech.com> <1252096543.2402.4.camel@heimdal.trondhjem.org> <4AA17D62.9020404@candelatech.com>
Mime-Version: 1.0 (iPhone Mail 7A400)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:54478 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934082AbZIDU6e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 16:58:34 -0400
In-Reply-To: <4AA17D62.9020404@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 4, 2009, at 16:49, Ben Greear <greearb@candelatech.com> wrote:

> I'm using O_DIRECT (so that the server is continually stressed even if
> the file would have otherwise been cached locally on the client).
>
> This still causes a copy of the contents to user-space when I do a
> read() call though, as far as I can tell.  Since I'm normally not  
> looking
> at this data at all, the memory copy from kernel to user is wasted
> effort in my case.

You're missing the point. O_DIRECT does not copy data from the kernel  
into userspace. The data is placed directly into the user buffer from  
the socket.

The only faster alternative would be to directly discard the data in  
the socket, and we offer no option to do that.

Trond
