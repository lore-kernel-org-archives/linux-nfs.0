Return-Path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20100831162648.GF3071@fieldses.org>
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com>
	<OF1477B0A3.3F72D2BF-ON88257783.005FBF98-88257783.005FDE25@us.ibm.com>
	<OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com>
	<4C761A61.2070203@panasas.com>
	<273FE88A07F5D445824060902F7003440C5CDD52@SACMVEXC1-PRD.hq.netapp.com>
	<20100831162648.GF3071@fieldses.org>
Date: Tue, 31 Aug 2010 10:51:11 -0700
Message-ID: <AANLkTi=85p8qm-_RKRH60CZBJPMp5g_Qj2NHvHcDaw1S@mail.gmail.com>
Subject: Re: Linux pNFS status meeting 08/26
From: Fred Isaman <iisaman@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
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

On Tue, Aug 31, 2010 at 9:26 AM, J. Bruce Fields <bfields@fieldses.org> wro=
te:
> On Mon, Aug 30, 2010 at 02:15:43PM -0700, Labiaga, Ricardo wrote:
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
>> For the 1st wave of functionality, the suggestion is to submit three
>> large patches:
>>
>> 1. Everything that touches NFS common code
>> =A0 (such as init and uninit pNFS, pnfs_update_layout invocations)
>> 2. Layoutget and getdeviceinfo generic code common to all layout drivers
>> 3. File layout specific layoutget and getdeviceinfo
>
> I understand large patches for the latter two, but for the first, might
> it be worth keeping smaller patches? =A0Changes to common code seem most
> at risk of breaking existing functionality. =A0And they might be
> individually testable (since you can test for regressions), as opposed to
> the new stuff that may be impossible to test until it's all applied.
>

Note that the not much touches the common code, especially in our
first submission, so it will be a fairly small patch, which we will
not be adverse to breaking up at reviewers request.  Right now we are
trying to accommodate Cristoph's request for larger patches combined
with Trond's request for small, easy to review patches for anything
that touches common code.

Fred

> But that's all just generalities--if people who've looked at the patches
> don't think they split up sensibly, then fine.
>
> --b.
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
