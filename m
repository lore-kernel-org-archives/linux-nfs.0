Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45823 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754456Ab1CBTPq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 14:15:46 -0500
Date: Wed, 2 Mar 2011 14:15:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rick Koshi <nfs-bug-report@more-right-rudder.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Possible NFSv4 locking bug
Message-ID: <20110302191545.GA3981@fieldses.org>
References: <201102281527.p1SFRNst010559@hope.more-right-rudder.com>
 <20110301155308.GB20599@fieldses.org>
 <201103012231.p21MV68F018619@hope.more-right-rudder.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201103012231.p21MV68F018619@hope.more-right-rudder.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 01, 2011 at 05:31:06PM -0500, Rick Koshi wrote:
> "J. Bruce Fields" writes:
> > On Mon, Feb 28, 2011 at 10:27:23AM -0500, Rick Koshi wrote:
> > > 
> > > I've found that when I lock an NFS-mounted file on a client, the server
> > > reserves an open file descriptor (as seen in /proc/sys/fs/file-nr).
> > 
> > So it looks like that's the total number of allocated struct file's
> > across the system?
> 
> That sounds about right.  To be honest, I'm not 100% sure exactly
> what that file reports.  But I do know that when it got that large,
> I stopped being able to open new files as any non-root user.  Running
> basic things like 'ls' gave me errors, as they were unable to open
> shared libraries to run.
> 
> If you like, you can read the post I originally submitted
> on serverfault.com, when I was trying to figure this out.
> It documents a lot of what I tried:
> 
>    http://serverfault.com/questions/235059/vfs-file-max-limit-1231582-reached

Yeah, this is an nfsv4-specific bug, and I can reproduce it easily by
e.g. running cthon -l in a loop on the client while monitoring file-nr
on the server.  I see the problem, but there's more than one thing to
fix there, so it needs more thought; I'll try to have a patch out by the
end of the day.

--b.
