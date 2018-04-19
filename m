Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:44554 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752413AbeDSPKJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2018 11:10:09 -0400
Received: by mail-ua0-f182.google.com with SMTP id r16so3652772uak.11
        for <linux-nfs@vger.kernel.org>; Thu, 19 Apr 2018 08:10:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180417132156.GA10291@parsley.fieldses.org>
References: <680B7A1A-792A-4B9E-A0CA-46E459B65077@netapp.com>
 <20180416212942.GA2634@parsley.fieldses.org> <EC52DFFD-CB6F-45F5-BAB9-C684C205DE26@netapp.com>
 <20180417132156.GA10291@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 19 Apr 2018 11:10:06 -0400
Message-ID: <CAN-5tyEW+vZ1gYeP8zey1SkvuzXsJwdmrG=ZEXi6XXEVNM9Z_w@mail.gmail.com>
Subject: Re: nfsd issue with a kerberized callback
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 9:21 AM, J. Bruce Fields <bfields@redhat.com> wrote=
:
> On Mon, Apr 16, 2018 at 08:05:44PM -0400, Olga Kornievskaia wrote:
>> > On Apr 16, 2018, at 5:29 PM, J. Bruce Fields <bfields@redhat.com> wrot=
e:
>> >> I believe what=E2=80=99s happening is that because the client hasn=E2=
=80=99t received
>> >> CB_NULL that establishes a callback channel but got a CB_RECALL it=E2=
=80=99s
>> >> just ignoring it.
>> >
>> > I see two succesful CB_NULL calls and replies, so I think the context
>> > establishment worked.  I don't know why there's a third CB_NULL in fra=
me
>> > 285.
>>
>> The two CB_NULL calls are both gss_init calls. They are not RPC NULL cal=
l. Server for some reason establishes 2 different gss context (again not ne=
cessarily a problem). The 3rd CB_NULL is gss_data and it sends an actual NU=
LL call. I believe that=E2=80=99s the one that establishes a callback chann=
el.
>
> Oh, I see.  No, that NULL call isn't necessary.  It's just the server
> probing to see whether the callback channel works.  That NULL call isn't
> required by the spec and everything should still work if the CB_RECALL
> is sent out before it completes.

Ok thank you. Another question: can the nfsd decide to give out
delegation regardless of the existence of the callback path? Looking
at the nfsd open code I see that it checks if cl_cb_state is
NFSD4_CB_UP. But I guess somehow (according to this trace), it finds
it up? Any ideas, looks like a bug...

On this particular network trace, in frame 240, the server gives out
the read delegation (which is later on it's trying to recall). However
the setup of the callback path(s) doesn't happen until frames 259/261
(tcp connections are established starting from frames 253/256).

Goal is to try and reproduce this problem where the client is failing
the CB_RECALL... but so far I can't trigger this.

Also I figured out why there are 2 SETCLIENTIDs and it's not because
of the 2 mounts (with unmount in the middle). First SETCLIENTID is
trunking discovery. Second SETCLIENTID is for when client is trying to
do an operation requiring a clientid. Therefore this leads to
existence of 2 callback paths (ie 2 CB_NULL gss context
establishment). I'm not sure if this is somehow incorrect that client
provides 2 callback path and server establishes context for both.
