From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] nfs-utils: add initial tests for statd that run via
 "make check"
Date: Tue, 29 Dec 2009 11:09:16 -0500
Message-ID: <20091229110916.5f30a434@tlielax.poochiereds.net>
References: <1260992440-8234-1-git-send-email-jlayton@redhat.com>
	<1260992440-8234-3-git-send-email-jlayton@redhat.com>
	<4B336C25.7000705@RedHat.com>
	<20091224192007.217a9ed5@tupile.poochiereds.net>
	<B5BBFA5F-8B83-4AB2-A4CB-F9D315562434@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528AbZL2QJV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Dec 2009 11:09:21 -0500
In-Reply-To: <B5BBFA5F-8B83-4AB2-A4CB-F9D315562434@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 29 Dec 2009 10:38:38 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> >>> +grep -q $COOKIE /var/lib/nfs/statd/sm/$MON_NAME
> >> This is a distro specific path... The default is /var/lib/nfs/sm
> >> It would be nice if somehow we could pull in the NFS_STATEDIR define
> >> from support/include/config.h file...
> >>
> >
> > Good point. I'll need to think on how we can deal with that. Maybe  
> > what
> > I should do is add a new "statdtest" command that prints out this
> > directory? Unless someone has a better idea, I'll respin this set with
> > that change soon.
> 
> We'd be better off, I think, if you did this test using calls to  
> libnsm.a, rather than naked greps.  You're adding yet another  
> invisible and undocumented dependency on the "formal API" that is the  
> state directory.  I'd rather see the C API tested here, and then  
> deprecate direct accesses over time.
> 

Ok, maybe I need to sit down and write a "statdb" utility that can
read/manipulate the statd DB via the libnsm.a interfaces? That might be
handy for other purposes too. I'll look at that when I get back from
vacation...

-- 
Jeff Layton <jlayton@redhat.com>
