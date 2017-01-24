Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16605 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdAXTym (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 14:54:42 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] nfs: Don't increment lock sequence ID after NFS4ERR_MOVED
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170124194140.GB20844@fieldses.org>
Date: Tue, 24 Jan 2017 14:54:37 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6C265563-4A49-4369-8A34-4803A07EC1D5@oracle.com>
References: <20170122190429.7337.77928.stgit@manet.1015granger.net> <69D3212A-874D-42A2-BE65-F3A01B061A87@oracle.com> <20170123164913.GB9493@fieldses.org> <1F944D3D-A28B-48C5-88CC-39EBD6CB8430@oracle.com> <20170124191515.GA20844@fieldses.org> <677C0AEE-D64A-489E-B7CE-4BFEEABAA6EA@oracle.com> <20170124194140.GB20844@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 24, 2017, at 2:41 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, Jan 24, 2017 at 02:31:37PM -0500, Chuck Lever wrote:
>> Adding a justification is OK with me, and please replace the
>> list of steps with my updated list above.
>> 
>> However, your explanation implies that Solaris is the only server
>> that might need this fix. Actually _any_ server that supports
>> transparent state migration needs clients to get this fix. Lock
>> operations on a file that has moved are not able to update the
>> sequence ID on the destination server.
> 
> Are you sure?

I'm pretty sure.


> Couldn't an implementation include a server-to-server
> protocol that allowed the source and destination server to share stateid
> information?

"Migration" means that the filesystem's name space and data
content has moved, and is no longer accessible on this server.

"Transparent State Migration" means that the filesystem's
state was moved with its name space and data content.

NFS4ERR_MOVED here means specifically that file and its state
is no longer managed or accessible at the local server. It
kind of implies categorically that the above situation is not
in play.

What you are describing is something that is not Transparent
State Migration. Sounds more like replication. In which case,
the server would report NFS4ERR_MOVED on a LOOKUP at the
root of the filesystem, and not on a LOCK request. A client
can recognize the difference between these two and react
accordingly.


> But even if that's possible, it may be unnecessarily complicated, so I
> agree I shouldn't be claiming it's a Solaris-specific issue (though it
> may be worth documenting that's who first hit this).
> 
> --b.
> 
>> This backwards-compatible change is OK because:
>> 
>> - No servers in the wild support migration yet, thus
>> NFS4ERR_MOVED is never returned by existing servers
>> 
>> - Clients that do not support migration should never receive
>> NFS4ERR_MOVED on a state-mutating operation
>> 
>> In other words, this change is necessary only for clients that
>> support TSM.
>> 
>> Salt to taste.
>> 
>> 
>>> --b.
>>> 
>>>> 
>>>> 
>>>>> --b.
>>>>> 
>>>>>>> 
>>>>>>> Reported-by: Xuan Qi <xuan.qi@oracle.com>
>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>> Cc: stable@vger.kernel.org # v3.7+
>>>>>>> ---
>>>>>>> include/linux/nfs4.h |    3 ++-
>>>>>>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>>>>>> 
>>>>>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>>>>>>> index bca5363..1b1ca04 100644
>>>>>>> --- a/include/linux/nfs4.h
>>>>>>> +++ b/include/linux/nfs4.h
>>>>>>> @@ -282,7 +282,7 @@ enum nfsstat4 {
>>>>>>> 
>>>>>>> static inline bool seqid_mutating_err(u32 err)
>>>>>>> {
>>>>>>> -	/* rfc 3530 section 8.1.5: */
>>>>>>> +	/* See RFC 7530, section 9.1.7 */
>>>>>>> 	switch (err) {
>>>>>>> 	case NFS4ERR_STALE_CLIENTID:
>>>>>>> 	case NFS4ERR_STALE_STATEID:
>>>>>>> @@ -291,6 +291,7 @@ static inline bool seqid_mutating_err(u32 err)
>>>>>>> 	case NFS4ERR_BADXDR:
>>>>>>> 	case NFS4ERR_RESOURCE:
>>>>>>> 	case NFS4ERR_NOFILEHANDLE:
>>>>>>> +	case NFS4ERR_MOVED:
>>>>>>> 		return false;
>>>>>>> 	};
>>>>>>> 	return true;
>>>>>>> 
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> 
>>>>>> --
>>>>>> Chuck Lever
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> 
>>>> --
>>>> Chuck Lever
>>>> 
>>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> Chuck Lever
>> 
>> 

--
Chuck Lever



