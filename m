From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC:PATCH] How best to handle implicit clearing of
	setuid/setgid bits on NFS?
Date: Thu, 28 Jun 2007 09:38:22 -0400
Message-ID: <1183037902.6163.29.camel@heimdal.trondhjem.org>
References: <20070529124705.a1e70735.jlayton@redhat.com>
	 <1182982555.5311.67.camel@heimdal.trondhjem.org>
	 <20070627221354.02233c58.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
	aviro@redhat.com, nhorman@tuxdriver.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070627221354.02233c58.jlayton@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2007-06-27 at 22:13 -0400, Jeff Layton wrote:
> Ok. This is a bit more complex now since we remove suid bits on
> truncate, but don't set ATTR_FORCE.
> 
> Here's a patch that should do this. I know there's a general
> aversion to adding new flags to vfs structures, but I couldn't think of
> a way to cleanly do this without adding one.
> 
> Note that I've not tested this patch at all so this is just a RFC.
> 
> CC'ing Al here since he's expressed interest in this problem as well.
> 
> Thoughts?

We don't really need to do this with extra VFS flags. Here is my
preferred approach for dealing with this problem.

        http://article.gmane.org/gmane.linux.nfs/8511/match=attr%5fkill%5fsuid

As you can see, that still allows the filesystem to determine how it
should deal with the ATTR_KILL_SUID/ATTR_KILL_SGID flags. The default
behaviour is provided by inode_setattr(), and is the same as today. Only
filesystems that don't use inode_setattr() will need to be audited for
whether or not they need a fix.

Cheers,
  Trond

