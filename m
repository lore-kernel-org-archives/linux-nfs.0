From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs: convert proto= option to use netid's rather than a
 protoname
Date: Thu, 29 Oct 2009 06:58:16 -0400
Message-ID: <20091029065816.314f5858@barsoom.rdu.redhat.com>
References: <1256758812-24928-1-git-send-email-jlayton@redhat.com>
	<20091029042415.GA2283@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754076AbZJ2K6T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Oct 2009 06:58:19 -0400
In-Reply-To: <20091029042415.GA2283@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 29 Oct 2009 00:24:15 -0400
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Oct 28, 2009 at 03:40:12PM -0400, Jeff Layton wrote:
> > Solaris uses netids as values for the proto= option, so that when
> > someone specifies "tcp6" they get traffic over TCP + IPv6. Until
> > recently, this has never really been an issue for Linux since it didn't
> > support NFS over IPv6.  The netid and the protocol name were generally
> > always the same (modulo any strange configuration in /etc/netconfig).
> > 
> > The solaris manpage documents their proto= option as:
> > 
> >     proto= _netid_ | rdma
> 
> I'm strictly against adding netid braindamage to Linux.  Just because
> Solaris made a mistake we don't have to repeat it.
> 
> Adding a hack to mount.nfs to parse it is fine, but there's not need to
> display it again.

Can you outline your objection to using netid's? What specifically are
you against here?

There's good reason to keep the userspace utility and kernel in sync
with respect to options. Otherwise if someone tries to remount a
filesystem with the options listed in /proc/mounts the result will be
different, no?

-- 
Jeff Layton <jlayton@redhat.com>
