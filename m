Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:48199 "EHLO
	imap.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965011Ab3BMWr1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 17:47:27 -0500
Date: Wed, 13 Feb 2013 17:47:20 -0500
From: "Theodore Ts'o" <tytso@mit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anand Avati <anand.avati@gmail.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>, sandeen@redhat.com,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130213224720.GE5938@thunk.org>
References: <20130212202841.GC10267@fieldses.org>
 <20130213040003.GB2614@thunk.org>
 <20130213133131.GE14195@fieldses.org>
 <20130213151455.GB17431@thunk.org>
 <20130213151953.GJ14195@fieldses.org>
 <20130213153654.GC17431@thunk.org>
 <20130213162059.GL14195@fieldses.org>
 <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
 <20130213222052.GD5938@thunk.org>
 <20130213224141.GU14195@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130213224141.GU14195@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 05:41:41PM -0500, J. Bruce Fields wrote:
> > What if we have an ioctl or a process personality flag where a broken
> > application can tell the file system "I'm broken, please give me a
> > degraded telldir/seekdir cookie"?  That way we don't penalize programs
> > that are doing the right thing, while providing some accomodation for
> > programs who are abusing the telldir cookie.
> 
> Yeah, if there's a simple way to do that, maybe it would be worth it.

Doing this as an ioctl which gets called right after opendir, i.e
(ignoring error checking):

      DIR *dir = opendir("/foo/bar/baz");
      ioctl(dirfd(dir), EXT4_IOC_DEGRADED_READDIR, 1);
      ...

should be quite easy.  It would be a very ext3/4 specific thing,
though.

It would be more work to get something in as a process personality
flag, mostly due to the politics of assiging a bit out of the
bitfield.

						- Ted

