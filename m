Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Wed, 12 Aug 2009 10:20:41 -0400
To: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
Message-ID: <20090812142041.GA12753@fieldses.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
	<20090812024341.GA3227@fieldses.org>
	<x49ab25w4ja.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49ab25w4ja.fsf@segfault.boston.devel.redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 12, 2009 at 09:22:17AM -0400, Jeff Moyer wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> > On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
> >> I squashed the previous set of 4 incremental patches into 3. Otherwise
> >> there should be no differences w.r.t. the set that Jeff tested.
> >
> > Apologies for the long delay.... Unfortunately, I can't reproduce any of
> > this at all: I reliably get about 112MB/s regardless of what combination
> > of these patches I apply (including none).  This is over gigabit
> > ethernet to a server exporting a filesystem on raid 0 over 3 sata disks
> > which iozone locally reports getting just over 200MB/s reads from.
> >
> > Any suggestions?
> 
> Well, you gave me nothing to go on here, Bruce!

Apologies for the lack of details....

> I assume you're using
> the deadline I/O scheduler on the NFS server, is that right?  If not,
> you should be.

Oops, sorry, no. Looks like it doesn't allow setting a scheduler on md0,
so I'm assuming I should be setting it on the component drives.

> Second, are you using iozone to reproduce?
> 
>   iozone -s 2000000 -r 64 -f /mnt/test/testfile -i 1 -w

Yes, I was using your commandline.

> That's the command line I was using.  Third, I reproduced this on
> 2.6.30-rc1.  Perhaps you should start there and make sure you at least
> see the same problem on that kernel.  Otherwise, maybe we've made up for
> the performance elsewhere.

Right, could be, I was working on top of 2.6.31-rc1.

> Finally, didn't you revert the autotuning patch?  If so, you wouldn't
> see this problem.  Let me know how this goes, and if you still can't
> reproduce it I'll setup for testing it here.

Right, I re-applied the autotuning patch before applying the others.

Thanks for the suggestions.

--b.
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
