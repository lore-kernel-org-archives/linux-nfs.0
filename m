Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868Ab2BWQwI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Feb 2012 11:52:08 -0500
Date: Thu, 23 Feb 2012 11:52:06 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Louie <snikrep@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: v4recovery client id lockup
Message-ID: <20120223115206.662b325c@redhat.com>
In-Reply-To: <CAMgFM3CXWEXqo+Nr1tt6XS6XrhJVfW9a5Dx=iSACriCOxfXjkw@mail.gmail.com>
References: <CAMgFM3CXWEXqo+Nr1tt6XS6XrhJVfW9a5Dx=iSACriCOxfXjkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 22 Feb 2012 17:06:49 -0800
Louie <snikrep@gmail.com> wrote:

> We have a weird, intermittent issue with NFS that I've been trying to
> track down for the past 6 months. This is on NFS v4, mounted over SSH,
> with Centos 6.2 as client/server.
> 
> Periodically, when running a client-side command that reads a large amount of
> files (e.g. converting 2000 small picture files to another format over
> NFS), our server will completely lock up for a period of time. ATOP
> shows 50-90% IO activity on the sda drive (root system, but not the
> shared NFS area where the files are actually located).
> 
> I've finally tracked down the activity to the
> /var/lib/nfs/v4recovery directory. One of the client ID directories
> gets created/deleted over and over again (same name each time) -
> enough to completely lock up the system. If I sit on the directory
> while this is happening and do "ls" commands over and over, you can
> see it disappear and appear ("ls -i" shows new inode numbers).
> 
> The strange thing is that this is periodic, and if you simply
> kill the client process and restart, everything often works smoothly. The
> actual server IO activity seems to be coming from the journal (what
> appears in iostat), but it's only writing/rewriting the empty client
> ID directories (the size of the activity shows 0.0 kb/s).
> 
> I've searched everywhere for info on this directory and trying to
> debug this stuff in general and come up empty, sorry if this has been
> covered before.
> 
> Appreciate ANY help, this has been driving me completely crazy.

Those directories are for the server to tell what clients are allowed
to reclaim locks or not. There are some problems that can occur when
there are server reboots in conjunction with a network partition
between server and client. See section 8.6.3 in RFC3530 if you're
interested in the gory details...

In any case, nfsd tracks some info in that directory in order to deal
with those cases. It's certainly possible there is a bug in that code
though. I fixed a few subtle bugs in that code recently, with this
patchset which I've proposed for 3.4:

    [PATCH v6 0/5] nfsd: overhaul the client name tracking code

...but none that sound similar to what you're seeing. Still, you may
want to play with that and see whether it helps this case at all. You
won't need the userspace pieces if you're still using the legacy client
tracking code.

-- 
Jeff Layton <jlayton@redhat.com>
