From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH 2/7] NFS: if ATTR_KILL_S*ID bits are set, then
	skip mode change
Date: Mon, 17 Sep 2007 09:10:47 -0400
Message-ID: <1190034647.6700.3.camel@heimdal.trondhjem.org>
References: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
	 <20070914102545.GF21965@sgi.com>
	 <20070914070258.8fccb40e.jlayton@redhat.com>
	 <20070914130924.GG21965@sgi.com>
	 <20070914093846.7cdd89da.jlayton@redhat.com>
	 <20070914144033.GD25610@sgi.com>
	 <20070914105838.efbfc45e.jlayton@redhat.com>
	 <20070914154345.GE25610@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Layton <jlayton@redhat.com>, reiserfs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, ecryptfs-devel@lists.sourceforge.net,
	nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
	unionfs@filesystems.org, linux-cifs-client@lists.samba.org
To: Greg Banks <gnb@sgi.com>
Return-path: <reiserfs-devel-owner@vger.kernel.org>
In-Reply-To: <20070914154345.GE25610@sgi.com>
Sender: reiserfs-devel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 2007-09-15 at 01:43 +1000, Greg Banks wrote:
> On Fri, Sep 14, 2007 at 10:58:38AM -0400, Jeff Layton wrote:
> > If Irix isn't clearing these bits
> > on a write then it might be good to see if they can fix that...
> 
> I think first you'd have to mount a serious argument that it's broken,
> more serious than "it works differently from Linux".

How about: "If IRIX isn't clearing these bits then they're leaving their
customers wide open to all sorts of security issues."

Unless you make the chmod/chgrp atomic with the write, then there will
always be a way for a client to inject data while the setuid/setgid bits
are set: basically, it allows said client to rewrite a setuid/setgid
executable.

We're not fixing this in the client because it isn't fixable on the
client.

Trond

