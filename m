From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC PATCH 0/2] Add VFS support for looking up paths on remote
 servers using a temporary mount namespace
Date: Tue, 10 Feb 2009 13:31:48 -0500
Message-ID: <1234290708.7423.72.camel@heimdal.trondhjem.org>
References: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org>
	 <20090210155820.GB29075@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090210155820.GB29075@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-02-10 at 10:58 -0500, J. Bruce Fields wrote:
> On Mon, Feb 09, 2009 at 01:45:34PM -0500, Trond Myklebust wrote:
> > The following two patches attempt to improve NFSv4's ability to look up
> > the mount path on a remote server.
> > 
> > The first patch adds VFS support for walking the remote path, using a
> > temporary mount namespace to represent the server's namespace, so that
> > symlinks
> 
> I'm a bit confused about the symlink case--I take it you're assuming
> that symlinks in the pseudofs should be interpreted as relative to the
> server's namespace (in keeping with traditional implementations of
> server exports), while symlinks elsewhere should continue to be
> intepreted relative to the client's namespace.
> 
> Do the rfc's say anything about this?

No, the RFCs say nothing, but interpreting symlinks as being relative to
the server namespace would be consistent with the mount behaviour of
NFSv2/v3. It also makes me uncomfortable to have a remote mount path
that could refer back to the client's namespace: that would not be an
NFS mount, but a local bind mount...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
