From: Ian Kent <raven@themaw.net>
Subject: Re: VFS: Busy inodes after unmount on 2 way SMP (fwd)
Date: Sat, 13 Sep 2003 22:21:58 +0800 (WST)
Sender: autofs-bounces@linux.kernel.org
Message-ID: <Pine.LNX.4.44.0309132220220.3585-100000@raven.themaw.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <autofs-bounces@linux.kernel.org>
To: Arun Sharma <arun.sharma@intel.com>,
   autofs mailing list <autofs@linux.kernel.org>, <nfs@lists.sourceforge.net>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>


Appologies, think I should have reply-all on this. Oops.

---------- Forwarded message ----------
Date: Sat, 13 Sep 2003 18:25:11 +0800 (WST)
From: Ian Kent <raven@themaw.net>
To: H. Peter Anvin <hpa@zytor.com>
Subject: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP

On Fri, 12 Sep 2003, H. Peter Anvin wrote:

> Arun Sharma wrote:
> > H. Peter Anvin wrote:
> > 
> >>
> >> Which version of autofs are you running?  What version of mount(8)?
> >>
> > 
> > autofs-3.1.7 and mount-2.11g
> > 
> >> It's possible NFS lets you umount a mount which has busy inodes under
> >> certain conditions.
> > 
> > 
> > Are you thinking of the MNT_FORCE flag ? I have reasons to believe that
> > it won't help. Mainly because if it was a RPC task that marked the inode
> > busy, it'd have put itself on the waitq of the inode. However I found
> > that waitqueue_active(&inode->i_wait) == 0.
> > 
> 
> No, I'm thinking about the possibility that there is a bug.
> 
> autofs depends critically on a filesystem *not* allowing itself to be
> unmounted when there are busy inodes; however, this is something that
> things other than autofs doesn't really stress a whole lot.

I've only ever seen the "busy inodes" message as a result of automount 
not exiting cleanly, leaving directories behind. autofs-4 has an annoying 
habit of exiting without cleaning up after itself under adverse 
conditions. I can't comment on autofs-3.

I believe I have made some progress in this area with the work that I have 
been doing on autofs-4. I hope to get something into beta soon.

The autofs-4.0.0 (4.0.0pre10 with a couple of my patches and couple of 
others) to be released soon is likely to have the same problem.

-- 

   ,-._|\    Ian Kent
  /      \   Perth, Western Australia
  *_.--._/   E-mail: raven@themaw.net
        v    Web: http://themaw.net/
