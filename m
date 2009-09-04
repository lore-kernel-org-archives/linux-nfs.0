From: Ben Greear <greearb@candelatech.com>
Subject: Re: Reading NFS file without copying to user-space?
Date: Fri, 04 Sep 2009 14:57:06 -0700
Message-ID: <4AA18D32.50507@candelatech.com>
References: <4AA16F25.6050700@candelatech.com> <1252096543.2402.4.camel@heimdal.trondhjem.org> <4AA17D62.9020404@candelatech.com> <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43330 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934318AbZIDV5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 17:57:12 -0400
In-Reply-To: <74C14419-4D21-4EC2-B01A-EAC04B354F06@fys.uio.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2009 01:58 PM, Trond Myklebust wrote:

> You're missing the point. O_DIRECT does not copy data from the kernel
> into userspace. The data is placed directly into the user buffer from
> the socket.
>
> The only faster alternative would be to directly discard the data in the
> socket, and we offer no option to do that.

I was thinking I might be clever and use sendfile to send an nfs
file to /dev/zero, but unfortunately it seems sendfile can only send
to a destination that is a socket....

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

