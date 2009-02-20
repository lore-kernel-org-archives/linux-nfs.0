From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Fri, 20 Feb 2009 15:14:24 -0500
Message-ID: <20090220201424.GG1104@fieldses.org>
References: <18846.4842.625445.980681@notabene.brown> <20090220182350.GB1104@fieldses.org> <18847.2286.101191.989726@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51761 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742AbZBTUO0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2009 15:14:26 -0500
In-Reply-To: <18847.2286.101191.989726-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 21, 2009 at 06:47:58AM +1100, Neil Brown wrote:
> 
> Trond seems happy with it now.  And the NFSv4 server effectively
> imposes it.  So maybe there are no remaining arguments against it ??

None from me.

> 
> > 
> > >  2/ The server could lie about the mtime.
> > >     In particular, if the mtime for a file was the same as the current
> > >     time - to the granularity of the filesystem storing the file -
> > >     then reduce the mtime that is reported by the smallest difference that
> > >     can be reported by the protocol.
> > >     That would be one microsecond for v2, and one nanosecond for v3
> > >     and v4.
> > 
> > Assume for simplicity's sake the time granularity is a second, and
> > measure time in seconds in the following examples:
> > 
> > Your proposal offers an improvement in this example (currently,
> > subsequent getattrs will not reflect the final modification):
> > 
> > 	t=0.1 modify
> > 	t=0.2 getattr
> > 	t=0.3 modify
> > 
> > Your proposal causes a regression in the following example:
> > 
> > 	t=0.1 modify
> > 	t=0.2 getattr
> > 	t=1.1 modify 
> > 	t=1.2 modify
> > 
> 
> I cannot see how there is a regression here.  Subsequent getattrs will
> show all modifications (if you wait at least one second).
> The first gettattr returns '-0.000000001', which is different from any
> previously returned mtime.
> Any subsequent getattr will return 0.999999999 or 1, depending on when
> it arrives.

Sorry, I guess I misread "smallest difference that can be reported by
the protocol" as "smallest difference supported by the filesystem"!

The former is currently *always* smaller than the latter, so you're
reporting an mtime that will never arise in any other way.  So you're
right, this results in strictly more cache revalidations in every case.

It may turn out that this mtime-1 case ends up being the typical case,
since a single logical file modification may appear as multiple writes
on the server, and those are likely to come in rapid succession.

A "make" that takes less than one second, on an ext3 export, may result
in targets with earlier mtimes than sources.

(Why not mtime+1?  And why not ctime?)

> The only possible regression is that sometimes we will flush the cache
> when previously we didn't.  In each case where that changes, the
> client can not possible know whether it needs to or not, so flushing
> rather than not flushing is the safest option.
> 
> > 
> > By the way, I have one sadly neglected todo here: ext4 has a real nfsv4
> > changeattribute, which needs to be hooked up to the nfsd code.
> 
> Does it?
> I just had a quick look, found that it stores a 64 bit number on disk
> which is stored in inode->i_version.
> And this is incremented for directory operations.  But it doesn't seem
> to be changed for file operations.
> 
> But maybe I missed something.

After some mucking around with git and git grep... looks like the
inode_inc_iversion() calls do the job.  Note there's an i_version mount
option that's required.

--b.
