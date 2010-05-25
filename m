Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34917 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754449Ab0EYBgC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 21:36:02 -0400
Date: Tue, 25 May 2010 11:35:53 +1000
From: Neil Brown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100525113553.3928bc1a@notabene.brown>
In-Reply-To: <20100524164736.GR31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
	<20100524115903.GP31073@ZenIV.linux.org.uk>
	<20100524155031.GQ31073@ZenIV.linux.org.uk>
	<1274718082.10795.31.camel@heimdal.trondhjem.org>
	<20100524164736.GR31073@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 24 May 2010 17:47:36 +0100
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, May 24, 2010 at 12:21:22PM -0400, Trond Myklebust wrote:
> > > Can an nfs4 server e.g. have /x/y being a symlink that resolves to /a/b and
> > > allow mounting of both /x/y/c and /a/b/c?  Which path would it return to
> > > client that has mounted both, walked to some referral point and called
> > > nfs_do_refmount(), triggering nfs4_proc_fs_locations()?
> > > 
> > > Trond, Neil?
> > 
> > When mounting /x/y/c in your example above, the NFSv4 protocol requires
> > the client itself to resolve the symlink, and then walk down /a/b/c
> > (looking up component by component), so it will in practice not see
> > anything other than /a/b/c.
> > 
> > If it walks down to a referral, and then calls nfs_do_refmount, it will
> > do the same thing: obtain a path /e/f/g on the new server, and then walk
> > down that component by component while resolving any symlinks and/or
> > referrals that it crosses in the process.
> 
> Ho-hum...  What happens if the same fs is mounted twice on server?  I.e.
> have ext2 from /dev/sda1 mounted on /a and /b on server, then on the client
> do mount -t nfs foo:/a /tmp/a; mount -t nfs foo:/b /tmp/b.  Which path
> would we get from GETATTR with fs_locations requested, if we do it for
> /tmp/a/x and /tmp/b/x resp.?  Dentry will be the same, since fsid would
> match.
> 
> Or would the server refuse to export things that way?

If an explicit fsid or uuid is given for the two different export points,
then the server will happily export both and the client will see two
different filesystems that happen to contain identical content.  They could
return different fs_locations, or could return the same depending on what is
specified in /etc/exports.

If mountd is left to choose the default uuid, then it will only export one of
them at a time.  When the client requests the mount of "foo:/b", the
information given to the kernel will over-ride the export of "/a".  The
client won't notice much as the filehandles will all be the same.

The value returned for fs_locations is given to the kernel by mountd based on
the contents of /etc/exports.
So if you mount /dev/sda1 on /a /b, then in /etc/exports have:

  /a *(locations=foo_a)
  /b *(locations=foo_b)

(or whatever the correct syntax is), then when the client does

   mount foo:/a /tmp/a

and asks for fs_locations in /tmp/a it will get something based on foo_a..
If it then does
   mount foo:/b /tmp/b
then future fs_locations requests in either /tmp/a or /tmp/b will be based on
foo_b.

If one client mounts foo:/a and then another mounts foo:/b, then both will
see foo_b locations.

Obviously setting /etc/exports up like this with different locations for the
same data would be pretty silly.   If the different exports of the same fs
had the same locations, then it would all work sensibly.

At least, the above is a worst case.  It is not impossible that mountd could
detect that the two exports are the same and would prefer the "first" one in
all cases.  In that case the results would be more stable, but not
necessarily more "correct" (whatever that means here).

NeilBrown
