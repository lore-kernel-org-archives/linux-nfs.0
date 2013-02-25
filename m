Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f49.google.com ([209.85.215.49]:50241 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757549Ab3BYPVL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Feb 2013 10:21:11 -0500
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DE4C7@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361744605-28235-1-git-send-email-s.syam@samsung.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9235DE4C7@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 25 Feb 2013 20:51:09 +0530
Message-ID: <CAFBvHifgLh7W58mw64Ycnn7qT6_3isYGpJAkRXuOV7KZFdSniQ@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix possible NULL pointer dereference
From: Syam Sidhardhan <syamsidhardh@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Mon, Feb 25, 2013 at 4:05 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2013-02-25 at 03:53 +0530, Syam Sidhardhan wrote:
>> Check for cred == NULL has to be done before accessing cred.
>>
>> Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
>> ---
>>  net/sunrpc/auth.c |    7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index f529404..18678a6 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -695,10 +695,13 @@ rpcauth_invalcred(struct rpc_task *task)
>>  {
>>       struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>>
>> +     if (cred == NULL)
>> +             return;
>> +
>>       dprintk("RPC: %5u invalidating %s cred %p\n",
>>               task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
>> -     if (cred)
>> -             clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>> +
>> +     clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>>  }
>>
>>  int
>
> Do we need that check at all?

I'm not sure whether we need that check or not. However
similar functions such as rpcauth_refreshcred(), rpcauth_uptodatecred() etc
are doing the same check inside. Cppcheck is throwing an error too.

Regards,
Syam
