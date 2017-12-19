Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:43657 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932965AbdLSFsx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Dec 2017 00:48:53 -0500
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fcntl.2, read.2, write.2: document "Lost locks" as cause
 for EIO.
To: NeilBrown <neilb@suse.com>
References: <87lgi7nttp.fsf@notabene.neil.brown.name>
 <df9a18ce-c412-44aa-d475-77521a7252c5@gmail.com>
 <87shc7lnfs.fsf@notabene.neil.brown.name>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <130530e8-83bc-35d3-b84c-9bee85ddee12@gmail.com>
Date: Tue, 19 Dec 2017 06:48:50 +0100
MIME-Version: 1.0
In-Reply-To: <87shc7lnfs.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/18/2017 10:45 PM, NeilBrown wrote:
> On Mon, Dec 18 2017, Michael Kerrisk (man-pages) wrote:
> 
>> Hello Neil
>>
>> There's a piece of your patch I don't understand. Please see below.
>>
>> On 12/13/2017 05:19 AM, NeilBrown wrote:
>>>
>>> If an advisory lock is lost, then read/write requests on any
>>> affected file descriptor can return EIO - for NFSv4 at least.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>>  man2/fcntl.2 | 24 ++++++++++++++++++++++++
>>>  man2/read.2  |  9 +++++++++
>>>  man2/write.2 |  9 +++++++++
>>>  3 files changed, 42 insertions(+)
>>>
>>> diff --git a/man2/fcntl.2 b/man2/fcntl.2
>>> index 67642384154c..6e6e26f66aa0 100644
>>> --- a/man2/fcntl.2
>>> +++ b/man2/fcntl.2
>>> @@ -669,6 +669,30 @@ and
>>>  Mandatory locking is not specified by POSIX.
>>>  Some other systems also support mandatory locking,
>>>  although the details of how to enable it vary across systems.
>>> +.SS Lost locks
>>> +When an advisory lock is obtained on a networked filesystem such as
>>> +NFS it is possible that the lock might get lost.
>>> +This may happen due to administrative action on the server, or due to a
>>> +network partition which lasts long enough for the server to assume
>>
>> What does "network partition which lasts long enough" mean?
>> I think this perhaps needs to be clarified a little. At least,
>> I don't understand it.
> 
> "network partition" is a term using the NFS RFCs for any situation that
> that results in the server and client not being able to communicate
> (that are partitioned, one from the other?  There is partition (wall)
> between them?  They are in separate partitions?).
> I can see how the meaning might not be obvious if you hadn't come across
> it before.
> 
> If we change "network partition" to "loss of connectivity", would that
> make it clear.  Is "loss of network connectivity with the server" too
> verbose?

Thanks, Neil. I've applied your patch and added the words "loss of network
connectivity with the server".

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
