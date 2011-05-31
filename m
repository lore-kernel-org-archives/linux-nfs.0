Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:40777 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757840Ab1EaRHm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 13:07:42 -0400
Message-ID: <4DE5205C.5020209@itwm.fraunhofer.de>
Date: Tue, 31 May 2011 19:07:40 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
To: "Ted Ts'o" <tytso@mit.edu>
CC: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: infinite getdents64 loop
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org> <201105311147.24939.sweet_f_a@gmx.de> <4DE4C063.9060100@itwm.fraunhofer.de> <20110531123518.GB4215@thunk.org>
In-Reply-To: <20110531123518.GB4215@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/31/2011 02:35 PM, Ted Ts'o wrote:
> On Tue, May 31, 2011 at 12:18:11PM +0200, Bernd Schubert wrote:
>>
>> Out of interest, did anyone ever benchmark if dirindex provides any
>> advantages to readdir?  And did those benchmarks include the
>> disadvantages of the present implementation (non-linear inode
>> numbers from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
>> 'rm -fr $dir')?
>
> The problem is that seekdir/telldir is terminally broken (and so is
> NFSv2 for using a such a tiny cookie) in that it fundamentally assumes
> a linear data structure.  If you're going to use any kind of
> tree-based data structure, a 32-bit "offset" for seekdir/telldir just
> doesn't cut it.  We actually play games where we memoize the low
> 32-bits of the hash and keep track of which cookies we hand out via
> seekdir/telldir so that things mostly work --- except for NFSv2, where
> with the 32-bit cookie, you're just hosed.

Well, lets just ignore NFSv2, for NFS there are better working v3 and v4 
alternatives. My real concern are ext3 and ext4, which have

#define pos2min_hash(pos)	(0)


>
> The reason why we have to iterate over the directory in hash tree
> order is because if we have a leaf node split, half the directories
> entries get copied to another directory entry, given the promises made
> by seekdir() and telldir() about directory entries appearing exactly
> once during a readdir() stream, even if you hold the fd open for weeks
> or days, mean that you really have to iterate over things in hash
> order.

Ah, I never looked into the dirindex implementation, I always thought 
the dirindex blocks get updated and not real directory entries as well.

>
> I'd have to look, since it's been too many years, but as I recall the
> problem was that there is a common path for NFSv2 and NFSv3/v4, so we
> don't know whether we can hand back a 32-bit cookie or a 64-bit
> cookie, so we're always handing the NFS server a 32-bit "offset", even
> though ew could do better.  Actually, if we had an interface where we
> could give you a 128-bit "offset" into the directory, we could
> probably eliminate the duplicate cookie problem entirely.  We just
> send 64-bits worth of hash, plus the first two bytes of the of file
> name.

Well, personally I'm more interested in user space, but I don't see any 
difference between NFS, other kernel paths and user space. I think this 
is used for everything:

	/* Some one has messed with f_pos; reset the world */
	if (info->last_pos != filp->f_pos) {
		free_rb_tree_fname(&info->root);
		info->curr_node = NULL;
		info->extra_fname = NULL;
		info->curr_hash = pos2maj_hash(filp->f_pos);
		info->curr_minor_hash = pos2min_hash(filp->f_pos);
	}


So with the above #define pos2min_hash(), info->curr_minor_hash is 
always zero with no exception. Or do I miss something?

>
>> 3) Disable dirindexing for readdirs
>
> That won't work, since it will break POSIX compliance.  Once again,
> we're tied by the decisions made decades ago...

I really wonder if we couldn't set a flag somewhere to ignore posix for 
applications that could handle it on their own. Pity that opendir 
doesn't allow to set flags. An ioctl would be another choice.


Thanks,
Bernd
