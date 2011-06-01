Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756084Ab1FAQQR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 12:16:17 -0400
Subject: Re: infinite getdents64 loop
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "Ted Ts'o" <tytso@mit.edu>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org
Date: Wed, 01 Jun 2011 12:15:59 -0400
In-Reply-To: <4DE63A42.4090102@panasas.com>
References: <201105281502.32719.sweet_f_a@gmx.de>
	 <201105301137.02061.sweet_f_a@gmx.de>
	 <1306767521.5971.2.camel@lade.trondhjem.org>
	 <201105311147.24939.sweet_f_a@gmx.de> <4DE4C063.9060100@itwm.fraunhofer.de>
	 <20110531123518.GB4215@thunk.org> <4DE521B9.5050603@panasas.com>
	 <4DE525AE.9030806@itwm.fraunhofer.de> <4DE63A42.4090102@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306944959.3873.18.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-01 at 16:10 +0300, Boaz Harrosh wrote: 
> On 05/31/2011 08:30 PM, Bernd Schubert wrote:
> > On 05/31/2011 07:13 PM, Boaz Harrosh wrote:
> >> On 05/31/2011 03:35 PM, Ted Ts'o wrote:
> >>> On Tue, May 31, 2011 at 12:18:11PM +0200, Bernd Schubert wrote:
> >>>>
> >>>> Out of interest, did anyone ever benchmark if dirindex provides any
> >>>> advantages to readdir?  And did those benchmarks include the
> >>>> disadvantages of the present implementation (non-linear inode
> >>>> numbers from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
> >>>> 'rm -fr $dir')?
> >>>
> >>> The problem is that seekdir/telldir is terminally broken (and so is
> >>> NFSv2 for using a such a tiny cookie) in that it fundamentally assumes
> >>> a linear data structure.  If you're going to use any kind of
> >>> tree-based data structure, a 32-bit "offset" for seekdir/telldir just
> >>> doesn't cut it.  We actually play games where we memoize the low
> >>> 32-bits of the hash and keep track of which cookies we hand out via
> >>> seekdir/telldir so that things mostly work --- except for NFSv2, where
> >>> with the 32-bit cookie, you're just hosed.
> >>>
> >>> The reason why we have to iterate over the directory in hash tree
> >>> order is because if we have a leaf node split, half the directories
> >>> entries get copied to another directory entry, given the promises made
> >>> by seekdir() and telldir() about directory entries appearing exactly
> >>> once during a readdir() stream, even if you hold the fd open for weeks
> >>> or days, mean that you really have to iterate over things in hash
> >>> order.
> >>
> >> open fd means that it does not survive a server reboot. Why don't you
> >> keep an array per open fd, and hand out the array index. In the array
> >> you can keep a pointer to any info you want to keep. (that's the meaning of
> >> a cookie)
> > 
> > An array can take lots of memory for a large directory, of course. Do we 
> > really want to do that in kernel space? Although I wouldn't have a 
> > problem to reserve a certain amount of memory for that. But what do we 
> > do if that gets exhausted (for example directory too large or several 
> > open filedescriptors)?
> 
> You miss understood me. Ted was complaining that the cookie was only 32
> bit and he hoped it was bigger, perhaps 128 minimum. What I said is that
> for each open fd, a cookie is returned that denotes a temporary space
> allocated for just that caller. When a second call with the same fd, same
> cookie comes, the allocated object is inspected to retrieve all the
> information needed to continue the walk from the same place. So the allocated
> space is only per active caller, up to the time fd is closed.
> (I never meant per directory entry)
> 
> > And how does that help with NFS and other cluster filesystems where the 
> > client passes over the cookie? We ignore posix compliance then?
> > 
> 
> I was not referring to that. I understand that this is an hard problem
> but it is solvable. The space per cookie is solved above.

No. The above does not help in the case of NFS. The NFS protocol pretty
much assumes that the cookies are valid forever (there is no "open
directory" state to tell the server when to cache and when not).

There is a half-arsed attempt to deal with cookies that expire in the
form of the 'verifier', which changes when the cookies expire. When this
happens, the client is indeed notified that its cookies are no longer
usable, but the protocol offers no guidance for how the client can
recover from such a situation if some process still holds an open
directory descriptor.
In practice, therefore, the NFS protocol assumes permanent cookies...

My $.02 on this problem is therefore that we need some guidance from the
application as to whether or not it can deal with 64-bit cookies (or
larger). Something like Andreas' suggestion might work, and would allow
us to fix 'telldir()' for userland too.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

