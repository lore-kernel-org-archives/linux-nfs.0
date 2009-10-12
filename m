From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Mon, 12 Oct 2009 18:55:58 -0400
Message-ID: <1255388158.3711.57.camel@heimdal.trondhjem.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
	 <4ACB5FC0.7060307@redhat.com>
	 <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>
	 <4AD36C82.8080904@redhat.com>
	 <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>
	 <4AD384BE.2090008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Haynes <tdh@excfb.com>, James Morris <jmorris@namei.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4AD384BE.2090008@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-10-12 at 15:34 -0400, Peter Staubach wrote:
> > So, is this a new side band protocol or an extension to NFSv3?
> > 
> 
> This is a side band protocol designed to allow the setting
> and getting of Linux style extended attributes.  They don't
> quite match the Solaris style sub-files approach, but I
> think could be implemented on top of the sub-files approach.

Sub-files are really a different kettle of fish, since they don't have
any side-effects on the main file itself.

xattrs are basically three different sets of objects bundled into one
set of syscall interfaces.

     1. There is a set of 'user' extended attributes, which are
        basically arbitrary length named strings. Anyone with read
        access to the file can read them, and anyone with write access
        can set them. Setting or clearing a user attribute has no
        side-effects on the parent file. The most common usage for these
        strings appears to be to annotate the file with search metadata
        (c.f. beagle)...
     2. There are a set of 'trusted' extended attributes. These are
        similar to user attributes, in that they have no side-effects,
        however you need to use a privileged process in order to set or
        read them.
     3. The 'system' and 'security' extended attributes are where all
        hell breaks loose. These provide storage for things like posix
        acls, and selinux security contexts. Setting or clearing these
        attributes will almost certainly have side-effects on the parent
        file itself, so you really want to be very careful with what you
        stuff into them.

> > Is there some document describing the problem being solved?
> > 
> 
> Not exactly, or at least, not that I've seen.  There is a need
> to support general Linux style extended attributes over NFSv3
> and NFSv4 prior to 4.2.  This will be used in the short term
> to solve some of the base issues that are being addressed by
> the Labeled NFS work currently underway in the IETF WG.  That
> work is much more extensive and designed to be a better
> solution, but we need something before that work will complete.
> 
> I am seeking to discover whether this will be a Linux to
> Linux only solution always or whether other vendors might be
> amenable to considering implementing this support.

I don't see how it can be anything but a Linux to Linux, single
distribution only solution if you support setting and clearing 'system'
and 'security' extended attributes, since there appears to be no method
outlined here for negotiating which features the client and server
support.
Without such negotiation (or the requirement that the client and server
be completely homogeneous), how do I, for instance, stop the
'restorecon' utility running on my client from breaking my mail server
process running on a completely different machine when it decides to
reset the 'security.selinux' label on my ~/mail folder?

Cheers,
  Trond

