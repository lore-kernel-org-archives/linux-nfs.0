Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:49986 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaFENeR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:34:17 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so2293698igq.13
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:34:16 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH pynfs 02/17] 4.1 server: service RECLAIM_COMPLETE operations
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <97724584-1F1E-48AE-84C9-DB56A911E7A5@primarydata.com>
Date: Thu, 5 Jun 2014 09:34:14 -0400
Cc: Trond Myklebust <trondmy@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <9A6740D0-174D-4063-A273-7E052815C9ED@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com> <1401915726-29092-3-git-send-email-dros@primarydata.com> <20140605022918.GB12044@fieldses.org> <CAABAsM60taecJryiaryhnW8FbZGo5s0r4Oz=aRFXYCBPDQoBbA@mail.gmail.com> <50CFBC92-B124-4912-9D3D-16C81476C883@primarydata.com> <20140605130608.GB8362@fieldses.org> <97724584-1F1E-48AE-84C9-DB56A911E7A5@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On second thought, I’m just going to drop this patch.

I only added it to avoid a NFS4ERR_NOTSUPP when connecting the file layout
MDS to pynfs DSes, but it is harmless and outside the scope of what I’m doing.

Not worth that can of worms.

-dros



On Jun 5, 2014, at 9:18 AM, Weston Andros Adamson <dros@primarydata.com> wrote:

> 
> On Jun 5, 2014, at 9:06 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Thu, Jun 05, 2014 at 08:58:01AM -0400, Weston Andros Adamson wrote:
>>> Are you saying that the pynfs server supports state recovery? This has not
>>> been my experience. I’ll double check.
>> 
>> If you don't support state recovery, then I think the minimal correct
>> behavior would be to have no grace period at all: return NO_GRACE on
>> *every* reclaim operation and GRACE only on non-reclaims not preceded by
>> a global (one_fs == FALSE) RECLAIM_COMPLETE for that client.
>> 
>> All this does is catch misbehaving clients, and maybe that's not a
>> priority.  But it's easy enough to implement.
> 
> Yeah, that sounds good.
> 
> -dros
> 
>> 
>> —b.
>> 
>>> -dros
>>> 
>>> 
>>> 
>>> On Jun 5, 2014, at 8:22 AM, Trond Myklebust <trondmy@gmail.com> wrote:
>>> 
>>>> On Wed, Jun 4, 2014 at 10:29 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>>> On Wed, Jun 04, 2014 at 05:01:50PM -0400, Weston Andros Adamson wrote:
>>>>>> Just return ok!
>>>>> 
>>>>> Technically it should record whether or not the reclaim_complete has
>>>>> happened and return a GRACE error on any non-reclaim open performed
>>>>> before the reclaim_complete--but for your purposes you may not care...
>>>>> 
>>>> 
>>>> ...and a NOGRACE error on any reclaim opens performed by that client
>>>> after the reclaim_complete?
>>>> 
>>>>> --b.
>>>>> 
>>>>>> 
>>>>>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>>>>>> ---
>>>>>> nfs4.1/nfs4server.py | 3 +++
>>>>>> 1 file changed, 3 insertions(+)
>>>>>> 
>>>>>> diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
>>>>>> index 65fb9af..3607dc0 100755
>>>>>> --- a/nfs4.1/nfs4server.py
>>>>>> +++ b/nfs4.1/nfs4server.py
>>>>>> @@ -1809,6 +1809,9 @@ class NFS4Server(rpc.Server):
>>>>>>       with find_state(env, arg.deleg_stateid, allow_0=False) as state:
>>>>>>           state.delegreturn()
>>>>>>       return encode_status(NFS4_OK)
>>>>>> +
>>>>>> +    def op_reclaim_complete(self, arg, env):
>>>>>> +        return encode_status(NFS4_OK)
>>>>>> 
>>>>>>   def op_getdevicelist(self, arg, env): # STUB
>>>>>>       check_session(env)
>>>>>> --
>>>>>> 1.8.5.2 (Apple Git-48)
>>>>>> 
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
> 

