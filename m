Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:52978 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125Ab0FUXVj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jun 2010 19:21:39 -0400
Date: Tue, 22 Jun 2010 09:21:05 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: Chuck Lever <chuck.lever@oracle.com>
cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
In-Reply-To: <4C1FC553.4030904@oracle.com>
Message-ID: <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org> <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org> <4C1FC553.4030904@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 21 Jun 2010, Chuck Lever wrote:

> >   /*
> > + * FIXME: currently, the RPC layer will allocate the maximum buffer size
> > + * here for each call (which can be ~ 64k).  The Labeled NFS prototype code
> > + * uses 4k, although we should not impose limits for NFS which don't exist
> > + * in the OS unless absolutely necsssary.  We likely need a dynamic scheme
> > + * here, possibly using pages.
> > + */
> 
> Encoding directly into RPC buffers is usually only for small objects, a few
> hundred bytes at most.  What are the challenges to using the page cache for
> these right now?  We already do that for symlinks and ACLs, right?

There's nothing stopping it -- the code just needs to be written that way.

> Is there a way the server can advertise a size limit for these objects,
> similar to rsize and wsize?

I guess we could add this, although most xattrs are quite small anyway, 
with upper limits defined by the OS (and then likely the same defined in 
the protocol).

> > +/*
> > + * Special case of xdr_encode_opaque, where the xattr helpers hand us
> > + * separate namespace and name buffers, which we encode as a single XDR
> > + * string over the wire.  Neither namespace nor name may be empty or null.
> > + */
> > +static __be32 *xattr_encode_name(__be32 *p, const char *namespace, const
> > char *name)
> 
> By convention this function would be called "xdr_encode_xattr_name()".

Ok.

> 
> Are these names going to be UTF-8 strings?

I believe so.

> > +#define NFS_XATTR_PROGRAM	391063	/* TODO: find another value */
> 
> RFC 5531, appendix B proscribes the appropriate method for requesting an RPC
> program number assignment.
> 
> Even though the NFSACL protocol doesn't have one, I have to agree with Deniel
> that we should have the RPCL definition of the on-the-wire protocol first, so
> we can review it and ensure our user space and kernel XDR functions remain
> consistent and correct over time.

Indeed, this is something I'm hoping to do soon.

>  Is there an RFC?

No, there have been several implementations, but never an RFC for xattrs.  

I'm using the XFS implementation as a starting point, and following the 
ACL model of implementing a side-protocol.

> Especially if we expect non-Linux implementations, I would think an
> IANA-assigned program number and a proper RPCL definition would be apriori
> requirements.

It's possible the FreeBSD folk may want to interop with this, as they have 
similar name/value xattrs.

(Btw, slides from a presentation I did on this last year at LinuxCon are 
at http://namei.org/presentations/linuxcon09_nfsv3xattrs.pdf)

Thanks for reviewing the code!


-- 
James Morris
<jmorris@namei.org>
