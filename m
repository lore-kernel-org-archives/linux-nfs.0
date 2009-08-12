From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
Date: Wed, 12 Aug 2009 13:02:13 -0400
Message-ID: <x491vnhvucq.fsf@segfault.boston.devel.redhat.com>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
	<20090812024341.GA3227@fieldses.org>
	<x49ab25w4ja.fsf@segfault.boston.devel.redhat.com>
	<20090812142041.GA12753@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090812142041.GA12753@fieldses.org> (J. Bruce Fields's message
	of "Wed, 12 Aug 2009 10:20:41 -0400")
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Wed, Aug 12, 2009 at 09:22:17AM -0400, Jeff Moyer wrote:
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> 
>> > On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
>> >> I squashed the previous set of 4 incremental patches into 3. Otherwise
>> >> there should be no differences w.r.t. the set that Jeff tested.
>> >
>> > Apologies for the long delay.... Unfortunately, I can't reproduce any of
>> > this at all: I reliably get about 112MB/s regardless of what combination
>> > of these patches I apply (including none).  This is over gigabit
>> > ethernet to a server exporting a filesystem on raid 0 over 3 sata disks
>> > which iozone locally reports getting just over 200MB/s reads from.
>> >
>> > Any suggestions?
>> 
>> Well, you gave me nothing to go on here, Bruce!
>
> Apologies for the lack of details....

No worries.  ;-)

>> I assume you're using
>> the deadline I/O scheduler on the NFS server, is that right?  If not,
>> you should be.
>
> Oops, sorry, no. Looks like it doesn't allow setting a scheduler on md0,
> so I'm assuming I should be setting it on the component drives.

Right, set the scheduler on the component drives.  I was testing on
hardware raid, fwiw.

Again, let me know if you need me to reproduce this.  It will give me an
excuse to get back that really nice machine I was using for testing. ;-)

-Jeff
