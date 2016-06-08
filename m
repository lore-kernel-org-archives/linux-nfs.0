Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:53414 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426278AbcFHOoZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 10:44:25 -0400
Subject: Re: Files leak from nfsd in 4.7.1-rc1 (and more?)
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1465383501.27742.19.camel@poochiereds.net>
Date: Wed, 8 Jun 2016 10:44:13 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
Message-Id: <E7CB5954-7A60-4F4B-BFA7-872E5B8C5EDB@linuxhacker.ru>
References: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru> <1465319435.3024.25.camel@poochiereds.net> <0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru> <1465329897.3024.38.camel@poochiereds.net> <752F7196-1EE7-4FB3-8769-177131C8A793@linuxhacker.ru> <1465344205.3024.42.camel@poochiereds.net> <AA8AB6FA-E3FF-42B9-A275-0173BD667B0F@linuxhacker.ru> <1465383501.27742.19.camel@poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 8, 2016, at 6:58 AM, Jeff Layton wrote:

> On Tue, 2016-06-07 at 22:22 -0400, Oleg Drokin wrote:
>> On Jun 7, 2016, at 8:03 PM, Jeff Layton wrote:
>> 
>>>>> That said, this code is quite subtle. I'd need to look over it in more
>>>>> detail before I offer up any fixes. I'd also appreciate it if anyone
>>>>> else wants to sanity check my analysis there.
>>>>> 
>>> Yeah, I think you're right. It's fine since r/w opens have a distinct
>>> slot, even though the refcounting just tracks the number of read and
>>> write references. So yeah, the leak probably is in an error path
>>> someplace, or maybe a race someplace.
>> 
>> So I noticed that set_access is always called locked, but clear_access is not,
>> this does not sound right.
>> 
>> So I placed this strategic WARN_ON:
>> @@ -3991,6 +4030,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
>>                         goto out_put_access;
>>                 spin_lock(&fp->fi_lock);
>>                 if (!fp->fi_fds[oflag]) {
>> +WARN_ON(!test_access(open->op_share_access, stp));
>>                         fp->fi_fds[oflag] = filp;
>>                         filp = NULL;
>>        
>> This is right in the place where nfsd set the access flag already, discovered
>> that the file is not opened and went on to open it, yet some parallel thread
>> came in and cleared the flag by the time we got the file opened.
>> It did trigger (but there are 30 minutes left till test finish, so I don't
>> know yet if this will correspond to the problem at hand yet, so below is speculation).
>> 
>> Now, at the exit from this function, the state will not have access for this file
>> set and the file would be leaked, since the matching call, probably in
>> release_all_access() does:
>>                 if (test_access(i, stp))
>>                         nfs4_file_put_access(stp->st_stid.sc_file, i);
>>                 clear_access(i, stp);
>> 
>> Meaning that the refcount is not dropped due to no access flag set.
>> 
>> I imagine we can just set the flag back right after setting fp->fi_fds[oflag]
>> and that particular race would be gone?
>> 
>> Would that be ok, or is it just wrong that somebody can come and drop
>> (delegation downgrade seems to be the most likely suspect) access bits like this
>> while they are in the middle of being acquired?
>> 
> 
> I think you're on the right track...
> 
> Operations that morph the stateid's seqid should be serialized via the
> st_rwsem. An OPEN_DOWNGRADE or CLOSE takes an exclusive lock on the
> rwsem, but we do allow OPENs to run in parallel with each other, under
> the assumption that on success you always get at least what you
> requested. So, I don't think that OPEN can really race with an
> OPEN_DOWNGRADE or CLOSE like you're thinking.
> 
> But...suppose we have two racing OPEN calls. They're both in
> nfs4_get_vfs_file. One opens the file and succeeds and the other fails
> and ends up in out_put_access. At that point, you could end up
> clobbering the successful update to st_access_bmap from the other task,
> and we'd end up not putting the file access references in
> release_all_access.

It looks like the race plays in reverse to what I thought.
My assert when setting fi_fds to not NULL never hit, but I also had this warning
below and that DID hit and is a 100% correlation to the later leak.

set_access(u32 access, struct nfs4_ol_stateid *stp)
{
        unsigned char mask = 1 << access;

        WARN_ON_ONCE(access > NFS4_SHARE_ACCESS_BOTH);
WARN_ON(stp->st_access_bmap & mask);
        stp->st_access_bmap |= mask;
}

So we are setting the access that is already set
(this comes from nfs4_get_vfs_file() via nfs4_upgrade_open() ) twice, then one
of the callers drops theirs, and so subsequent state is not dropping their
file reference in release_all_access() because they don't see the access bit,
something like this.

Though I don't see why it cannot play like I originally envisioned too.

Hm…
So if it always hits when set_access warning triggers, and there's no
error on both paths, then there's no explicit call to nfs4_file_put_access()
and that's a leak since release_all_access() would only release the file once?

I wonder if instead on the success exit path we can check the old_access_bmap and
if there our current access is also set - release it?
This is ok, right? if the other caller succeeded they still keep the reference.
If the other caller failed they drop theirs and restore their idea of access bmap
which presumably does not have the bit set and drop their reference anyway.

The question is if they both fail, or only them fail.
If both fail and we win the race on restoring old access - we might set access wrongly
because them had it correct.
Similarly if they fail and we don't, they can reset our access.

> A simple way to confirm that might be to convert all of the read locks
> on the st_rwsem to write locks. That will serialize all of the open
> operations and should prevent that particular race from occurring.
> 
> If that works, we'd probably want to fix it in a less heavy-handed way,
> but I'd have to think about how best to do that.

Indeed this sounds a bit too heavy handed, but I'll give it a try just to make sure.

Thanks.

Bye,
    Oleg