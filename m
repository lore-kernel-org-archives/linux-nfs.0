Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:58304 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595AbZCYTXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 15:23:46 -0400
Subject: Re: Making crossmnt a default export option
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <49CA7D93.9050608@RedHat.com>
References: <49CA7D93.9050608@RedHat.com>
Content-Type: text/plain
Date: Wed, 25 Mar 2009 15:23:40 -0400
Message-Id: <1238009020.26487.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-03-25 at 14:53 -0400, Steve Dickson wrote:
> Hello,
> 
> What would be the ramifications of turning on the crossmnt
> option on by default? Currently the the default is nocrossmnt.
> 
> In my recent work with pseudo exports, it has become very apparent
> that having the crossmnt always set, especially with multi file
> system exports, allows mount to "just work"!
> 
> So historically what is the reason for not allowing the clients
> to always cross file systems? Is it a security issue? 
> And again, what would be the ramifications always allowing, by
> default, clients to cross file systems?

I think the only real problem would be that Solaris tends to get very
confused when you do. As Benny pointed out, the original NFSv2 and NFSv3
specs didn't allow you to cross mount points, and so Solaris never got
round to implementing it.
I don't know what the current status is, but the original Solaris 10
NFSv4 client was also incapable of crossing mount points despite the
fact that rfc3530 does support it.

Cheers
  Trond

