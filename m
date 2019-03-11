Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 790FAC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:14:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48CC8206BA
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 15:14:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="gRyWnmrM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727320AbfCKPOx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 11:14:53 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:39328 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727216AbfCKPOx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Mar 2019 11:14:53 -0400
Received: by mail-vs1-f68.google.com with SMTP id w14so2922058vso.6
        for <linux-nfs@vger.kernel.org>; Mon, 11 Mar 2019 08:14:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=emPOYlFok5aQSz4Wvx5YA4FdSgMlD8tynKOnVHHMsWE=;
        b=gRyWnmrMRHde7dEhzIakfa+CiJ3uLtLLR2TB3bCX7DtDprNp0GRX4mFWVpdiGBJwwH
         NWdL9ZApzHcr4PFdbE+wxRtE/7BmSZ2cnddQXssU0NBCv04PIkJ4LRU51w/+bAmz9Uhf
         pKtUHTEh65b9XZl54kSknQmWldvJFbJPSPhCFQvwzaLPkklwYmCQlQM3VO9DyEdx+hh8
         TGqFBT3QX/+QJPSFNZvBhKvLexbO5b/+1DzEypVDMALi4YeNJ0LFmAYmH28yUyOC2KoB
         2K+hIpW+PYF0j9Bqllo/1+FfXSeIljN2csWiyD7QR3ZFy+QrTg9WpdFcB5sPaCAIs/Tn
         ecfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=emPOYlFok5aQSz4Wvx5YA4FdSgMlD8tynKOnVHHMsWE=;
        b=aV4KFWj+iE4ZN3LkRVqhO63uOkZVEi7yrhJHb6+Wj6ve1O552R/sY6w0JiTzDABd+W
         65FTgxTnHcQt5U7f3vsUHZoaAQSAEau3Av4COU5TTiYvedyMSXQCTLnTlKIk/pO66jNA
         btrjKsQiyZRX6FhjxM+SbuDbm11vDSsMmVNyZ6i3TEdpo6sOgSUMUasRWqBrdTHA1lw/
         POt6Ff9lEYxHERqen+B13AhSJSLMQI1c2EmggFRqRkIZYdjr95PfqUjlzv1Ofmeo8kqN
         ZypwmwJMwnWZdkfwCCIUcV2SfhQCCZFDjr18brOKA4YE/DjNU93/5H6i3s79LC6SPAB8
         wRiQ==
X-Gm-Message-State: APjAAAX5vdYfuEp9GGbclehJ+4JW9eC7buGEvvqg/l1RdR3SaAVO+DiF
        ypaNtlGJkISq0zbzsqfCYWKm5F52snI15kwIB8I=
X-Google-Smtp-Source: APXvYqxMGUa+ayNKB4BNd78AZ2rpjisZLDb6CFpo6bnqIuziX9onvNxtHRsYDrjWxHLAhHYkZxRGmgxliu9fm378E1o=
X-Received: by 2002:a67:3112:: with SMTP id x18mr16137555vsx.194.1552317292167;
 Mon, 11 Mar 2019 08:14:52 -0700 (PDT)
MIME-Version: 1.0
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com> <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com> <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com> <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com> <20190306160934.GB3066@fieldses.org>
 <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
 <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com> <7824abe2b39fef6c5e1cd9cc53732fc91728871c.camel@hammerspace.com>
In-Reply-To: <7824abe2b39fef6c5e1cd9cc53732fc91728871c.camel@hammerspace.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 11 Mar 2019 11:14:41 -0400
Message-ID: <CAN-5tyH52dv7zuCkQoUS04rpbqotWn+SM1rJoxqBgsWG2bKLcg@mail.gmail.com>
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

On Mon, Mar 11, 2019 at 11:12 AM Trond Myklebust
<trondmy@hammerspace.com> wrote:
>
> On Mon, 2019-03-11 at 14:30 +0000, Trond Myklebust wrote:
> > Hi Olga,
> >
> > On Sun, 2019-03-10 at 18:20 -0400, Olga Kornievskaia wrote:
> > > There are a bunch of cases where multiple operations are using the
> > > same seqid and slot.
> > >
> > > Example of such weirdness is (nfs.seqid == 0x000002f4) &&
> > > (nfs.slotid
> > > == 0) and the one leading to the hang.
> > >
> > > In frame 415870, there is an OPEN using that seqid and slot for the
> > > first time (but this slot will be re-used a bunch of times before
> > > it
> > > gets a reply in frame 415908 with the open stateid seq=40).  (also
> > > in
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
>
> This should result in exactly 1 bump of the stateid seqid.
>
> > > Client in all this mess never processes the open stateid seq=40 and
> > > keeps on resending CLOSE with seq=37 (also to note client "missed"
> > > processing seqid=38 and 39 as well. 39 probably because it was a
> > > reply
> > > on the same kind of "Reused" slot=1 and seq=0x000128f7. I haven't
> > > tracked 38 but i'm assuming it's the same). I don't know how many
> > > times but after 5mins, I see a TEST_STATEID that again uses the
> > > same
> > > seqid+slot (which gets a reply from the cache matching OPEN). Also
> > > open + close (still with seq=37) open is replied to but after this
> > > client goes into a soft lockup logs have
> > > "nfs4_schedule_state_manager:
> > > kthread_ruan: -4" over and over again . then a soft lockup.
> > >
> > > Looking back on slot 0. nfs.seqid=0x000002f3 was used in
> > > frame=415866
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
> >
>
>
> Note also that what you describe would appear to indicate a serious
> server bug. If the client is reusing a slot+seqid, then the correct
> server behaviour is to either return one of the errors NFS4ERR_DELAY,
> NFS4ERR_SEQ_FALSE_RETRY, NFS4ERR_RETRY_UNCACHED_REP,
> NFS4ERR_SEQ_MISORDERED, or else it must replay the exact same reply
> that it had cached for the original request.
>
> It is protocol violation for the server to execute new requests on a
> slot+seqid combination that has already been used. For that reason, it
> is also impossible for a replay to cause further state changes on the
> server; a replay means that the server belts out the exact same reply
> that was attempted sent earlier with no changes (with stateids that
> match bit for bit what would have been sent earlier).
>

But it is the same requests because all of them are opens on the same
file same everything.

> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
