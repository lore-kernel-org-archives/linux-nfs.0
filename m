From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: htree+NFS (NFS client bug?)
Date: 27 Nov 2002 21:42:14 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shsfztmeod5.fsf@charged.uio.no>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
	<20021127133318.GA8117@think.thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Ext2 devel <ext2-devel@lists.sourceforge.net>,
	NFS maillist <nfs@lists.sourceforge.net>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Theodore Ts'o <tytso@mit.edu>
In-Reply-To: <20021127133318.GA8117@think.thunk.org>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Theodore Ts'o <tytso@mit.edu> writes:

     > Well, even if the NFS server is generating bad cookies (and
     > that may be possible), the NFS client should be more robust and
     > not spin in a loop forever.

No. In this case, the problem appears to be that the cookie issued by
the server for the end of directory case is not unique.

If userland calls an extra 'readdir()' after EOF is reached, then as
far as the client is concerned, this sort of thing cannot be
distinguished from readdir()+seekdir()+readdir()..

Cheers,
  Trond
