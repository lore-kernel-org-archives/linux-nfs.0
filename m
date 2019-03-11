Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3C36C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:13:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8188A206BA
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:13:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="gmp288xp"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726675AbfCKPNN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 11:13:13 -0400
Received: from mail-ua1-f68.google.com ([209.85.222.68]:39248 "EHLO
        mail-ua1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725845AbfCKPNM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Mar 2019 11:13:12 -0400
Received: by mail-ua1-f68.google.com with SMTP id s15so1636190uap.6
        for <linux-nfs@vger.kernel.org>; Mon, 11 Mar 2019 08:13:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W5Bm3UK1sYUTkREvkZKMr2r5k8diW8OqvDOfQTuXmhk=;
        b=gmp288xpaFrjVwb37PfMoYjTzziYLrlcIj94mV8GmIfw/hH/evyGBuRkFhHScAIm+l
         iY70lLk8zdRkLgTCb/vTVYPBXXa4oVZv3EJAwDOlUKYeTeQaF00KJCFTfQU/psliuN8B
         LouZplTgbFph4yEiM/2vVu9IfdXgcougJ0g6RakatXdKLmpiTa6XXdGpPlSSa/NMahZd
         YCSN5ZHNY/VOmszjBCQN738cWc91MtI9lyEmlm71AdB/lvHeSZGpbp0vXNq/FSvumdjD
         gWLQWjbE3sutZtikxpntzOOBNk/3ZZ+oybGg5g0ULguLvnBuMYm6cdgqqSOdVBC9xcaP
         sedA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=W5Bm3UK1sYUTkREvkZKMr2r5k8diW8OqvDOfQTuXmhk=;
        b=i0L51kGdVnpWN992L72aNzYGGFMsosd1bCbv9PtO9cCaO2Gb0F3kH+C/pAdj3q2nY0
         IY/ZtlnK1rEPUGanaRMYHXAbmoFYmoigjF3T9FOzHlRRQcDDCrJpSdZByKlXEApCjWLp
         W+LZ2GO6GeJY+GGA1l5DSns+K83Ox8ixhGTm26cmD6EJ7HyOY498wuJZSUUq5ewY2eu5
         3MKicV7s70WgNtVbheGzK3hVGtCi8uPW3DwTlgOv69vxcUSdUFiytILnLOzJpWSxOx8Y
         o/OSPY4NoeJQhSewKNJP1GgXsaJQSRSsM/pBDIejnS+Fkd+s/aQK67db4/4LbnUVcVb+
         d3gw==
X-Gm-Message-State: APjAAAWpIP0NQGiEYCiPwm5EZPQ+N0AMijj7bfnRHxpo1COO5Ush1RNF
        SZEQ8/PuwaBrYG7eHkKPnH8DOwTztRJBr2sn9ec4Gg==
X-Google-Smtp-Source: APXvYqxkCvY0ya054G46EcEiZv6BWHBd8wYI1Gq42d7Ftc83HxHbA5E25oBklAe64Isg5CvmgTfKRJ+RQxCQlVzocME=
X-Received: by 2002:ab0:3011:: with SMTP id f17mr16714650ual.5.1552317191459;
 Mon, 11 Mar 2019 08:13:11 -0700 (PDT)
MIME-Version: 1.0
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com> <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com> <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com> <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com> <20190306160934.GB3066@fieldses.org>
 <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
 <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com> <CAN-5tyH8hFmEsAKDMDL4uey0MXh9+kY43=LEpgjj711eVUubAA@mail.gmail.com>
In-Reply-To: <CAN-5tyH8hFmEsAKDMDL4uey0MXh9+kY43=LEpgjj711eVUubAA@mail.gmail.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 11 Mar 2019 11:13:00 -0400
Message-ID: <CAN-5tyEAfV_WA3Vyf8LQ-EN4yn99p1sk7fuu7n43t8H8+un2Yw@mail.gmail.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "jiufei.xue@linux.alibaba.com" <jiufei.xue@linux.alibaba.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Mar 11, 2019 at 11:07 AM Olga Kornievskaia <aglo@umich.edu> wrote:
>
> On Mon, Mar 11, 2019 at 10:30 AM Trond Myklebust
> <trondmy@hammerspace.com> wrote:
> >
> > Hi Olga,
> >
> > On Sun, 2019-03-10 at 18:20 -0400, Olga Kornievskaia wrote:
> > > There are a bunch of cases where multiple operations are using the
> > > same seqid and slot.
> > >
> > > Example of such weirdness is (nfs.seqid == 0x000002f4) && (nfs.slotid
> > > == 0) and the one leading to the hang.
> > >
> > > In frame 415870, there is an OPEN using that seqid and slot for the
> > > first time (but this slot will be re-used a bunch of times before it
> > > gets a reply in frame 415908 with the open stateid seq=40).  (also in
> > > this packet there is an example of reuse slot=1+seqid=0x000128f7 by
> > > both TEST_STATEID and OPEN but let's set that aside).
> > >
> > > In frame 415874 (in the same packet), client sends 5 opens on the
> > > SAME
> > > seqid and slot (all have distinct xids). In a ways that's end up
> > > being
> > > alright since opens are for the same file and thus reply out of the
> > > cache and the reply is ERR_DELAY. But in frame 415876, client sends
> > > again uses the same seqid and slot  and in this case it's used by
> > > 3opens and a test_stateid.
> > >
> > > Client in all this mess never processes the open stateid seq=40 and
> > > keeps on resending CLOSE with seq=37 (also to note client "missed"
> > > processing seqid=38 and 39 as well. 39 probably because it was a
> > > reply
> > > on the same kind of "Reused" slot=1 and seq=0x000128f7. I haven't
> > > tracked 38 but i'm assuming it's the same). I don't know how many
> > > times but after 5mins, I see a TEST_STATEID that again uses the same
> > > seqid+slot (which gets a reply from the cache matching OPEN). Also
> > > open + close (still with seq=37) open is replied to but after this
> > > client goes into a soft lockup logs have
> > > "nfs4_schedule_state_manager:
> > > kthread_ruan: -4" over and over again . then a soft lockup.
> > >
> > > Looking back on slot 0. nfs.seqid=0x000002f3 was used in frame=415866
> > > by the TEST_STATEID. This is replied to in frame 415877 (with an
> > > ERR_DELAY). But before the client got a reply, it used the slot and
> > > the seq by frame 415874. TEST_STATEID is a synchronous and
> > > interruptible operation. I'm suspecting that somehow it was
> > > interrupted and that's who the slot was able to be re-used by the
> > > frame 415874. But how the several opens were able to get the same
> > > slot
> > > I don't know..
> >
> > Is this still true with the current linux-next? I would expect this
> > patch
> > http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commitdiff;h=3453d5708b33efe76f40eca1c0ed60923094b971
> > to change the Linux client behaviour in the above regard.
>
> Yes. I reproduced it against your origin/testing (5.0.0-rc7+) commit
> 0d1bf3407c4ae88 ("SUNRPC: allow dynamic allocation of back channel
> slots").

Let me double check that. I have reproduced the "infinite loop" or
CLOSE on the upstream (I'm looking thru the trace points from friday).

>
>
> >
> > Cheers
> >   Trond
> >
> > --
> > Trond Myklebust
> > Linux NFS client maintainer, Hammerspace
> > trond.myklebust@hammerspace.com
> >
> >
