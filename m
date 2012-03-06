Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:52342 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932461Ab2CFC2n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 21:28:43 -0500
Date: Mon, 5 Mar 2012 21:28:38 -0500
From: "Ted Ts'o" <tytso@mit.edu>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, sandeen@redhat.com,
        Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to
 usage type
Message-ID: <20120306022838.GA24323@thunk.org>
References: <20120109132137.2616029.76288.stgit@localhost.localdomain>
 <20120109132148.2616029.68798.stgit@localhost.localdomain>
 <20120305155939.GE21356@thunk.org>
 <4F555CE5.7050401@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F555CE5.7050401@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 06, 2012 at 01:40:05AM +0100, Bernd Schubert wrote:
> 
> Yeah, you are right, we also should check for 64-bit EOF. But
> wouldn't be something like this be better?
> 
> 	/* check for hash collision */
> 	if(is_32bit_api() ) {
> 		if (hash == (EXT4_HTREE_EOF_32BIT<<  1))
> 			hash = (EXT4_HTREE_EOF_32BIT - 1)<<  1;
> 	} else {
> 		if (hash == (EXT4_HTREE_EOF_64BIT<<  1))
> 			hash = (EXT4_HTREE_EOF_64BIT - 1)<<  1;
> 	}

Actually, neither change is needed, now that I look at things more
closely.  hash is a __u32, so it could never been
EXT4_HTREE_EOF_64BIT.  But given that we won't let major hash become
larger than 0xfffffffc, that means the largest possible position value
is 0x7ffffffeffffffff.  So using an EOF value of 0x0x7fffffffffffffff
will work fine.

The bigger problem that I found when I looked more closely at the
patch is that the patch uses f_flags in places where f_mode needs to
be used:

static inline loff_t hash2pos(struct file *filp, __u32 major, __u32 minor)
{
	if ((filp->f_flags & FMODE_32BITHASH) ||
                   ^^^^^^^
	    (!(filp->f_flags & FMODE_64BITHASH) && is_32bit_api()))
                     ^^^^^^^
		return major >> 1;
	else
		return ((__u64)(major >> 1) << 32) | (__u64)minor;
}

static inline __u32 pos2maj_hash(struct file *filp, loff_t pos)
{
	if ((filp->f_flags & FMODE_32BITHASH) ||
                   ^^^^^^
	    (!(filp->f_mode & FMODE_64BITHASH) && is_32bit_api()))
                     ^^^^^^
		return (pos << 1) & 0xffffffff;
	else
		return ((pos >> 32) << 1) & 0xffffffff;
}

Which makes me wonder how much this has been tested?

      	       	      	       	    	     - Ted
