Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33353 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755093AbdCaUoo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Mar 2017 16:44:44 -0400
Received: by mail-io0-f194.google.com with SMTP id f84so6981299ioj.0
        for <linux-nfs@vger.kernel.org>; Fri, 31 Mar 2017 13:44:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170309202610.GF3929@fieldses.org>
References: <b321152e-cbe8-94b3-498c-1d32e7c7be2d@gmail.com>
 <1488885081.2788.0.camel@redhat.com> <20170309202610.GF3929@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 31 Mar 2017 16:44:43 -0400
Message-ID: <CAN-5tyGdGQ8q_D=w673Bmo-6njgsSB94kT93BJRaSzODZgo7zg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC/backchanel: set XPT_CONG_CTRL flag for bc xprt
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bruce,

When is this going to go upstream?

On Thu, Mar 9, 2017 at 3:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Thanks!  Applying.--b.
>
> On Tue, Mar 07, 2017 at 06:11:21AM -0500, Jeff Layton wrote:
>> On Tue, 2017-03-07 at 17:22 +0800, Kinglong Mee wrote:
>> > The xprt for backchannel is created separately, not in TCP/UDP code.
>> > Because without the flags, the requests from NFSv41 backchannel are
>> > rejected in svc_process_common(),
>> >
>> > 1191         if (versp->vs_need_cong_ctrl &&
>> > 1192             !test_bit(XPT_CONG_CTRL, &rqstp->rq_xprt->xpt_flags))
>> > 1193                 goto err_bad_vers;
>> >
>> > Fixes: 5283b03ee5 ("nfs/nfsd/sunrpc: enforce transport...")
>> > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> > ---
>> >  net/sunrpc/svcsock.c | 1 +
>> >  1 file changed, 1 insertion(+)
>> >
>> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> > index 8931e33..2b720fa 100644
>> > --- a/net/sunrpc/svcsock.c
>> > +++ b/net/sunrpc/svcsock.c
>> > @@ -1635,6 +1635,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
>> >
>> >     xprt = &svsk->sk_xprt;
>> >     svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
>> > +   set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
>> >
>> >     serv->sv_bc_xprt = xprt;
>> >
>>
>> Good catch.
>>
>> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
