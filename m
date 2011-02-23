Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:58107 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab1BWIEo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Feb 2011 03:04:44 -0500
Subject: Re: Invisible file problem
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Bruce Guenter <bruce@untroubled.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110222215214.GA32537@untroubled.org>
References: <20110222215214.GA32537@untroubled.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Feb 2011 23:50:47 -0800
Message-ID: <1298447447.2968.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-02-22 at 15:52 -0600, Bruce Guenter wrote: 
> I have come on a situation where a file in a directory is not showing up
> in any directory listings, yet is still accessible by direct access.  It
> shows up in listings on the server but not on the client.  I did a
> capture of the NFS protocol traffic, and the file is showing up in the
> readdir call results.  If I recreate the directory using the same file
> names but empty files, the behavior persists.
> 
> I am running vanilla 2.6.37.1 on both client and server, using NFSv4.
> The server filesystem is ext4.
> 
> Is this a kernel NFS client bug?  Is there anything else I can do to
> diagnose the source of the problem, or any way to work around it?
> 
> Thanks.

There is a known bug in readdir that has been fixed in 2.6.38-rc6, but
hasn't yet hit the 2.6.37 stable series. Please check the patch at

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=d1205f87bbb8040c1408bbd9e0a720310b2b0b9b

and see if it fixes your problem.

Cheers
  Trond

