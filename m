Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:33975 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751914AbeERUCp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 16:02:45 -0400
Received: by mail-ua0-f193.google.com with SMTP id f22-v6so6152815uam.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 13:02:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1526670307.10011.20.camel@redhat.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
 <CAN-5tyGDGOqPKXKD+LQq8Ub3CUosmaaAq=ir3Gp7R3LKABwtEQ@mail.gmail.com> <1526670307.10011.20.camel@redhat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 18 May 2018 16:02:43 -0400
Message-ID: <CAN-5tyEreQF24jmybAULA8_8VCjwg_eCRazS1MYNwN1QecYDHA@mail.gmail.com>
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
To: Simo Sorce <simo@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 18, 2018 at 3:05 PM, Simo Sorce <simo@redhat.com> wrote:
> On Fri, 2018-05-18 at 14:53 -0400, Olga Kornievskaia wrote:
>> Hi Chuck,
>>
>> I'm not convinced that "srchost=" is necessary. I believe that
>> everything that is needed is suppose to be encoded in the "target="
>> option.
>>
>> I thought target just needed to correctly identify the domain for
>> which authentication is taking place. Then I think more changes should
>> be in nfs-utils to make sure that we find credentials for that
>> particular domain instead of going by the gethostbyname() results.
>
> What do you mean by "domain" here? Realm or hostname ?
> What if the multihomed service is part of multiple realms and even
> serves with multiple different hostnames ?

I meant the DNS domain name.

Let's set a side multi-kerberos domain scenarios here as the
implementation assumes a single domain right now. Otherwise we need to
send down in which kerberos realm authentication is happening.

I thought the problem is that nfs-utils looking for credentials quires
gethostbyname() which on a multihome machine returns an answer which
is insufficient accurately match among the key tab entries. I think we
instead need to be parsing the domain out of the
"target=<principal>@<targethost>.domain" and the look for the
"nfs@<srchost>.domain" match instead of looking for
"nfs@gethostbyname()" . Also kernel needs to make sure it's supplying
the correct "target=" entry.

> Simo.
>
>>
>> On Fri, May 18, 2018 at 11:39 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> > I've been experimenting with this series that modifies NFSD to
>> > discover and use the correct GSS service principal when constructing
>> > its NFSv4.0 callback channels. I'm interested in review of this
>> > approach. There are a couple of code comments marked with XXX that
>> > also need some attention.
>> >
>> > The rpc.gssd change mentioned in 1/4 is unremarkable and will be
>> > made available once there is consensus about the kernel changes
>> > in this series. No gssproxy changes are necessary.
>> >
>> > ---
>> >
>> > Chuck Lever (4):
>> >       sunrpc: Enable the kernel to specify the hostname part of service principals
>> >       sunrpc: Extract target name into svc_cred
>> >       nfsd: Use correct credential for NFSv4.0 callback with GSS
>> >       nfsd: Remove callback_cred
>> >
>> >
>> >  fs/nfsd/nfs4callback.c               |   29 ++++----------
>> >  fs/nfsd/nfs4state.c                  |   17 +++-----
>> >  fs/nfsd/state.h                      |    2 -
>> >  include/linux/sunrpc/svcauth.h       |    3 +
>> >  net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>> >  net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
>> >  6 files changed, 80 insertions(+), 61 deletions(-)
>> >
>> > --
>> > Chuck Lever
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Simo Sorce
> Sr. Principal Software Engineer
> Red Hat, Inc
>
