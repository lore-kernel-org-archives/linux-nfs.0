From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Re: Irix NFS server usual problem [patch, fc3
	2.6.10-1,760_FC3]
Date: Thu, 10 Feb 2005 10:20:44 -0500
Message-ID: <1108048844.9840.55.camel@lade.trondhjem.org>
References: <20050207221638.GA18723@dspnet.fr.eu.org>
	 <1107816524.9970.8.camel@lade.trondhjem.org>
	 <20050210124832.GA23320@dspnet.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Hack inc." <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Olivier Galibert <galibert@pobox.com>
In-Reply-To: <20050210124832.GA23320@dspnet.fr.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

to den 10.02.2005 Klokka 13:48 (+0100) skreiv Olivier Galibert:

> If the patch looks like it's going to be accepted, I'll send the
> (trivial) mount changes to whoever the util-linux maintainer is.  And
> does someone happens to know who maintains the mount/nfs options man
> page?

No. No more hacks and/or mount options for legacy issues in the mainline
NFS client please: there are already too many of them in there.

A permanent fix probably ought to involve removing our current
dependency on using the server-generated readdir cookies as
telldir/seekdir offsets.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>
