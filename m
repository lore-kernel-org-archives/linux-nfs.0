Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36884 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdKKCcg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 21:32:36 -0500
Date: Sat, 11 Nov 2017 02:32:27 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
Message-ID: <20171111023227.GI21978@ZenIV.linux.org.uk>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk>
 <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
 <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
 <CA+55aFx63wq=qN0+P+S-aahq7HzvYLi1tSxhPT9x78E8BrMNGQ@mail.gmail.com>
 <67939ef3-29c6-762c-7afe-46cc69630d95@gentoo.org>
 <20171111011306.GA30259@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171111011306.GA30259@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 10, 2017 at 08:13:06PM -0500, J. Bruce Fields wrote:
> On Fri, Nov 10, 2017 at 03:26:27PM -0800, Patrick McLean wrote:
> > 
> > 
> > On 2017-11-10 10:42 AM, Linus Torvalds wrote:
> > > On Thu, Nov 9, 2017 at 5:58 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
> > >>
> > >> Something must have changed since 4.13.8 to trigger this though.
> > > 
> > > Arnd pointed to some commits that might be relevant for the cp210x
> > > module, but those are all already in 4.13.8, so if 4.13.8 really is
> > > rock solid for you, I don't think that's it.
> > > 
> > > I really don't see anything that looks even half-way suspicious in
> > > that 4.13.8..11 range. But as mentioned, compiler interactions can be
> > > _really_ subtle.
> > > 
> > > And hey, it can be a real kernel bug too, that just happens to be
> > > exposed by RANDSTRUCT, so a bisect really would be very nice.
> > 
> > I am working on bisecting the issue now, but I think I have some more
> > evidence pointing to a compiler issue related to RANDSTRUCT. There are
> > actually 3 issues that we have seen. Sometimes we get the null pointer
> > deref in the initial message, sometimes we get the GPF, and sometimes we
> > see an issue where the NFS clients see all files as root-owned
> > directories.
> 
> That suggests that stat.uid is 0 and stat.mode & S_IFMT is 0040000 in
> the stat structure that nfsd passed to vfs_getattr().
> 
> No idea what sort of information is useful when tracking down this kind
> of bug, but you could also run wireshark and take a look at the server's
> GETATTR replies to see if there's some other corruption.

FWIW, having looked at some of the __bugger_layout users...  Compiler bugs
aside,
	* use in struct {dentry,inode,mount,block_device} has to go - cache
use patterns at hash lookups are _not_ something to play with like that.
	* struct file_lock and struct super_block - ditto, only it's not
hash lookups that hurt here.  struct vm_area_struct, while we are at it.
	* struct group_info - Cthulhu's pus-leaking warts, what's the point
randomizing _that_?  No, really - here's the damn thing in all its glory:
struct group_info {
        atomic_t        usage;
        int             ngroups;
        kgid_t          gid[0];
} __randomize_layout;
I really hope that plugin does *not* try to move the ->gid[] anywhere...
Which leaves us a choice between putting ->usage first or second.  Sure,
every bit helps, but... even for security theatre that looks a bit too
pathetic.
	* struct vfsmount.  Wow.  All of log2(3!) bits.  Congratulations.
At least that's better than struct path.  Oh, wait - they'd done struct path
as well...

What the hell had they been doing?  Muscarine old-fashioned way?  Looks like
a mix of pointless and truly dangerous.  And then there are compiler bugs and
the charming effect on reproducibility...
