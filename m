From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: O_NONBLOCK for regular files
Date: Wed, 13 Apr 2005 17:06:12 +1000
Message-ID: <1113375971.1956.634.camel@hole.melbourne.sgi.com>
References: <405C0DC0.3E61994@melbourne.sgi.com>
	 <1113353153.1956.481.camel@hole.melbourne.sgi.com>
	 <1113371790.9903.3.camel@lade.trondhjem.org>
	 <1113372223.1956.628.camel@hole.melbourne.sgi.com>
	 <1113373891.9903.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Filesystem Development List <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1113373891.9903.7.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2005-04-13 at 16:31, Trond Myklebust wrote:
> on den 13.04.2005 Klokka 16:03 (+1000) skreiv Greg Banks:
> 
> > Any other issues?
> > 
> > Greg.
> 
> Well, I'm sa bit curious as to what "iap->ia_valid |= ATTR_NO_BLOCK"
> will do. AFAICS, there is nothing that actually tests for it.

fs/xfs/linux-2.6/xfs_iops.c:linvfs_setattr() does

    535 #ifdef ATTR_NO_BLOCK
    536         if ((ia_valid & ATTR_NO_BLOCK))
    537                 flags |= ATTR_NONBLOCK;
    538 #endif

and later ATTR_NONBLOCK is used to change the behaviour of
DMAPI callouts from XFS.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


