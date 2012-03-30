Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759210Ab2C3URt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 16:17:49 -0400
Date: Fri, 30 Mar 2012 16:17:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unlink within an open directory stream
Message-ID: <20120330161755.681e8924@corrin.poochiereds.net>
In-Reply-To: <4F70B2AE.4000504@panasas.com>
References: <275611967.8.1332608027370.JavaMail.root@thunderbeast.private.linuxbox.com>
	<1332609149.25346.12.camel@lade.trondhjem.org>
	<4F70B2AE.4000504@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 26 Mar 2012 11:17:18 -0700
Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 03/24/2012 10:12 AM, Myklebust, Trond wrote:
> 
> > On Sat, 2012-03-24 at 12:53 -0400, Matt W. Benjamin wrote:
> >> Hi,
> >>
> >> I don't think anything is.  Or, people originally reported the behavior against knfsd.
> >>
> >> Matt
> > 
> > There is a known issue with ext2/3/4 generating non-unique readdir
> > cookies. It rarely hits you when you are creating small directories, but
> > it frequently hits you with larger ones. A fix is underway that should
> > significantly reduce the frequency of cookie collisions.
> > 
> > Recent NFS clients will actually detect the presence of those cookie
> > loops, and log them in the kernel syslog. That would therefore be the
> > first thing that I'd check if confronted with this kind of problem.
> > 
> > Cheers
> >   Trond
> > 
> 
> 
> Trond please look on the bug report links below. It's not the "cookie collisions" case.
> 
> It's the new (post RHEL 6.0 Kernel) NFS need for opendir after an unlink.
> Now the POSIX man page *does* say that applications must re-opendir after
> unlink, but there are some applications who did not read the manual, and since
> it works with local filesystems and old nfs, (What Kernel RHEL 6.0 is based on?)
> they never noticed the bug and never fixed it.
> 

The RHEL6 kernel is 2.6.32 based, but we have (as always) done some
fairly extensive backports from upstream.

One of the things that was backported was the Bryan's work to clean up
readdir and to eliminate the readdirplus limit. With that change, you
get fewer entries per READDIRPLUS call, so you make more READDIRPLUS
calls to the server in order to traverse an entire directory.

Since you're unlinking as you go, then I suspect that you're just more
likely to see this problem crop up, but I suspect Trond is correct and
this is preexisting bug.

One way to confirm this might be to have them mount with -o nordirplus.
Does that make the problem go away?
-- 
Jeff Layton <jlayton@redhat.com>
