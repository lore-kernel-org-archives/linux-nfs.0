Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 912F3C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 15:33:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3E74920811
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 15:33:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="o478iWbP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727670AbfCSPdY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 11:33:24 -0400
Received: from mail-vs1-f46.google.com ([209.85.217.46]:46582 "EHLO
        mail-vs1-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726876AbfCSPdY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 11:33:24 -0400
Received: by mail-vs1-f46.google.com with SMTP id w26so9476160vsk.13
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2019 08:33:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=bGDpfwsWabDHKnXFm2gbGgX8H1X1+lnEJNbWDskz/30=;
        b=o478iWbP0ocWUlkY7cQ2gt4whuKBjJeshbV8GZ93MYN7lblsMWhpqn4GLOQUU4Kgdj
         wUsEGgDaX1M5mZTUnYpU4yvLJgtnrrh+m8eyxB+jsZdtEtc6UMZ77LikrKs1tCTqT5oc
         xOWF7m4z+SWnacU7cSeKJHhIn5kQFmyoeU5v4ZogtDR+pTX8fJnOroxkaWvMMlI62/al
         Nn9Z16/MXotOQV4ZMUdZq9rJonjMYpq3O87sj6s5TJQ86KRy06uv6FsrailZLI0G+VKy
         rnB+OkHrP3PgyMuMki57enmSjUZVo+RawvZf3AjyQbfoR/gaTtPPrKAcciXOjxY8ZgSd
         1rCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=bGDpfwsWabDHKnXFm2gbGgX8H1X1+lnEJNbWDskz/30=;
        b=XmiFhSBUH600g7Mq1xsUwOThDcYWsR47X+ethRGzcACv5ubnfxRrWSOB9IF+K1BrJT
         dHCQntVRS1tGJxv9RKigpllpfRVPukR4wEvAjTKQRC8Iqp7cwECyVVRC48kUzmpWqes5
         zWGnYP7G7pZjHgg/Z5w/MLPE1GVrI+GKSyHR1xCKQCUXNfI7Izgp1EsO1E6Zbni3zKV5
         cGTqXyuH/dLjrr611WxSENdoSjVgwBz1+RgJ9PpOH/k63sgzqZjZIiTMOcUE1QooZ7Jp
         o55wPTKTHm4xuNpxlOETleO65fxH9bNF4Rzm67yYINpmNl820J73UnDEP99alRfbL3AS
         diWA==
X-Gm-Message-State: APjAAAV2gzbV68NF9c4NttbezCSIQ3t9PShLFOpjBMntq4tzc0gG19TS
        2Xy17xZxXzIfTF2BDIBPdmTUJ5xJLdBC2gdEPapZRHog
X-Google-Smtp-Source: APXvYqzpyhEa0Of/qYHtXcmR/s7xx5qizBGuZ0JsD3+l2KhKoMl4oLk6T7YkG9MP//MUP1O6SuLTQAI6D8b6WaxzAKE=
X-Received: by 2002:a67:74cd:: with SMTP id p196mr1705055vsc.215.1553009601917;
 Tue, 19 Mar 2019 08:33:21 -0700 (PDT)
MIME-Version: 1.0
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com> <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com> <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com> <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com> <20190306160934.GB3066@fieldses.org>
 <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
 <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
 <CAN-5tyH8hFmEsAKDMDL4uey0MXh9+kY43=LEpgjj711eVUubAA@mail.gmail.com>
 <CAN-5tyEAfV_WA3Vyf8LQ-EN4yn99p1sk7fuu7n43t8H8+un2Yw@mail.gmail.com>
 <37b3d7db-0bdf-014a-adff-ea401ea92fc7@linux.alibaba.com> <CAN-5tyFHD5ZCqZ59GJzf_CAaJQZ7OXEhaxtYaSDAdXMLSA-xDA@mail.gmail.com>
 <63f00c10-28f5-b1e6-dcf9-f85f5edbfabf@linux.alibaba.com>
In-Reply-To: <63f00c10-28f5-b1e6-dcf9-f85f5edbfabf@linux.alibaba.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Tue, 19 Mar 2019 11:33:10 -0400
Message-ID: <CAN-5tyHxQ7q9aR=dmS4_-b0269vcepjcv7r6W9-soDhp4McAKA@mail.gmail.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
To:     Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Mar 16, 2019 at 10:11 AM Jiufei Xue
<jiufei.xue@linux.alibaba.com> wrote:
>
>
> Hi Olga,
> On 2019/3/16 =E4=B8=8A=E5=8D=884:33, Olga Kornievskaia wrote:
> > On Fri, Mar 15, 2019 at 2:31 AM Jiufei Xue <jiufei.xue@linux.alibaba.co=
m> wrote:
> >>
> >> Hi Olga,
> >>
> >> On 2019/3/11 =E4=B8=8B=E5=8D=8811:13, Olga Kornievskaia wrote:
> >>> Let me double check that. I have reproduced the "infinite loop" or
> >>> CLOSE on the upstream (I'm looking thru the trace points from friday)=
.
> >>
> >> Do you try to capture the packages when reproduced this issue on the
> >> upstream. I still lost kernel packages after some adjustment according
> >> to bfield's suggestion :(
> >
> > Hi Jiufei,
> >
> > Yes I have network trace captures but they are too big to post to the
> > mailing list. I have reproduced the problem on the latest upstream
> > origin/testing branch commit "SUNRPC: Take the transport send lock
> > before binding+connecting". As you have noted before infinite loops is
> > due to client "losing" an update to the seqid.
> >
> > one packet would send out an (recovery) OPEN with slot=3D0 seqid=3DY.
> > tracepoint (nfs4_open_file) would log that status=3DERESTARTSYS. The rp=
c
> > task would be sent and the rpc task would receive a reply but there is
> > nobody there to receive it... This open that got a reply has an
> > updated stateid seqid which client never updates. When CLOSE is sent,
> > it's sent with the "old" stateid and puts the client in an infinite
> > loop. Btw, CLOSE is sent on the interrupted slot which should get
> > FALSE_RETRY which causes the client to terminate the session. But it
> > would still keep sending the CLOSE with the old stateid.
> >
> > Some things I've noticed is that TEST_STATE op (as a part of the
> > nfs41_test_and _free_expired_stateid()) for some reason always has a
> > signal set even before issuing and RPC task so the task never
> > completes (ever).
> >
> > I always thought that OPEN's can't be interrupted but I guess they are
> > since they call rpc_wait_for_completion_task() and that's a killable
> > event. But I don't know how to find out what's sending a signal to the
> > process. I'm rather stuck here trying to figure out where to go from
> > there. So I'm still trying to figure out what's causing the signal or
> > also how to recover from it that the client doesn't lose that seqid.
> >
> >>
> Thank you for you quick relpy.
>
> I have also noticed the ERESTARTSYS status for OPEN op, but I think it
> is returned by the open process which is woken in nfs4_run_open_task().
> I found that the decode routine nfs4_xdr_dec_open returned -121, which
> I thought is the root cause of this problem. Could you please post the
> content of the last OPEN message?


Hi Jiufei,

Yes I think that's why the update isn't happening because the
rpc_status isn't 0.

Trond,

rpc_status of the rpc tasks that were interrupted but are finishing
are not able to succeed because when they try to decode_sequence the
res->st_slot is NULL. Sequence op is not decoded and then when it
tries to decode the PUTFH it throws unexpected op (expecting PUTFH but
has SEQ still there instead).

res->st_slot is going away because after the open(s) were interrupted
and _nfs4_proc_open() returned an error (interrupted), it goes and
frees the slot.

Is it perhaps appropriate to only free the slot there when if
(!data->cancelled) free_slot() otherwise. Let the async RPC task
continue and once it's done it'll free the slot.

How's this for a proposed fix:
Subject: [PATCH 1/1] NFSv4.1 don't free interrupted slot on open

Allow the async rpc task for finish and update the open state if needed,
then free the slot. Otherwise, the async rpc unable to decode the reply.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4dbb0ee..96c2499 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2933,7 +2933,8 @@ static int _nfs4_open_and_get_state(struct
nfs4_opendata *opendata,
  }

 out:
- nfs4_sequence_free_slot(&opendata->o_res.seq_res);
+ if (!opendata->cancelled)
+ nfs4_sequence_free_slot(&opendata->o_res.seq_res);
  return ret;
 }




>
> Thanks,
> Jiufei.
>
>
>
> >> Thanks,
> >> Jiufei
> >
