Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:34296 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab2CFKAA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2012 05:00:00 -0500
Message-ID: <4F55E01B.3060105@itwm.fraunhofer.de>
Date: Tue, 06 Mar 2012 10:59:55 +0100
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: "Ted Ts'o" <tytso@mit.edu>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, sandeen@redhat.com,
        Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to usage
 type
References: <20120109132137.2616029.76288.stgit@localhost.localdomain> <20120109132148.2616029.68798.stgit@localhost.localdomain> <20120305155939.GE21356@thunk.org> <4F555CE5.7050401@itwm.fraunhofer.de> <20120306022838.GA24323@thunk.org>
In-Reply-To: <20120306022838.GA24323@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/06/2012 03:28 AM, Ted Ts'o wrote:
> On Tue, Mar 06, 2012 at 01:40:05AM +0100, Bernd Schubert wrote:
>>
>> Yeah, you are right, we also should check for 64-bit EOF. But
>> wouldn't be something like this be better?
>>
>> 	/* check for hash collision */
>> 	if(is_32bit_api() ) {
>> 		if (hash == (EXT4_HTREE_EOF_32BIT<<   1))
>> 			hash = (EXT4_HTREE_EOF_32BIT - 1)<<   1;
>> 	} else {
>> 		if (hash == (EXT4_HTREE_EOF_64BIT<<   1))
>> 			hash = (EXT4_HTREE_EOF_64BIT - 1)<<   1;
>> 	}
>
> Actually, neither change is needed, now that I look at things more
> closely.  hash is a __u32, so it could never been
> EXT4_HTREE_EOF_64BIT.  But given that we won't let major hash become
> larger than 0xfffffffc, that means the largest possible position value
> is 0x7ffffffeffffffff.  So using an EOF value of 0x0x7fffffffffffffff
> will work fine.

Ah, I looked after 1 a.m., seems that was too late for me to notice.

>
> The bigger problem that I found when I looked more closely at the
> patch is that the patch uses f_flags in places where f_mode needs to
> be used:
>
> static inline loff_t hash2pos(struct file *filp, __u32 major, __u32 minor)
> {
> 	if ((filp->f_flags&  FMODE_32BITHASH) ||
>                     ^^^^^^^
> 	    (!(filp->f_flags&  FMODE_64BITHASH)&&  is_32bit_api()))
>                       ^^^^^^^
> 		return major>>  1;
> 	else
> 		return ((__u64)(major>>  1)<<  32) | (__u64)minor;
> }
>
> static inline __u32 pos2maj_hash(struct file *filp, loff_t pos)
> {
> 	if ((filp->f_flags&  FMODE_32BITHASH) ||
>                     ^^^^^^
> 	    (!(filp->f_mode&  FMODE_64BITHASH)&&  is_32bit_api()))
>                       ^^^^^^
> 		return (pos<<  1)&  0xffffffff;
> 	else
> 		return ((pos>>  32)<<  1)&  0xffffffff;
> }
>
> Which makes me wonder how much this has been tested?

Arg, my bad, I introduced this issue when I converted from f_flags to 
f_mode, seems I forgot all of those above :(
Hrm, I thought I had tested sufficiently, but obviously I did not :( 
Here's the test tool.
http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/test_seekdir/

While quickly looking, I think it only affects NFSv2, which I think I 
indeed didn't test. I only run tests for 32 bit and 64-bit user space 
and NFSv3. But yes, NFSv2 is an important test too. Not sure if I will 
find time for that today.

Will send an updated version later on.


Thanks for your review,
Bernd
