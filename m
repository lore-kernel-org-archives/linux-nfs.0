Return-Path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4C7D349E.5010709@panasas.com>
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com>
	<OF1477B0A3.3F72D2BF-ON88257783.005FBF98-88257783.005FDE25@us.ibm.com>
	<OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com>
	<4C761A61.2070203@panasas.com>
	<273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
	<4C7D349E.5010709@panasas.com>
Date: Tue, 31 Aug 2010 11:11:06 -0700
Message-ID: <AANLkTikUK=u4bHzfzdU=bwKp8tvPOohHuWjKn+XSK9Sy@mail.gmail.com>
Subject: Re: Linux pNFS status meeting 08/26
From: Fred Isaman <iisaman@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 31, 2010 at 9:58 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 08/31/2010 12:15 AM, Labiaga, Ricardo wrote:
>> Last week Andy, Fred, Trond, and I were physically in the same location,
>> so we took the opportunity to review the first set of patches in the
>> pnfs-submit branch and further discussed the best way to proceed with
>> the submission. =A0For ease of review, Trond reiterated that we submit o=
ur
>> patches in waves of functionality and that they be submitted as a set of
>> few large patches.
>>
>> The proposal is to submit the functionality in the following order:
>>
>> 1st Layoutget and getdeviceinfo (together)
>> 2nd Layoutreturn
>> 3rd Read/ Write I/O path (could be broken into two sets)
>> 4th Callback Path
>> 5th Layoutcommit
>>
>
> A natural read and understanding of pnfs has this logical progression
>
> 1st Layoutget and getdeviceinfo (together)
> 2rd Read/ Write I/O path (could be broken into two sets)
> 3rd Layoutcommit
> 4th Layoutreturn
> 5th Callback Path
>
> Could you elaborate a bit on why you choose to reorder them this way?
>

Because in your suggested order, the IO code would not work correctly
until the layoutreturn code is added.  With our ordering, at each step
there is fully functional code that does not depend for correctness on
future patches.  (Note that the layoutcommit code is basically
optional for the file driver, so is last.)

>> For the 1st wave of functionality, the suggestion is to submit three
>> large patches:
>>
>
> I would love to see a:
> 0. Complete STD definitions headers
>

Trond has said that enums taken direct from the spec can include their
full definitions, even if not all are used yet, so those that we
include should be complete.

>> 1. Everything that touches NFS common code
>> =A0 (such as init and uninit pNFS, pnfs_update_layout invocations)
>
> Separation to proc and XDR layers

This will be more like what you ask about below...the invocation of
pnfs code on mount/umount, and calls to pnfs_update_layout.

>
>> 2. Layoutget and getdeviceinfo generic code common to all layout drivers
>
> Is that the high level pnfs.c stuff? then YES nice.
>

Very roughly, the pnfs.c code stripped of anything related to
LAYOUTRETURN, LAYOUTCOMMIT, or needed only for block/object drivers.

> Will this be together with it's invocation at the nfs-vfs files like
> inode.c write.c etc.. ?
>
>> 3. File layout specific layoutget and getdeviceinfo
>>
>
> You might want to reorder 2 and 3. First submit services which are at fir=
st
> dead code. Then submit the code that calls them. Are you making a point
> in making each patch compilable, runnable through out?
>

We've been told to avoid having dead code.  So any patch which
includes a function also has callers of that function.  Thus we need
to keep the ordering of 2 and 3.

Ignoring how we split up the code for our first submission for the
moment, we should be sending out the actual changes we are making to
the current first ~20 patches of pnfs-submit by the end of the day.
We'll split the code once those changes are reviewed.

Fred

>> This means we have about 19 or so of the first pnfs-submit patches that
>> need to be squashed into a single patch for ease of review. =A0In
>> addition, we found a number of minor issues during the review that need
>> to be addressed. =A0We also need to strip out some things that are not
>> strictly needed for the first wave of patches, with the intent to
>> reintroduce them when the functionality is actually used by objects and
>> blocks. =A0It was made clear that including functionality that is not
>> required by the File Layout driver at this time is not appropriate. =A0F=
or
>> example, io_ops that are no required by the File Layout (and have a
>> trivial implementation) are a no-go. =A0The abstraction is best introduc=
ed
>> when the drivers that actually require it are submitted.
>>
>> Andy and Fred will email the details of the changes along with the
>> patches shortly.
>>
>> Net-net, no radical changes needed, but a number of small issues that
>> need to be addressed before we can start submitting. =A0More details
>> coming shortly.
>>
>> Thanks,
>>
>> - ricardo
>
> Thanks
> Boaz
> _______________________________________________
> NOTE: THIS LIST IS DEPRECATED. =A0Please use linux-nfs@vger.kernel.org in=
stead.
> (To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in=
 the body of a message to majordomo@vger.kernel.org.)
>
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>
_______________________________________________
NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org instea=
d.
(To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in t=
he body of a message to majordomo@vger.kernel.org.)

NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
