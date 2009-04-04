From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mountd: use separate lockfiles
Date: Sat, 04 Apr 2009 07:53:45 -0400
Message-ID: <49D74A49.6030509@RedHat.com>
References: <20090319172841.GF26378@sgi.com> <1237485682.7534.39.camel@heimdal.trondhjem.org> <20090319195357.GH26378@sgi.com> <20090319221458.GI26378@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39634 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767AbZDDL4l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Apr 2009 07:56:41 -0400
In-Reply-To: <20090319221458.GI26378@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Ben Myers wrote:
> Hey Trond,
> 
> On Thu, Mar 19, 2009 at 02:53:57PM -0500, Ben Myers wrote:
>> On Thu, Mar 19, 2009 at 02:01:21PM -0400, Trond Myklebust wrote:
>>> Why do you need a second call to open() in the first place?
>> I'll give it another try.
> 
> Here it is again.  It works just fine without the second open.
> 
> Thanks,
> 	Ben
> 
> 
> From 1687f7a02cd34f76d5e6c461ca7d7bb56f3826d6 Mon Sep 17 00:00:00 2001
> From: Ben Myers <bpm@sgi.com>
> Date: Thu, 19 Mar 2009 16:44:54 -0500
> Subject: [PATCH] Mountd should use separate lockfiles
> 
> Mountd keeps file descriptors used for locks separate from those used for io
> and seems to assume that the lock will only be released on close of the file
> descriptor that was used with fcntl.  Actually the lock is released when any
> file descriptor for that file is closed.  When setexportent() is called after
> xflock() he closes and reopens the io file descriptor and defeats the lock.
> 
> This patch fixes that by using a separate file for locking, cleaning them up
> when finished.
> 
> Signed-off-by: Ben Myers <bpm@sgi.com>
Committed...

steved.
