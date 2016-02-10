Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52878 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567AbcBJTeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Feb 2016 14:34:07 -0500
Date: Wed, 10 Feb 2016 14:34:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, lkml <linux-kernel@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Andreas Dilger <adilger@dilger.ca>
Subject: Re: richacl(7) man page review comments
Message-ID: <20160210193404.GA13989@fieldses.org>
References: <56B770B6.7040803@gmail.com>
 <56B77262.7090107@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56B77262.7090107@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 07, 2016 at 05:35:46PM +0100, Michael Kerrisk (man-pages) wrote:
> > This permission is always implicitly granted.
> > .HP
> > .B write_attributes
> > .RB ( A ):
> > Change the times associated with a file or directory to an arbitrary value.
> > This permission is always implicitly granted to the file owner.
> > .HP
> > .B read_acl
> > .RB ( c ):
> > Read the ACL of a file or directory. This permission is always
> > implicitly granted.
> > .HP
> > .B write_acl
> > .RB ( C ):
> > Change the ACL or file mode of a file or directory.
> > .HP
> > .B write_owner
> > .RB ( o ):
> > Take ownership of a file or directory.  Change the owning group of a file or
> > directory to a group of which the calling process is a member.
> > .HP
> > .B read_named_attrs
> > .RB ( R ),
> > .B write_named_attrs
> > .RB ( W ),
> > .B synchronize
> > .RB ( S ),
> > .B write_retention
> > .RB ( e ),
> > .B write_retention_hold
> > .RB ( E ):
> > These permissions can be stored, but do not have a local meaning.
> 
> So, I thenk that a sentence here should explain why these permissions
> exist. Is if for future extension, because they are meaningful in NFS,
> or something else?

Yeah, "synchronize" is something only Windows clients care about, as I
understand it.  The others are for NFS features that nobody has tried to
implement yet.  It's useful to store those bits but they don't do
anything at this point.  We could provie FC references, I guess, but
it's probably not worth going into much detail about.

> > Automatic Inheritance allows permission changes to propagate from a directory
> > to files and subdirectories inside that directory, recursively.  Carrying out
> > this propagation of permissions is the responsibility of the process changing
> > the directory permissions (usually, setrichacl(1)).
> 
> I'm confused by the previous sentence. the feature is labeled "Automatic
> Inheritance", implying that the user/process need do nothing. The next
> sentence says "propagation ... is the responsibility of the process".
> These two points seem contradictory. I think something more needs to be
> said here.

Yeah, the "automatic" name is probably misleading, but I think we're
stuck with that name and just need to make the point a bit more
forcefully.

Userland utilities take responsibility for the actual recursive
propagation of changes, all the kernel does is provide a few bits which
help to do it correctly (e.g. to distinguish between ACEs that ewre
inherited inherited (and can be blown away by propagation) and those
that were added locally).

--b.
