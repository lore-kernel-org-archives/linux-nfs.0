Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:39299 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaFEM6D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 08:58:03 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so7505219igb.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 05:58:03 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH pynfs 02/17] 4.1 server: service RECLAIM_COMPLETE operations
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <CAABAsM60taecJryiaryhnW8FbZGo5s0r4Oz=aRFXYCBPDQoBbA@mail.gmail.com>
Date: Thu, 5 Jun 2014 08:58:01 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <50CFBC92-B124-4912-9D3D-16C81476C883@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com> <1401915726-29092-3-git-send-email-dros@primarydata.com> <20140605022918.GB12044@fieldses.org> <CAABAsM60taecJryiaryhnW8FbZGo5s0r4Oz=aRFXYCBPDQoBbA@mail.gmail.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Are you saying that the pynfs server supports state recovery? This has not
been my experience. I’ll double check.

-dros



On Jun 5, 2014, at 8:22 AM, Trond Myklebust <trondmy@gmail.com> wrote:

> On Wed, Jun 4, 2014 at 10:29 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Wed, Jun 04, 2014 at 05:01:50PM -0400, Weston Andros Adamson wrote:
>>> Just return ok!
>> 
>> Technically it should record whether or not the reclaim_complete has
>> happened and return a GRACE error on any non-reclaim open performed
>> before the reclaim_complete--but for your purposes you may not care...
>> 
> 
> ...and a NOGRACE error on any reclaim opens performed by that client
> after the reclaim_complete?
> 
>> --b.
>> 
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>>> ---
>>> nfs4.1/nfs4server.py | 3 +++
>>> 1 file changed, 3 insertions(+)
>>> 
>>> diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
>>> index 65fb9af..3607dc0 100755
>>> --- a/nfs4.1/nfs4server.py
>>> +++ b/nfs4.1/nfs4server.py
>>> @@ -1809,6 +1809,9 @@ class NFS4Server(rpc.Server):
>>>         with find_state(env, arg.deleg_stateid, allow_0=False) as state:
>>>             state.delegreturn()
>>>         return encode_status(NFS4_OK)
>>> +
>>> +    def op_reclaim_complete(self, arg, env):
>>> +        return encode_status(NFS4_OK)
>>> 
>>>     def op_getdevicelist(self, arg, env): # STUB
>>>         check_session(env)
>>> --
>>> 1.8.5.2 (Apple Git-48)
>>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

