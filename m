Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:61535 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbaFEMWX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 08:22:23 -0400
Received: by mail-qa0-f50.google.com with SMTP id j15so1215230qaq.37
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 05:22:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140605022918.GB12044@fieldses.org>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
	<1401915726-29092-3-git-send-email-dros@primarydata.com>
	<20140605022918.GB12044@fieldses.org>
Date: Thu, 5 Jun 2014 08:22:22 -0400
Message-ID: <CAABAsM60taecJryiaryhnW8FbZGo5s0r4Oz=aRFXYCBPDQoBbA@mail.gmail.com>
Subject: Re: [PATCH pynfs 02/17] 4.1 server: service RECLAIM_COMPLETE operations
From: Trond Myklebust <trondmy@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 4, 2014 at 10:29 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Jun 04, 2014 at 05:01:50PM -0400, Weston Andros Adamson wrote:
>> Just return ok!
>
> Technically it should record whether or not the reclaim_complete has
> happened and return a GRACE error on any non-reclaim open performed
> before the reclaim_complete--but for your purposes you may not care...
>

...and a NOGRACE error on any reclaim opens performed by that client
after the reclaim_complete?

> --b.
>
>>
>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>> ---
>>  nfs4.1/nfs4server.py | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
>> index 65fb9af..3607dc0 100755
>> --- a/nfs4.1/nfs4server.py
>> +++ b/nfs4.1/nfs4server.py
>> @@ -1809,6 +1809,9 @@ class NFS4Server(rpc.Server):
>>          with find_state(env, arg.deleg_stateid, allow_0=False) as state:
>>              state.delegreturn()
>>          return encode_status(NFS4_OK)
>> +
>> +    def op_reclaim_complete(self, arg, env):
>> +        return encode_status(NFS4_OK)
>>
>>      def op_getdevicelist(self, arg, env): # STUB
>>          check_session(env)
>> --
>> 1.8.5.2 (Apple Git-48)
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
