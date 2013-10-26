Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751958Ab3JZFST (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Oct 2013 01:18:19 -0400
Date: Sat, 26 Oct 2013 01:18:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        linux-nfs@vger.kernel.org, Ric Wheeler <ricwheeler@gmail.com>,
        nfsv4 <nfsv4@ietf.org>
Subject: Re: XATTRs in NFS?
Message-ID: <20131026051815.GA10048@fieldses.org>
References: <739187808.295.1382744200733.JavaMail.root@thunderbeast.private.linuxbox.com>
 <1403457744.302.1382745154408.JavaMail.root@thunderbeast.private.linuxbox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403457744.302.1382745154408.JavaMail.root@thunderbeast.private.linuxbox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 25, 2013 at 07:52:34PM -0400, Matt W. Benjamin wrote:
> Hi Chuck,
> 
> >From a standards perspective, could you please elaborate on how local xattrs are
> "subtly incompatible" with NFSv4 named attributes?
> 
> It appears to me that the interesting issues (if any) are strictly related to possible lack of well-understood, or recommended, mappings of nfsv4 named attributes to and from whatever file attribute concept(s) exist on the client and server, not with the named attribute interface.
> 
> I did find slides in which James Morris asserts that "NFSv4 includes Named Attributes, which are based on the Solaris subfile model and incompatible with name/value schemes"
> (http://www.slideshare.net/jamesmorris/adding-extended-attribute-support-to-nfs).
> However, named attributes as actually specified in RFC 5661, at least, are not in fact a "fully general" subfile mechanism as found in Solaris.  The various restrictions in section 5.3 of RFC 5661 restrict implementations to a single-level namespace of attributes.  With the non-recursion restriction in place, nfsv4 named attributes appear to form a 1-to-1 mapping with Windows alternate data streams and Mac resource forks, and since nfsv4 named attribute data may be of arbitrary length, they also appear able to represent Linux or FreeBSD named attribute, should the an nfsv4 server on one of those platforms wish to do so.  (I presume that is by design.)
> 
> There seems to be a long history of mapping precursors of "posix" named attributes into alternate data streams (http://en.wikipedia.org/wiki/Extended_file_attributes#Windows_NT), and even the reverse (e.g., the ntfs3g file system driver for Linux, http://www.tuxera.com/community/ntfs-3g-advanced/extended-attributes/):
> 
> """The extended attributes in user name space are stored on NTFS as alternate data streams whose name is the unprefixed name of the attribute, and whose contents is the value of the attribute. They can be read and modified in Windows by using the standard file access functions, with a colon and the stream name (which is the unprefixed extended attribute name) appended to the file name."""
> 
> Finally, we have existing implementation experience.  I'll leave out Solaris, and mention the Windows NFSv4.1 client.  The Windows client implements nfsv4 named attributes as a direct mapping to Windows fs alternate data streams.
> 
> Presumably, there could be other differences between a platform attribute
> interface an NFSv4 named attributes, e.g., perhaps update atomicity.

Right, xattrs are expected to be small-ish and are set and queried
atomically.  A server that implements named attributes using xattrs has
to for example implement write as a read-modify-write of the attribute.
You normally only address xattrs by name, so I guess you'd have to stick
a hash of the name in the filehandle.

We could probably get *something* working, but I don't know whether the
semantics would be close enough to not break an application that was
written to a named-attribute api.

Personally what I'd like to see is a really thorough description of a
use case or two.  All I've ever heard is either "selinux", or some vague
ideas about things people think might be cool to try.

It seemed various Linux desktop projects (Beagle?) were using them for a
while, but I haven't noticed that happening lately.  Did they give up?

Looking at my machines at home....  A "find . -print0 | xargs -0
getfattr" doesn't find anything on my Fedora machines, but it does find
"user.xdg.origin.url" and "user.xdg.referrer.url" xattrs set on a few
downloads created by chromium on a Ubuntu desktop.  Those xattrs are
documented at

	http://freedesktop.org/wiki/CommonExtendedAttributes/

Can't see anyplace they're used, except that the file manager does have
a "user attributes" tab in the "properties" dialog that you can pull up
from a right-click.

The tool I use to keep my home directories in sync (unison) doesn't
appear to propagate those.

Ho-hum.

--b.

> It seems
> though that any issues which might arise from this would also be ones the standard
> could expect the client and/or server implementation to deal appropriately with.
> 
> Matt
> 
> ----- "Chuck Lever" <chuck.lever@oracle.com> wrote:
> 
> > 
> > NFS has to interoperate with other operating systems that may or may
> > not support xattrs, or may have something that looks like an xattr,
> > but really is subtly incompatible.
> > 
> > Therefore we must have a standard for storing and accessing xattrs
> > locally (POSIX) and a standard for expressing their name and content
> > on the wire (IETF NFS) before we can consider an implementation.
> > 
> > So we would like to see some very clear evidence that it's worth the
> > effort.  Until then, Linux distributors are free to implement NFS
> > xattr support outside the standard NFS protocol (like the Solaris
> > NFSv3 ACL protocol) and support this themselves, perhaps as proof that
> > "if you build it, they will come."
> > 
> > -- 
> > Chuck Lever
> > chuck[dot]lever[at]oracle[dot]com
> > 
> > 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Matt Benjamin
> The Linux Box
> 206 South Fifth Ave. Suite 150
> Ann Arbor, MI  48104
> 
> http://linuxbox.com
> 
> tel.  734-761-4689 
> fax.  734-769-8938 
> cel.  734-216-5309 
