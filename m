From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Tue, 27 Apr 2010 18:03:14 +0300
Message-ID: <4BD6FCB2.4020805@panasas.com>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu> <20100422144831.GA5926@fieldses.org> <20100423212411.GC1964@fieldses.org> <20100423231344.GA6425@fieldses.org> <20100424001034.GA7176@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35313 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752230Ab0D0PDS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 11:03:18 -0400
In-Reply-To: <20100424001034.GA7176@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 24, 2010, 3:10 +0300, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Fri, Apr 23, 2010 at 07:13:44PM -0400, J. Bruce Fields wrote:
>> On Fri, Apr 23, 2010 at 05:24:11PM -0400, J. Bruce Fields wrote:
>>> On Thu, Apr 22, 2010 at 10:48:31AM -0400, J. Bruce Fields wrote:
>>>> On Thu, Apr 22, 2010 at 10:32:23AM -0400, J. Bruce Fields wrote:
>>>>> Enforce the rules about compound op ordering.
>>>>>
>>>>> Motivated by implementing RECLAIM_COMPLETE, for which the client is
>>>>> implicit in the current session, so it is important to ensure a
>>>>> succesful SEQUENCE proceeds the RECLAIM_COMPLETE.
>>>>
>>>> The other problem here is that while we have a reference count on the
>>>> session itself preventing it from going away till the compound is done,
>>>> I don't see what prevents the associated clientid from going away.
>>>>
>>>> To fix that, and to be more polite to 4.0 clients, I think we want to
>>>> also add a client pointer to the compound_state structure, keep count of
>>>> the number of compounds in progress which reference that client, and not
>>>> start the client's expiry timer until we've encoded the reply to the
>>>> compound.
>>>
>>> Benny--I coded up a simple (possibly incorrect) implementation of this,
>>> and then remembered that this was more or less what your
>>> state-lock-reduction-prep patch series did.  Do you have a more recent
>>> version of those patches?
>>
>> One possible problem with that approach: mark_for_renew() can fail (if
>> the client is already expired), without telling the caller.
>>
>> You then end up with an odd situation, continuing to process the rest of
>> the compound normally, while your session belongs to a client that's
>> already expired.
>>
>> Perhaps it would be better to mark the client for possible renewal the
>> moment it (or some stateid, sessionid, or other object that refers to
>> it) is looked up?
> 
> Also: a single "RENEW" state won't suffice when multiple outstanding
> compounds reference the same client, in which case you want only the
> last (not the first) to complete to do the renewal.  So I think we want
> a count of outstanding compounds referencing the client, so that we can
> do the renewal when the count goes to zero.

True. My patchset sort of did that on SEQUENCE, though not under the
sessionid_lock.  If the client is expired atomically with updating
all sessions referring to it under that lock we can refcount it for
renewal on nfsd4_get_session (always called under sessionid_lock),
next nfsd4_put_session should be moved under the same lock and there
the "use count" can be decremented and the client can be renewed
when no session is actively using it.

Benny

> 
> --b.
