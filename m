From: Greg Banks <gnb@sgi.com>
Subject: Re: [NFS] [PATCH 2/7] NFS: if ATTR_KILL_S*ID bits are set, then skip mode change
Date: Fri, 14 Sep 2007 20:25:45 +1000
Message-ID: <20070914102545.GF21965@sgi.com>
References: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org,
	ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <reiserfs-devel-owner@vger.kernel.org>
In-Reply-To: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
Sender: reiserfs-devel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Sep 04, 2007 at 10:37:04AM -0400, Jeff Layton wrote:
> If the ATTR_KILL_S*ID bits are set then any mode change is only for
> clearing the setuid/setgid bits. For NFS skip the mode change and
> let the server handle it.

You're assuming the server will remove setuid and setgid bits on WRITE?
I don't see that behaviour specified in the RFC, at least for v3.
The RFC specifies a behaviour for the mtime attribute as a side
effect of WRITE, but says nothing about mode.  This means server
implementations are free to clobber setuid or not.  A quick experiment
shows that at least the Irix server will *NOT* clobber those bits.
So with an Irix server you've now lost this Linux-specific "security
feature".

I'm curious about the reasons behind this change.  You mention
credential issues; how exactly is it that you have the correct creds
to perform a WRITE rpc but not a SETATTR rpc?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.
