From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 0/4] Optimize NFS open() calls by means of 'intents'...
Date: Mon, 30 Jun 2003 16:36:24 +0200
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <16128.19176.804116.866980@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
List-ID: <nfs.lists.sourceforge.net>

The following patches add the concept of 'intents' to the VFS layer,
and are subsequently used to optimize the NFSv2/v3 close-to-open code,
and to add O_EXCL support.
                                                                                
Intents are a concept which have been pioneered under Linux by Peter
Braam. They are an optional field that is passed down to inode ops and
are used in order to pass down extra information to the filesystem
about the nature of the operation being undertaken.
 
This allows the filesystem in turn to make assumptions in order to
optimize away unnecessary operations (for instance under NFS - doing
both a LOOKUP and a GETATTR when doing an open), and to choose
variants that improve the atomicity (For instance under NFSv4 you
may choose to OPEN rather than LOOKUP).

So far, I have only implemented OPEN intents. In the future, it may
prove to be useful to add intents for other operations (I know the
Lustre project in particular is keen to do this) in order to optimize
away unnecessary file permission checks, and other such things.
 
The patches presented now differ from those presented in May in that
I've tried to take into account both Linus' and Al Viro's comments.
The strategy is therefore to make use of the 'struct nameidata',
when it exists, and feed that down to the filesystem. The actual
intent information is then included as a union in the nameidata.
 
Cheers,
  Trond
