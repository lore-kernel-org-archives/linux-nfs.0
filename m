Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:46658 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752359AbeDQNJC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2018 09:09:02 -0400
Received: by mail-ua0-f195.google.com with SMTP id a17so12431959uaf.13
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 06:09:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416212942.GA2634@parsley.fieldses.org>
References: <680B7A1A-792A-4B9E-A0CA-46E459B65077@netapp.com> <20180416212942.GA2634@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 17 Apr 2018 09:08:59 -0400
Message-ID: <CAN-5tyFV7tmzY6gGb1sDffXq=YW+eiJrPsQVpmWnszspeh00cg@mail.gmail.com>
Subject: Re: nfsd issue with a kerberized callback
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2018 at 5:29 PM, J. Bruce Fields <bfields@redhat.com> wrote=
:
> On Mon, Apr 16, 2018 at 03:48:49PM -0400, Olga Kornievskaia wrote:
>> I have a failure that I=E2=80=99m investigating from the Bakeathon (this=
 was
>> going against redhat-75 server. Not sure who was running that server.
>> But I believe that was RHEL7.5 server). I have a network trace and I
>> was wondering if you could help with what the server is doing.
>>
>> I=E2=80=99m attaching a network trace. The parts I=E2=80=99m interested =
in explaining
>> have to do with the kerberized backchannel for NFS4.0.
>>
>> A setup is client doing v3 and v4 mount and opening file with one
>> version and appending to it with a different version. Its opened with
>> 4.0 and got a delegation and it=E2=80=99s trying to write with v3 and se=
rver
>> is recalling a delegation
>>
>> Server is issuing CB_NULL gss_init trying to establish a gss context.
>> But it=E2=80=99s doing it twice in frame 259 and frame 261. It=E2=80=99s=
 weird that
>> it=E2=80=99s doing it twice. But Ok.
>
> I also wonder why the client sent two sets of
> SETCLIENTID/SETCLIENTID_CONFIRM calls.

The test does two different mounts and there is an unmount between
them. There is 4.0 mount, unmount. Then v3 mount, then v4 mount again.
I think that=E2=80=99s why there are 2 SETCLIENTIDs.

> The second gets back the same
> clientid as the first, so I think the only thing the server might do is
> update the callback information--but the callback information is the
> same in both cases.  Maybe some server bug is causing it not to handle
> that update correctly?
>
> I also expect the server to start a CB_NULL as soon as it gets the
> setclientid_confirm, so I would have expected to see that sooner.

That=E2=80=99s true but I have seen when CB_NULL doesn=E2=80=99t happen rig=
ht away. So
this happens once in a while, don=E2=80=99t know why...

>> Now in frame, 283 it sends CB_COMPOUND CB_RECALL And in frame 285 it
>> sends CB_NULL with gss_data with the CB_NULL as the payload. I think
>> this is to establish the callback.
>>
>> In frame 287, client responds with RPC accept state of 6000 (which I
>> believe is "drop reply").
>
> That value shouldn't ever appear on the wire.
>
> Looks like RHEL7 may need 0533b13072f4 "svc: Avoid garbage replies when
> pc_func() returns rpc_drop_reply".
>
> From nfs4_callback_compound, there are a couple reasons it might return
> rpc_drop_reply--might be a failure to recognize the callback principal?

So you think the callback server doesn=E2=80=99t need an initial NULL call
before able to handle CB_RECALL?

>
>> I believe what=E2=80=99s happening is that because the client hasn=E2=80=
=99t received
>> CB_NULL that establishes a callback channel but got a CB_RECALL it=E2=80=
=99s
>> just ignoring it.
>
> I see two succesful CB_NULL calls and replies, so I think the context
> establishment worked.  I don't know why there's a third CB_NULL in frame
> 285.

The two CB_NULL calls are both gss_init calls. They are not RPC NULL
call. Server for some reason establishes 2 different gss context
(again not necessarily a problem). The 3rd CB_NULL is gss_data and it
sends an actual NULL call. I believe that=E2=80=99s the one that establishe=
s a
callback channel.

>
>> What happens later is that server re-transmits the CB_COMPOUND but
>> client replies out of the cache. What=E2=80=99s interesting is that by t=
his
>> time since CB_NULL that came after the CB_COMPOUND should have
>> established the callback and if the re-trasmission was instead a new
>> CB_RECALL, then it would have succeeded I would think. Server tries
>> twice and then finally, the sets the CB_PATH_DOWN on the RENEW that
>> client sends.
>>
>> Questions: 1. Do you see how CB_RECALL can travel before the callback
>> is established?
>
> I assume it's using the context established by one of the previous
> CB_NULLs.  I guess you could check the context handle to confirm this.

Both the CB_RECALL and CB_NULL carrying the NULL call that establishes
context use the gss_context established by the 2nd of the CB_NULL
calls.

I still believe that CB_RECALL was sent incorrectly as a callback
channel has not been established.

>> 2. Should the server do something else beside
>> re-transmitting the CB_RECALL because it got this =E2=80=9Cdrop reply=E2=
=80=9D error
>> code back?
>
> Since the reply isn't really valid, I think retrying is the server's
> only option.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
