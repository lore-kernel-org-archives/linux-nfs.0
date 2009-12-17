From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock
 restart
Date: Thu, 17 Dec 2009 15:48:03 -0500
Message-ID: <1261082883.4080.28.camel@localhost>
References: <4B275EA3.9030603@cn.fujitsu.com>
	 <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com>
	 <4B28B5FD.5000103@cn.fujitsu.com>
	 <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com>
	 <4B2A02C6.6080501@cn.fujitsu.com>
	 <35D45F43-D98F-460E-8060-F7C5F3ADFCFE@oracle.com>
	 <1261081664.4080.18.camel@localhost>
	 <76D5AD4C-2DDA-4A12-BD53-168D04CA9E7C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49448 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764895AbZLQUsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 15:48:13 -0500
In-Reply-To: <76D5AD4C-2DDA-4A12-BD53-168D04CA9E7C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-12-17 at 15:34 -0500, Chuck Lever wrote: 
> On Dec 17, 2009, at 3:27 PM, Trond Myklebust wrote:
> > One alternative might be to just record the kernel's random boot_id in
> > the pid file. That gets regenerated on each boot, so should be unique.
> 
> Where do you get it in user space?  Is it available on earlier  
> kernels?  ("should be unique" -- I hope it doesn't have the same  
> problem we had with XID replay on diskless systems).

You can access it from userland as the 'kernel.random.boot_id' sysctl.

It is available on 2.4 kernels and newer.

It is based on the kernel random number generator, so should be
reasonably unique.

> Fwiw, I tried using the boot time stamp at one point, but  
> unfortunately that's adjusted by the ntp offset, so it can take  
> different values over time.  It was difficult to compare it to a time  
> stamp recorded in a file.

Agreed. You can't rely on time stamps.

Trond

