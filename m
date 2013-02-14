Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46243 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934984Ab3BNVqn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2013 16:46:43 -0500
Date: Thu, 14 Feb 2013 16:46:38 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: Anand Avati <anand.avati@gmail.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>, sandeen@redhat.com,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130214214638.GB8343@fieldses.org>
References: <20130213151953.GJ14195@fieldses.org>
 <20130213153654.GC17431@thunk.org>
 <20130213162059.GL14195@fieldses.org>
 <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
 <20130213222052.GD5938@thunk.org>
 <20130213224141.GU14195@fieldses.org>
 <20130213224720.GE5938@thunk.org>
 <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
 <20130213230511.GW14195@fieldses.org>
 <20130213234430.GF5938@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130213234430.GF5938@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 06:44:30PM -0500, Theodore Ts'o wrote:
> On Wed, Feb 13, 2013 at 06:05:11PM -0500, J. Bruce Fields wrote:
> > 
> > Would it be possible to make something work like, for example, a 31-bit
> > hash plus an offset into a hash bucket?
> > 
> > I have trouble thinking about this, partly because I can't remember
> > where to find the requirements for readdir on concurrently modified
> > directories....
> 
> The requires are that for a directory entry which has not been
> modified since the last opendir() or rewindir(), readdir() must return
> that directory entry exactly once.
> 
> For a directory entry which has been added or removed since the last
> opendir() or rewinddir() call, it is undefined whether the directory
> entry is returned once or not at all.  And a rename is defined as a
> add/remove, so it's OK for the old filename and the new file name to
> appear in the readdir() stream; it would also be OK if neither
> appeared in the readdir() stream.

That's what I couldn't remember, thanks!

--b.

> 
> The SUSv3 definition of readdir() can be found here:
> 
>    http://pubs.opengroup.org/onlinepubs/009695399/functions/readdir.html
> 
> Note also that if you look at the SuSv3 definition of seekdir(), it
> explicitly states that the value returned by telldir() is not
> guaranteed to be valid after a rewinddir() or across another opendir():
> 
>    If the value of loc was not obtained from an earlier call to
>    telldir(), or if a call to rewinddir() occurred between the call to
>    telldir() and the call to seekdir(), the results of subsequent
>    calls to readdir() are unspecified.
> 
> Hence, it would be legal, and arguably more correct, if we created an
> internal array of pointers into the directory structure, where the
> first call to telldir() return 1, and the second call to telldir()
> returned 2, and the third call to telldir() returned 3, regardless of
> the position in the directory, and this number was used by seekdir()
> to index into the array of pointers to return the exact location in
> the b-tree.  This would completely eliminate the possibility of hash
> collisions, and guarantee that readdir() would never drop or return a
> directory entry multiple times after seekdir().
> 
> This implementation approach would have a potential denial of service
> potential since each call to telldir() would potentially be allocating
> kernel memory, but as long as we make sure the OOM killler kills the
> nasty process which is calling telldir() a lot, this would probably be
> OK.
> 
> It would also be legal to throw away this array after a call to
> rewinddir() and closedir(), since telldir() cookies and not guaranteed
> to valid indefinitely.  See:
> 
>    http://pubs.opengroup.org/onlinepubs/009695399/functions/seekdir.html
> 
> I suspect this would seriously screw over Gluster, though, and this
> wouldn't be a solution for NFSv3, since NFS needs long-lived directory
> cookies, and not the short-lived cookies which is all POSIX/SuSv3 guarantees.
> 
> Regards,
> 
> 					- Ted
> 
