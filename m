From: Greg Banks <gnb@sgi.com>
Subject: Re: [NFS] [PATCH 2/7] NFS: if ATTR_KILL_S*ID bits are set, then skip mode change
Date: Sat, 15 Sep 2007 01:43:45 +1000
Message-ID: <20070914154345.GE25610@sgi.com>
References: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com> <20070914102545.GF21965@sgi.com> <20070914070258.8fccb40e.jlayton@redhat.com> <20070914130924.GG21965@sgi.com> <20070914093846.7cdd89da.jlayton@redhat.com> <20070914144033.GD25610@sgi.com> <20070914105838.efbfc45e.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: reiserfs-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	ecryptfs-devel@lists.sourceforge.net, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070914105838.efbfc45e.jlayton@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Sep 14, 2007 at 10:58:38AM -0400, Jeff Layton wrote:
> On Sat, 15 Sep 2007 00:40:33 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> 
> > Ok, you convinced me.
> 
> Right. When I was first looking at this, I considered some similar
> approaches, but hit roadblocks with all of them. The only real option
> seems to be to leave this to the server, but that does assume that the
> server handles this properly.
> 
> Servers that don't are broken, IMO.

According to what spec?  A quick trip around the machine room shows
that neither Solaris 10 nor Darwin 7.9.0 clobber setuid on write
either.

> If Irix isn't clearing these bits
> on a write then it might be good to see if they can fix that...

I think first you'd have to mount a serious argument that it's broken,
more serious than "it works differently from Linux".

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.
