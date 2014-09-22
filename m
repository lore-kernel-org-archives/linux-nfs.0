Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:59382 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503AbaIVTtv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2014 15:49:51 -0400
Received: by mail-vc0-f182.google.com with SMTP id le20so4700682vcb.27
        for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 12:49:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <542062A0.4030103@akamai.com>
References: <cover.1411068259.git.jbaron@akamai.com>
	<d143828a73125846d583f4c606061109d22869f7.1411068259.git.jbaron@akamai.com>
	<CAHQdGtQOoop=CShDx9dTXSjo47KzWoRqkM9PNx1Si-pFSXg-_w@mail.gmail.com>
	<541B484E.90202@akamai.com>
	<CAHQdGtQ93P5BpDgW+BEhWNGB4=M7f0RF4p8NOXQmUJEw9cu4iQ@mail.gmail.com>
	<541B8CF0.3090502@akamai.com>
	<CAHQdGtSYqwLKuBWKGdZYaZqg5K=+f101FqUZ9Y5gHKr12bbbHA@mail.gmail.com>
	<541C9D16.7010800@akamai.com>
	<542062A0.4030103@akamai.com>
Date: Mon, 22 Sep 2014 15:49:50 -0400
Message-ID: <CAHQdGtQ4m3LfKHsQ=bwu9_dg5J7i4KREM75mqf4KnB=JjzfWCQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] rpc: Add -EPERM processing for xs_udp_send_request()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jason Baron <jbaron@akamai.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 22, 2014 at 1:55 PM, Jason Baron <jbaron@akamai.com> wrote:
> On 09/19/2014 05:16 PM, Jason Baron wrote:
>> On 09/19/2014 03:41 PM, Trond Myklebust wrote:
>>> On Thu, Sep 18, 2014 at 9:54 PM, Jason Baron <jbaron@akamai.com> wrote:
>>>> On 09/18/2014 05:20 PM, Trond Myklebust wrote:
>>>>> On Thu, Sep 18, 2014 at 5:02 PM, Jason Baron <jbaron@akamai.com> wrote:
>>>>>> On 09/18/2014 04:51 PM, Trond Myklebust wrote:
>>>>>>> On Thu, Sep 18, 2014 at 3:51 PM, Jason Baron <jbaron@akamai.com> wrote:
>>>>>>>> If an iptables drop rule is added for an nfs server, the client can end up in
>>>>>>>> a softlockup. Because of the way that xs_sendpages() is structured, the -EPERM
>>>>>>>> is ignored since the prior bits of the packet may have been successfully queued
>>>>>>>> and thus xs_sendpages() returns a non-zero value. Then, xs_udp_send_request()
>>>>>>>> thinks that because some bits were queued it should return -EAGAIN. We then try
>>>>>>>> the request and again and a softlockup occurs. The test sequence is simply:
>>>>>>>>
>>>>>>>> 1) open a file on the nfs server '/nfs/foo' (mounted using udp)
>>>>>>>> 2) iptables -A OUTPUT -d <nfs server ip> -j DROP
>>>>>>>> 3) write to /nfs/foo
>>>>>>>> 4) close /nfs/foo
>>>>>>>> 5) iptables -D OUTPUT -d <nfs server ip> -j DROP
>>>>>>>>
>>>>>>>> The softlockup occurs in step 4 above.
>>>>>>> For UDP, the expected and documented behaviour in the case above is as follows:
>>>>>>> - if the mount is soft, then return EIO on the first major timeout.
>>>>>> yeah - so this case is a softlockup in my testing :(
>>>>>>
>>>>>>> - if the mount is hard, then retry indefinitely on timeout.
>>>>>>>
>>>>>>> Won't these 2 patches end up propagating an EPERM to the application?
>>>>>>> That would be a definite violation of both hard and soft semantics.
>>>>>> ok, yeah it does propogate the -EPERM up - I wasn't aware of the correct
>>>>>> semantics - thanks.
>>>>>>
>>>>>> I can rework the patches such that they return -EIO instead for a soft mount,
>>>>>> and verify that we keep retrying for a hard one.
>>>>>>
>>>>> Doesn't the soft timeout currently trigger after the major timeout? If
>>>>> not, do we understand why it isn't doing so?
>>>>
>>>> No, the soft timeout does not currently trigger after the major timeout. Instead,
>>>> the kernel spins indefinitely, and triggers a softlockup.
>>>>
>>>> The reason is that xs_sendpages() returns a positive value in this case
>>>> and xs_udp_send_request() turns it in an -EAGAIN for the write operation.
>>>> Subsequently, we call call_transmit_status() and then call_status() which
>>>> sees the EAGAIN, which just starts all over again with a 'call_transmit()'.
>>>> So we are stuck spinning indefinitely in kernel space.
>>>>
>>>> Simply moving the -EPERM up in this patch, results in the behavior you
>>>> described above - EIO after a major timeout on a soft mount, and indefinte
>>>> retries on a hard mount - but without the cpu consumption. IE applying
>>>> this on top of this patch:
>>>>
>>>> --- a/net/sunrpc/clnt.c
>>>> +++ b/net/sunrpc/clnt.c
>>>> @@ -2019,6 +2019,7 @@ call_status(struct rpc_task *task)
>>>>         case -EHOSTDOWN:
>>>>         case -EHOSTUNREACH:
>>>>         case -ENETUNREACH:
>>>> +       case -EPERM:
>>>>                 if (RPC_IS_SOFTCONN(task)) {
>>>>                         rpc_exit(task, status);
>>>>                         break;
>>>> @@ -2048,7 +2049,6 @@ call_status(struct rpc_task *task)
>>>>         case -EAGAIN:
>>>>                 task->tk_action = call_transmit;
>>>>                 break;
>>>> -       case -EPERM:
>>>>         case -EIO:
>>>>                 /* shutdown or soft timeout */
>>>>                 rpc_exit(task, status);
>>>>
>>>> We could also 'translate' the -EPERM into an '-ENETUNREACH' or such,
>>>> in the return from xs_udp_send_request(), if you think that would make
>>>> more sense?
>>>>
>>>> Hopefully, I've explained things better.
>>>>
>>>>
>>>
>>> Yep. Can you please resend the patch with the above fix? I think we
>>> can live with the EPERM in the RPC_IS_SOFTCONN case, given that it is
>>> in practice only ever passed back to the 'mount' syscall.
>>>
>>
>> Hi,
>>
>> So after some more testing on this new patch, the test sequence I described
>> works fine - but if I set the firewall rule first and then do an open, it
>> appears that the open() wouldn't time out even on a soft mount (whereas
>> with the previous patch it incorrectly returned -EPERM almost immediately).
>> It appears that the rpc request is getting queued up onto one of the wait
>> queues (xprt_backlog or xprt_sending) in that case, but I'm not sure why.
>> I'll have to look more into it next week.
>>
>> Thanks,
>>
>> -Jason
>>
>>
>
> Hi Trond,
>
> Ok, so they do timeout now with this patch (for a soft mount) - I simply wasn't
> waiting long enough (took around 30 minutes in some cases). So I think this
> patch is ok. If it makes sense I can clean it up based on the comments, and
> re-submit?
>

Please do. Thanks!

Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
