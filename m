From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs + Reiser4
Date: Wed, 07 Apr 2010 18:49:02 -0400
Message-ID: <1270680542.6995.21.camel@localhost.localdomain>
References: <op.vaq49joctxpshh@localhost.localdomain>
	 <20100407173438.GA25614@fieldses.org> <4BBCD271.5040100@oracle.com>
	 <20100407185157.GF26072@fieldses.org> <4BBCD618.50301@oracle.com>
	 <20100407192025.GH26072@fieldses.org>
	 <1270674567.3177.2.camel@localhost.localdomain>
	 <4BBCFA28.2030101@catking.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:34760 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753435Ab0DGWtL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 18:49:11 -0400
In-Reply-To: <4BBCFA28.2030101-B3jsHfKwJfLR7s880joybQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-04-07 at 23:33 +0200, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote: 
> Some more info on the machines in question.
> 
> server: gentoo linux 2.6.29 kernel patched for R4 
> .net-fs/nfs-utils-1.2.1  Recently added nfs4 to existing nfs3 in kernel. 
> This did not seem to improve/deteriorate the problem. This has been an 
> issue ever since I used nfs to remote boot the client.
> 
> Client. ARM SBC also running 2.6.29 nfs3. Similar issues seen when 
> running manufacturer's 2.4 kernel. Suggests problem is on server.
> 
> Redboot bootstrap loads kernel via http then boots with nfsroot supplied 
> by server.
> 
> All specific issues related here are as seen yesterday with both running 
> 2.6.29.
> 
> The set up is damn near unusable as it is behaving now . Files are 
> constantly out of sync. Changes seem to stay or disappear in a more or 
> less arbitrary fashion (ie no percievable repeatable pattern or cause). 
> Files often get some kind of merge state which is neither the state on 
> the server , nor the last saved state on the client.
> 
> /dev/root on / type nfs
> (rw,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nointr,nolock,\proto=udp,timeo=\
> 11,retrans=3,sec=sys,addr=192.168.1.3)
> 
> I note vers=2 here, does this maybe indicate some trouble with the 
> initial negotiation and fallback to nfs2 ?
> 
> I don't have one clear , reproducible problem because the results are so 
> erratic. But just editting a file with vi on the client and reopening it 
> will give incorrect results 8 time out of 10.
> 
> The reboot issue killed me. I thought is desperation that that would at 
> least mean I got a clean copy.

OK, so clearly not a userspace NFS issue then.

Just out of interest, are you able to reproduce this problem with other
underlying filesystems? Reiser4 has never been merged into the mainline
kernel, so I doubt that any one of us has a test setup.

Cheers
  Trond

