Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f44.google.com ([209.85.128.44]:64306 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab3HBOaY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 10:30:24 -0400
Received: by mail-qe0-f44.google.com with SMTP id 6so373025qeb.17
        for <linux-nfs@vger.kernel.org>; Fri, 02 Aug 2013 07:30:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130802074353.514c8886@corrin.poochiereds.net>
References: <20130725055209.GA15621@sh-el5.eng.rdu2.redhat.com>
	<51F13948.3050100@redhat.com>
	<CAJfpegtpcXz+i-3txRC_NjTsYjXP5S4oJUdGstG+-PWVzazEWQ@mail.gmail.com>
	<51F81465.9010402@redhat.com>
	<20130801163940.GA1356@tucsk.piliscsaba.szeredi.hu>
	<51FAACD9.8020205@redhat.com>
	<CAJfpegu1RXAYOGWyuCeckJ8WHfK=3dFc5bm1zsM=1Qt3zcfbsg@mail.gmail.com>
	<20130802074353.514c8886@corrin.poochiereds.net>
Date: Fri, 2 Aug 2013 16:30:23 +0200
Message-ID: <CAJfpegthEZJEQhus=4CnvR+yb+vGj5c85kUnn18SrR0S1wbbtQ@mail.gmail.com>
Subject: Re: [PATCH] [REPOST] fuse: drop dentry on failed revalidate
From: Miklos Szeredi <miklos@szeredi.hu>
To: Jeff Layton <jlayton@redhat.com>
Cc: Ric Wheeler <rwheeler@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Anand Avati <avati@redhat.com>, Brian Foster <bfoster@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Alexander Viro <aviro@redhat.com>, David Howells <dhowells@redhat.com>,
        Eric Paris <eparis@redhat.com>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 2, 2013 at 1:43 PM, Jeff Layton <jlayton@redhat.com> wrote:
> Ok, took me a couple of times to look over the code but I think I
> understand the problem now...
>
> IIUC, then this patch should only ever cause this to return -ENOENT in
> a situation similar to the one in Anand's reproducer, right? The
> mountpoint-to-be was unlinked in another tree, and thus we found it to
> be invalid in the tree that we're mounting in. If so, then the dentry
> didn't exist at some point during the race window. Returning -ENOENT
> seems reasonable to me in that situation.

Yes, that's one part of it and ENOENT fits perfectly.

The other part is when the subtree is moved on another host.  Yes, NFS
can reconnect it, but only if it is accessed through the new location.
 Until then it will be inaccessible and the new location of the
mountpoint not discoverable through /proc/mounts or in any way without
outside knowledge.

And there was a pre-existing mount under the moved directory we don't
allow the d_drop in this "move" case either, and the mount is
accessible through the old name.  I seem to recall that there was a
discussion about this back then and Linus was quite adamant about
mountpoints not being allowed to be dissolved or moved without an
explicit action on the localhost (i.e. something that happens on
remote hosts shouldn't affect the status or location of mounts on the
localhost).

So what happens in this case:

host1: cd /nfs/foo/bar
host2: mv /nfs/foo /nfs/old-foo
host2: mkdir /nfs/foo
host1: ls /nfs/foo  [drops "old-foo" and adds a new foo dentry]
host1: mkdir bin [cwd is now not accessible from root]
host1: mount --bind /bin ./bin [???]

Currently that last one succeeds, with my patch it gives ENOENT, but
that's not the best error, since the mountpoint does exist.

Thanks,
Miklos
