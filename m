Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39332 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab3BMWlp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 17:41:45 -0500
Date: Wed, 13 Feb 2013 17:41:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: Anand Avati <anand.avati@gmail.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>, sandeen@redhat.com,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130213224141.GU14195@fieldses.org>
References: <20130212202841.GC10267@fieldses.org>
 <20130213040003.GB2614@thunk.org>
 <20130213133131.GE14195@fieldses.org>
 <20130213151455.GB17431@thunk.org>
 <20130213151953.GJ14195@fieldses.org>
 <20130213153654.GC17431@thunk.org>
 <20130213162059.GL14195@fieldses.org>
 <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
 <20130213222052.GD5938@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130213222052.GD5938@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 05:20:52PM -0500, Theodore Ts'o wrote:
> On Wed, Feb 13, 2013 at 01:21:06PM -0800, Anand Avati wrote:
> > 
> > NFS uses the term cookies, while man pages of readdir/seekdir/telldir calls
> > them "offsets". 
> 
> Unfortunately, telldir and seekdir are part of the "unspeakable Unix
> design horrors" which has been with us for 25+ years.  To quote from
> the rationale section from the Single Unix Specification v3 (there is
> similar language in the Posix spec).
> 
>     The original standard developers perceived that there were
>     restrictions on the use of the seekdir() and telldir() functions
>     related to implementation details, and for that reason these
>     functions need not be supported on all POSIX-conforming
>     systems. They are required on implementations supporting the XSI
>     extension.
> 
>     One of the perceived problems of implementation is that returning
>     to a given point in a directory is quite difficult to describe
>     formally, in spite of its intuitive appeal, when systems that use
>     B-trees, hashing functions, or other similar mechanisms to order
>     their directories are considered. The definition of seekdir() and
>     telldir() does not specify whether, when using these interfaces, a
>     given directory entry will be seen at all, or more than once.
> 
>     On systems not supporting these functions, their capability can
>     sometimes be accomplished by saving a filename found by readdir()
>     and later using rewinddir() and a loop on readdir() to relocate
>     the position from which the filename was saved.
> 
> 
> Telldir() and seekdir() are basically implementation horrors for any
> file system that is using anything other than a simple array of
> directory entries ala the V7 Unix file system or the BSD FFS.  For any
> file system which is using a more advanced data structure, like
> b-trees hash trees, etc, there **can't** possibly be a "offset" into a
> readdir stream.  This is why ext3/ext4 uses a telldir cookie, and it's
> why the NFS specifications refer to it as a cookie.  If you are using
> a modern file system, it can't possibly be an offset.
> 
> > You can always say "this is your fault" for interpreting the man pages
> > differently and punish us by leaving things as they are (and unfortunately
> > a big chunk of users who want both ext4 and gluster jeapordized). Or you
> > can be kind, generous and be considerate to the legacy apps and users (of
> > which gluster is only a subset) and only provide a mount option to control
> > the large d_off behavior.
> 
> The problem is that we made this change to fix real problems that take
> place when you have hash collisions.  And if you are using a 31-bit
> cookie, the birthday paradox means that by the time you have a
> directory with 2**16 entries, the chances of hash collisions are very
> real.  This could result in NFS readdir getting stuck in loops where
> it constantly gets the file "foo.c", and then when it passes the
> 31-bit cookie for "bar.c", since there is a hash collision, it gets
> "foo.c" again, and the readdir never terminates.
> 
> So the problem is that you are effectively asking me to penalize
> well-behaved programs that don't try to steel bits from the top of the
> telldir cookie, just for the benefit of gluster.
> 
> What if we have an ioctl or a process personality flag where a broken
> application can tell the file system "I'm broken, please give me a
> degraded telldir/seekdir cookie"?  That way we don't penalize programs
> that are doing the right thing, while providing some accomodation for
> programs who are abusing the telldir cookie.

Yeah, if there's a simple way to do that, maybe it would be worth it.

--b.
