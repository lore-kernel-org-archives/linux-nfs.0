Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Moyer <jmoyer@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
	<20090812024341.GA3227@fieldses.org>
	<x49ab25w4ja.fsf@segfault.boston.devel.redhat.com>
	<20090812142041.GA12753@fieldses.org>
	<x491vnhvucq.fsf@segfault.boston.devel.redhat.com>
	<20090812223258.GE17782@fieldses.org>
Date: Thu, 13 Aug 2009 09:05:47 -0400
In-Reply-To: <20090812223258.GE17782@fieldses.org> (J. Bruce Fields's message
	of "Wed, 12 Aug 2009 18:32:58 -0400")
Message-ID: <x49r5vfj238.fsf@segfault.boston.devel.redhat.com>
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

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Wed, Aug 12, 2009 at 01:02:13PM -0400, Jeff Moyer wrote:
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> 
>> > On Wed, Aug 12, 2009 at 09:22:17AM -0400, Jeff Moyer wrote:
>> >> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> >> 
>> >> > On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
>> >> >> I squashed the previous set of 4 incremental patches into 3. Otherwise
>> >> >> there should be no differences w.r.t. the set that Jeff tested.
>> >> >
>> >> > Apologies for the long delay.... Unfortunately, I can't reproduce any of
>> >> > this at all: I reliably get about 112MB/s regardless of what combination
>> >> > of these patches I apply (including none).  This is over gigabit
>> >> > ethernet to a server exporting a filesystem on raid 0 over 3 sata disks
>> >> > which iozone locally reports getting just over 200MB/s reads from.
>> >> >
>> >> > Any suggestions?
>> >> 
>> >> Well, you gave me nothing to go on here, Bruce!
>> >
>> > Apologies for the lack of details....
>> 
>> No worries.  ;-)
>> 
>> >> I assume you're using
>> >> the deadline I/O scheduler on the NFS server, is that right?  If not,
>> >> you should be.
>> >
>> > Oops, sorry, no. Looks like it doesn't allow setting a scheduler on md0,
>> > so I'm assuming I should be setting it on the component drives.
>> 
>> Right, set the scheduler on the component drives.  I was testing on
>> hardware raid, fwiw.
>
> Not much difference in results.  This is frustrating.
>
> For each test, I'm booting both client and server to the given kernel,
> running
>
> 	mount server:/exports/ /mnt/
> 	iozone -s 2000000 -r 64 -f /mnt/testfile -w -i1
> 	umount /mnt/
>
> five times, then taking the average of the "read" columns.  (I could
> stick to one client--not sure which you were using.  Installing new
> kernels on both is just what my existing test scripts happened to do by
> default.)

Hmm, I think I was using a RHEL 5 client, so 2.6.18-based.

> 2.6.30-rc1:				114113
> 2.6.30-rc1 + revert autotuning:		114159
> 2.6.30-rc1 + patch 1:			114168
> 2.6.30-rc1 + patch 1 & 2:		114136
> 2.6.30-rc1 + patch 1, 2, & 3:		114149
>
> (Where patches 1, 2, 3 are, respectively, "SUNRPC: Fix the TCP server's
> send buffer accounting results", "SUNRPC: Fix the TCP write space
> reservations for deferred requests", and "Fix svc_tcp_recvfrom()
> results", respectively.
>
> And the average-of-5 is pointless, really: the individual results have
> very little variation.
>
> See anything obvious I've gotten wrong here?

Aside from the client kernel, which I didn't think mattered at the time,
no.

>> Again, let me know if you need me to reproduce this.  It will give me an
>> excuse to get back that really nice machine I was using for testing. ;-)
>
> I'd be happiest if I could figure out how to reproduce this myself.

Understood.  Try an older client kernel.  If that still doesn't work,
then let me reproduce it and get back to you with more specifics of my
configuration.

Thanks for being so diligent, Bruce!

-Jeff
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
