From: Olivier Galibert <galibert@pobox.com>
Subject: Re: [NFS] Re: Irix NFS server usual problem [patch, fc3 2.6.10-1,760_FC3]
Date: Thu, 10 Feb 2005 17:43:28 +0100
Message-ID: <20050210164328.GA5267@dspnet.fr.eu.org>
References: <20050207221638.GA18723@dspnet.fr.eu.org> <1107816524.9970.8.camel@lade.trondhjem.org> <20050210124832.GA23320@dspnet.fr.eu.org> <1108048844.9840.55.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Hack inc." <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1108048844.9840.55.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Feb 10, 2005 at 10:20:44AM -0500, Trond Myklebust wrote:
> A permanent fix probably ought to involve removing our current
> dependency on using the server-generated readdir cookies as
> telldir/seekdir offsets.

Remplacing it by?  As in, I'm ready to do and test the code if I have
a decent idea of what would be acceptable.

  OG.
