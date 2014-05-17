Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f175.google.com ([209.85.128.175]:34705 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964865AbaEQRR3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 May 2014 13:17:29 -0400
Received: by mail-ve0-f175.google.com with SMTP id jw12so4547101veb.6
        for <linux-nfs@vger.kernel.org>; Sat, 17 May 2014 10:17:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFo99gatLzLpOu92N23bMQ=a25BTnK3QK2rAzoQJcU3oxMuMgA@mail.gmail.com>
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<5376025B.6010202@cogentembedded.com>
	<CAFo99gatLzLpOu92N23bMQ=a25BTnK3QK2rAzoQJcU3oxMuMgA@mail.gmail.com>
Date: Sat, 17 May 2014 13:17:28 -0400
Message-ID: <CAHQdGtRd-uKvRU8DD9zK-MEF0B10=rESrQAPJoQ8hTunwG883A@mail.gmail.com>
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 17, 2014 at 12:36 PM, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> Hi
>
> I have made a new patch according Sergei specification.
>

I'll be happy to apply this patch once someone explains to me why we
can't just remove that check for cred != NULL, however I'm not
applying a patch purely in order to silence a warning from cppcheck.

Cheers,
   Trond

> But there remains Tronds question though.
>
> Best regards
> Rickard Strandqvist
>
>
> 2014-05-16 14:19 GMT+02:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
>> Hello.
>>
>>
>> On 16-05-2014 1:56, Rickard Strandqvist wrote:
>>
>>> There is otherwise a risk of a possible null pointer dereference.
>>
>>
>>> Was largely found by using a static code analysis program called cppcheck.
>>
>>
>>> Signed-off-by: Rickard Strandqvist
>>> <rickard_strandqvist@spectrumdigital.se>
>>> ---
>>>   net/sunrpc/auth.c |   10 +++++++---
>>>   1 fil ändrad, 7 tillägg(+), 3 borttagningar(-)
>>
>>
>>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>>> index 5285ead..3a55698 100644
>>> --- a/net/sunrpc/auth.c
>>> +++ b/net/sunrpc/auth.c
>>> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>>>   {
>>>         struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>>>
>>> -       dprintk("RPC: %5u invalidating %s cred %p\n",
>>> -               task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>>> -       if (cred)
>>> +       if (cred) {
>>> +               dprintk("RPC: %5u invalidating %s cred %p\n",
>>> +                       task->tk_pid, cred->cr_auth->au_ops->au_name,
>>> cred);
>>> +
>>>                 clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>>> +       }
>>> +       else
>>
>>
>>    } and *else* should be on the same line, and there should be {} in the
>> *else* arm since there's {} in the *if* arm already, according to
>> Documentation/CodingStyle.
>>
>>
>>> +               dprintk("RPC: %5u invalidating is NULL\n", task->tk_pid);
>>
>>
>>    That's not a proper English, I'm afraid.
>>
>>>   }
>>
>>
>> WBR, Sergei
>>
>>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
