From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] [PATCH 2/7] NFS: if ATTR_KILL_S*ID bits are set, then
 skip mode change
Date: Fri, 14 Sep 2007 12:01:03 -0400
Message-ID: <20070914120103.d1de2e64.jlayton@redhat.com>
References: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
	<20070914102545.GF21965@sgi.com>
	<20070914070258.8fccb40e.jlayton@redhat.com>
	<20070914130924.GG21965@sgi.com>
	<20070914093846.7cdd89da.jlayton@redhat.com>
	<20070914144033.GD25610@sgi.com>
	<20070914105838.efbfc45e.jlayton@redhat.com>
	<20070914154345.GE25610@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: reiserfs-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	ecryptfs-devel@lists.sourceforge.net, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org
To: Greg Banks <gnb@sgi.com>
Return-path: <reiserfs-devel-owner@vger.kernel.org>
In-Reply-To: <20070914154345.GE25610@sgi.com>
Sender: reiserfs-devel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 15 Sep 2007 01:43:45 +1000
Greg Banks <gnb@sgi.com> wrote:

> On Fri, Sep 14, 2007 at 10:58:38AM -0400, Jeff Layton wrote:
> > On Sat, 15 Sep 2007 00:40:33 +1000
> > Greg Banks <gnb@sgi.com> wrote:
> > 
> > 
> > > Ok, you convinced me.
> > 
> > Right. When I was first looking at this, I considered some similar
> > approaches, but hit roadblocks with all of them. The only real option
> > seems to be to leave this to the server, but that does assume that the
> > server handles this properly.
> > 
> > Servers that don't are broken, IMO.
> 
> According to what spec?  A quick trip around the machine room shows
> that neither Solaris 10 nor Darwin 7.9.0 clobber setuid on write
> either.
> 

Hmm, last time I checked Solaris, I thought it did, but that was
Solaris 11. I'll plan to fire up my solaris qemu image and test
it again...

> > If Irix isn't clearing these bits
> > on a write then it might be good to see if they can fix that...
> 
> I think first you'd have to mount a serious argument that it's broken,
> more serious than "it works differently from Linux".
> 

Good point. POSIX is frustratingly ambiguous on this:

     Upon successful completion, where nbyte is greater than 0, write()
     shall mark for update the st_ctime and st_mtime fields of the file,
     and if the file is a regular file, the S_ISUID and S_ISGID bits of
     the file mode may be cleared.

...the "may" in that last sentence makes it optional, I suppose. Even if
it weren't then I guess there's also an argument that a write that comes
in via a nfs server may not be subject to the same semantics as the
write() syscall.

In any case, "broken" is probably too strong a term :-)

-- 
Jeff Layton <jlayton@redhat.com>
