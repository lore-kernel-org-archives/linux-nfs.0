Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19338 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAXT7S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 14:59:18 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] nfs: Don't increment lock sequence ID after NFS4ERR_MOVED
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170124195350.GC20844@fieldses.org>
Date: Tue, 24 Jan 2017 14:58:37 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CEE8A2B2-B551-453D-A6B6-E9F402C139BA@oracle.com>
References: <20170122190429.7337.77928.stgit@manet.1015granger.net> <69D3212A-874D-42A2-BE65-F3A01B061A87@oracle.com> <20170123164913.GB9493@fieldses.org> <1F944D3D-A28B-48C5-88CC-39EBD6CB8430@oracle.com> <20170124191515.GA20844@fieldses.org> <677C0AEE-D64A-489E-B7CE-4BFEEABAA6EA@oracle.com> <20170124194140.GB20844@fieldses.org> <20170124195350.GC20844@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 24, 2017, at 2:53 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, Jan 24, 2017 at 02:41:40PM -0500, J. Bruce Fields wrote:
>> On Tue, Jan 24, 2017 at 02:31:37PM -0500, Chuck Lever wrote:
>>> Adding a justification is OK with me, and please replace the
>>> list of steps with my updated list above.
>>> 
>>> However, your explanation implies that Solaris is the only server
>>> that might need this fix. Actually _any_ server that supports
>>> transparent state migration needs clients to get this fix. Lock
>>> operations on a file that has moved are not able to update the
>>> sequence ID on the destination server.
>> 
>> Are you sure?  Couldn't an implementation include a server-to-server
>> protocol that allowed the source and destination server to share stateid
>> information?
>> 
>> But even if that's possible, it may be unnecessarily complicated, so I
>> agree I shouldn't be claiming it's a Solaris-specific issue (though it
>> may be worth documenting that's who first hit this).
>> 
>> --b.
>> 
>>> This backwards-compatible change is OK because:
>>> 
>>> - No servers in the wild support migration yet, thus
>>> NFS4ERR_MOVED is never returned by existing servers
> 
> I think you mean "transparent state migration" there?

Yes, though I'm not aware of any public implementations
that support plain migration either.

NFS4ERR_MOVED can also be returned in cases where servers want
to advertise replicas, but we don't expect that status on
seqid-mutating operations like LOCK.


> A server supporting non-transparent state migration could return
> NFS4ERR_MOVED on a LOCK operation, but the client won't be able to use
> that stateid afterwards in that case anyway.
> 
>>> - Clients that do not support migration should never receive
>>> NFS4ERR_MOVED on a state-mutating operation
> 
> I didn't think there was a way for clients to advertise non-support for
> migration?

Not in NFSv4.0, but NFSv4.1 has an EXCHANGE_ID flag that signifies
client support for migration.


> But such clients could never recover from MOVED anyway, so we're not
> making things worse for them.

Exactly.


> --b.
> 
>>> 
>>> In other words, this change is necessary only for clients that
>>> support TSM.
>>> 
>>> Salt to taste.
>>> 
>>> 
>>>> --b.
>>>> 
>>>>> 
>>>>> 
>>>>>> --b.
>>>>>> 
>>>>>>>> 
>>>>>>>> Reported-by: Xuan Qi <xuan.qi@oracle.com>
>>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>>> Cc: stable@vger.kernel.org # v3.7+
>>>>>>>> ---
>>>>>>>> include/linux/nfs4.h |    3 ++-
>>>>>>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>>>>>>> 
>>>>>>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>>>>>>>> index bca5363..1b1ca04 100644
>>>>>>>> --- a/include/linux/nfs4.h
>>>>>>>> +++ b/include/linux/nfs4.h
>>>>>>>> @@ -282,7 +282,7 @@ enum nfsstat4 {
>>>>>>>> 
>>>>>>>> static inline bool seqid_mutating_err(u32 err)
>>>>>>>> {
>>>>>>>> -	/* rfc 3530 section 8.1.5: */
>>>>>>>> +	/* See RFC 7530, section 9.1.7 */
>>>>>>>> 	switch (err) {
>>>>>>>> 	case NFS4ERR_STALE_CLIENTID:
>>>>>>>> 	case NFS4ERR_STALE_STATEID:
>>>>>>>> @@ -291,6 +291,7 @@ static inline bool seqid_mutating_err(u32 err)
>>>>>>>> 	case NFS4ERR_BADXDR:
>>>>>>>> 	case NFS4ERR_RESOURCE:
>>>>>>>> 	case NFS4ERR_NOFILEHANDLE:
>>>>>>>> +	case NFS4ERR_MOVED:
>>>>>>>> 		return false;
>>>>>>>> 	};
>>>>>>>> 	return true;
>>>>>>>> 
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>> 
>>>>>>> --
>>>>>>> Chuck Lever
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>> 
>>>>> --
>>>>> Chuck Lever
>>>>> 
>>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>>> --
>>> Chuck Lever
>>> 
>>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



