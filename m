Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:43418 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752663AbeEVUvr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 16:51:47 -0400
Received: by mail-ua0-f193.google.com with SMTP id d4-v6so13249471ual.10
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 13:51:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <30255bb83a9b4df3f104e981788bb4f8df323b7e.camel@hammerspace.com>
References: <20180522184048.21586-1-kolga@netapp.com> <d9d84d1b2cdb6054aba1ed5124f4d632355dec0b.camel@hammerspace.com>
 <CAN-5tyEEVqnQgNJq_pbaujsVBeVQ0y0AwNgP=cJxA9aj2=o_9w@mail.gmail.com> <30255bb83a9b4df3f104e981788bb4f8df323b7e.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 22 May 2018 16:51:46 -0400
Message-ID: <CAN-5tyHo4HfsrfB37OjKXzruUSUmYwb1JqOBmJQwaO4dUJQpTg@mail.gmail.com>
Subject: Re: [PATCH 1/1] [SUNRPC] make sure to clone timeout values
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kolga@netapp.com" <kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2018 at 3:56 PM, Trond Myklebust
<trondmy@hammerspace.com> wrote:
> On Tue, 2018-05-22 at 15:28 -0400, Olga Kornievskaia wrote:
>> On Tue, May 22, 2018 at 3:03 PM, Trond Myklebust
>> <trondmy@hammerspace.com> wrote:
>> > On Tue, 2018-05-22 at 14:40 -0400, Olga Kornievskaia wrote:
>> > > From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
>> > >
>> > > For pNFS, the operations to DS currently timeout in 10s.
>> > > According
>> > > to the spec, the client must not be re-trying an NFSv4.1
>> > > operation
>> > > unless the connection was broken.
>> > >
>> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> > > ---
>> > >  net/sunrpc/clnt.c | 1 +
>> > >  1 file changed, 1 insertion(+)
>> > >
>> > > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> > > index 6e432ec..97517eb 100644
>> > > --- a/net/sunrpc/clnt.c
>> > > +++ b/net/sunrpc/clnt.c
>> > > @@ -668,6 +668,7 @@ struct rpc_clnt *
>> > >               .prognumber     = clnt->cl_prog,
>> > >               .version        = clnt->cl_vers,
>> > >               .authflavor     = flavor,
>> > > +             .timeout        = clnt->cl_timeout,
>> > >       };
>> > >       return __rpc_clone_client(&args, clnt);
>> > >  }
>> >
>> > What does this patch have to do with pNFS? That's the generic RPC
>> > client cloning API you are changing.
>> >
>> > The pNFS/files timeouts are intended to be set using the
>> > dataserver_retrans and dataserver_timeo module parameters described
>> > at
>> > the bottom of fs/nfs/filelayout/filelayoutdev.c
>>
>> Ok so perhaps the code needs to re-written so that it allows for the
>> DS to get an rpc client with its timeouts set. Which currently
>> doesn't
>> happen.
>>
>> From what I could tell the DS code tries to set the timeout values in
>> nfs4_set_ds_client() but that has no effect.
>>
>> nfs4_find_or_create_ds_client() calls rpc_clone_client_set_auth()
>> which creates an rpc client but the timeout that were set are ignored
>> and instead the rpc client is getting created with this 10s timeout.
>>
>> (but I thought that in general it made sense that a clone also copies
>> the timeout values)
>>
>
> It does not make sense when you consider that the timeout is a per-
> transport attribute.
>
> FWIW, I've no idea where this 10s timeout you are seeing is coming
> from. Perhaps it is worthwhile figuring that out first?

Besides the value of the 10s (which I also have been having a really
hard time figuring out) it's also the max timeout and the fact that,
after  the 10s are up it's giving up and failing the operation which
is then re-tried against the MDS. This shouldn't happen. So I felt
like even if that value was 60s, it shouldn't have timed out after 60s
and re-tried (without the fix that I'm proposing).

I'll give it a bit more to figure out where 10s is coming from.
