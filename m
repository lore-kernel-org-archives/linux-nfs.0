Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:1793 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402Ab3JYXww (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 19:52:52 -0400
Date: Fri, 25 Oct 2013 19:52:34 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        linux-nfs@vger.kernel.org, Ric Wheeler <ricwheeler@gmail.com>,
        nfsv4 <nfsv4@ietf.org>
Message-ID: <1403457744.302.1382745154408.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <739187808.295.1382744200733.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: XATTRs in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

>From a standards perspective, could you please elaborate on how local xattrs are
"subtly incompatible" with NFSv4 named attributes?

It appears to me that the interesting issues (if any) are strictly related to possible lack of well-understood, or recommended, mappings of nfsv4 named attributes to and from whatever file attribute concept(s) exist on the client and server, not with the named attribute interface.

I did find slides in which James Morris asserts that "NFSv4 includes Named Attributes, which are based on the Solaris subfile model and incompatible with name/value schemes"
(http://www.slideshare.net/jamesmorris/adding-extended-attribute-support-to-nfs).
However, named attributes as actually specified in RFC 5661, at least, are not in fact a "fully general" subfile mechanism as found in Solaris.  The various restrictions in section 5.3 of RFC 5661 restrict implementations to a single-level namespace of attributes.  With the non-recursion restriction in place, nfsv4 named attributes appear to form a 1-to-1 mapping with Windows alternate data streams and Mac resource forks, and since nfsv4 named attribute data may be of arbitrary length, they also appear able to represent Linux or FreeBSD named attribute, should the an nfsv4 server on one of those platforms wish to do so.  (I presume that is by design.)

There seems to be a long history of mapping precursors of "posix" named attributes into alternate data streams (http://en.wikipedia.org/wiki/Extended_file_attributes#Windows_NT), and even the reverse (e.g., the ntfs3g file system driver for Linux, http://www.tuxera.com/community/ntfs-3g-advanced/extended-attributes/):

"""The extended attributes in user name space are stored on NTFS as alternate data streams whose name is the unprefixed name of the attribute, and whose contents is the value of the attribute. They can be read and modified in Windows by using the standard file access functions, with a colon and the stream name (which is the unprefixed extended attribute name) appended to the file name."""

Finally, we have existing implementation experience.  I'll leave out Solaris, and mention the Windows NFSv4.1 client.  The Windows client implements nfsv4 named attributes as a direct mapping to Windows fs alternate data streams.

Presumably, there could be other differences between a platform attribute
interface an NFSv4 named attributes, e.g., perhaps update atomicity.  It seems
though that any issues which might arise from this would also be ones the standard
could expect the client and/or server implementation to deal appropriately with.

Matt

----- "Chuck Lever" <chuck.lever@oracle.com> wrote:

> 
> NFS has to interoperate with other operating systems that may or may
> not support xattrs, or may have something that looks like an xattr,
> but really is subtly incompatible.
> 
> Therefore we must have a standard for storing and accessing xattrs
> locally (POSIX) and a standard for expressing their name and content
> on the wire (IETF NFS) before we can consider an implementation.
> 
> So we would like to see some very clear evidence that it's worth the
> effort.  Until then, Linux distributors are free to implement NFS
> xattr support outside the standard NFS protocol (like the Solaris
> NFSv3 ACL protocol) and support this themselves, perhaps as proof that
> "if you build it, they will come."
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
