Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm29.bullet.mail.ac4.yahoo.com ([98.139.52.226]:36228 "HELO
	nm29.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754185Ab1CAWbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2011 17:31:09 -0500
Message-Id: <201103012231.p21MV68F018619@hope.more-right-rudder.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org
Subject: Re: Possible NFSv4 locking bug
In-reply-to: <20110301155308.GB20599@fieldses.org>
References: <201102281527.p1SFRNst010559@hope.more-right-rudder.com> <20110301155308.GB20599@fieldses.org>
From: "Rick Koshi" <nfs-bug-report@more-right-rudder.com>
Date: Tue, 01 Mar 2011 17:31:06 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

"J. Bruce Fields" writes:
> On Mon, Feb 28, 2011 at 10:27:23AM -0500, Rick Koshi wrote:
> > 
> > I've found that when I lock an NFS-mounted file on a client, the server
> > reserves an open file descriptor (as seen in /proc/sys/fs/file-nr).
> 
> So it looks like that's the total number of allocated struct file's
> across the system?

That sounds about right.  To be honest, I'm not 100% sure exactly
what that file reports.  But I do know that when it got that large,
I stopped being able to open new files as any non-root user.  Running
basic things like 'ls' gave me errors, as they were unable to open
shared libraries to run.

If you like, you can read the post I originally submitted
on serverfault.com, when I was trying to figure this out.
It documents a lot of what I tried:

   http://serverfault.com/questions/235059/vfs-file-max-limit-1231582-reached

> Is there any earlier kernel where you know this problem *didn't* occur?

Sorry, no.  This whole setup is fairly new.

    -- Rick
