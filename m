Return-Path: <SRS0=yRiJ=RN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 446F3C43381
	for <linux-nfs@archiver.kernel.org>; Sun, 10 Mar 2019 22:20:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E30F12077B
	for <linux-nfs@archiver.kernel.org>; Sun, 10 Mar 2019 22:20:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="pHI4dIyA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726751AbfCJWUS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 10 Mar 2019 18:20:18 -0400
Received: from mail-vs1-f44.google.com ([209.85.217.44]:40306 "EHLO
        mail-vs1-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726700AbfCJWUR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2019 18:20:17 -0400
Received: by mail-vs1-f44.google.com with SMTP id z18so1594694vso.7
        for <linux-nfs@vger.kernel.org>; Sun, 10 Mar 2019 15:20:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cIpK/CwyhVtc8zeR8fOw/LJcJZXps29DGKD5QFASBqY=;
        b=pHI4dIyAaj8TjFUHK8KmWuEM7a2oHqRmbnhyPGG7qHKJyINqTWkKqyjmS11OFLIqQk
         67Qe8svH73cGOuK+SDS4K4LMSCPPqnxGxefMs6/63TUvFRi7QECHCixnq2gTY3JG5jgp
         1+lWwLKAXnn3apjJzoJOunQ8XsAmDJzwDitgPDpvQ5gU0h9BhJFrysmNFgAcd5DwCCIh
         SwyiL6lM7qy74hI7G5BkIPVgxyrY962kY99r0A2DG7BPmgtz5zi4BSZMA/cT203tYMJY
         9tyR5esb01Aa+8k1C0EMJXmAb+9pR810y/RgUo9mfhiuxhywoDMKdLfDnPAyfj0/3zcP
         dRtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=cIpK/CwyhVtc8zeR8fOw/LJcJZXps29DGKD5QFASBqY=;
        b=aUZCXrg2uxu3KhCzktcJtmCf0jrxsf/oeCLH82O5UCrVvLH2I/vz7gZXE2PEksWMk/
         06JsUWyuul3P5CuNggtKJH1c8Zc/4N57tn13iyvZKjooquzcpHjIq7N5EDbveu57hMXR
         vyKSkAlwh+iwBpyc5wPLZFqm4UadarOavvhRHQw9mskiMo0K0MVdhuMdAE0+qJXkFwk0
         UCMyOzWXogqLiQn0hnpz/PkxOjlS3M1RWxk20znHjRjMP4c6WPCPFg0Pv0ms3YmiqGSI
         Y3aTeiLDz3bBMLTiN22pxhXqzcYpjPqvNOln7LCJXl52jyvYubWfLnm2riRozw4V+6+J
         mIBA==
X-Gm-Message-State: APjAAAWRNHC0AicupQFo0APhZBydPLLsIZpMo8EDoWmkQMI4T+Nh4ROq
        jaqFrSd7YpwckvUwj1Bb2AP8953k2MLYDYMHHf48uTSe
X-Google-Smtp-Source: APXvYqyBTANy0FgLV3dukIBR0O9Ec9hgiNVzP8TMmRn4onvgaAiKbUgaGLypxFAUgurXliuVxAVcCxMw48hejg5xAfk=
X-Received: by 2002:a67:7488:: with SMTP id p130mr15247265vsc.164.1552256416273;
 Sun, 10 Mar 2019 15:20:16 -0700 (PDT)
MIME-Version: 1.0
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com> <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com> <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com> <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com> <20190306160934.GB3066@fieldses.org>
In-Reply-To: <20190306160934.GB3066@fieldses.org>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Sun, 10 Mar 2019 18:20:05 -0400
Message-ID: <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
To:     "bfields@fieldses.org" <bfields@fieldses.org>
Cc:     Jiufei Xue <jiufei.xue@linux.alibaba.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 6, 2019 at 11:09 AM bfields@fieldses.org
<bfields@fieldses.org> wrote:
>
> On Wed, Mar 06, 2019 at 05:59:39PM +0800, Jiufei Xue wrote:
> > Hi Trond,
> >
> > >
> > > No, that's quite weird... Were you able to catch this behaviour on
> > > wireshark? It would be interesting to see if the server is actually
> > > sending 2 SEQUENCE ops or if that is a corruption that occurs on the
> > > client.
> > >
> >
> > Many packages are dropped by kernel when I use tcpdump, so I am not sure
> > whether the server is sending 2 SEQUENCE.
>
> For what it's worth, tcpdump with -s200 or so should be enough to get
> this.  Or maybe capturing from a different machine could help?
>
> > However, according to tracepoint nfsd_compound_status, the server is
> > processing SEQUENCE op only once. I think it is more likely blames to
> > the client.
>
> If there was a bug in nfsd's xdr decoding, that'd happen after that
> tracepoint.  That'd be weird corruption, but perhaps all the
> possibilites are weird at this point.

This is not a bug in the Linux nfsd. I was able to reproduce it
against the Ontap server. I ran using the RHEL7.6 client (but it's
upsteram since Jiufei hit it). (I wanted to attach a trace but it
looks like it's too big as my first attempt at posting this was
unsuccessful. I can send a trace to a personal email if interested).

There are a bunch of cases where multiple operations are using the
same seqid and slot.

Example of such weirdness is (nfs.seqid == 0x000002f4) && (nfs.slotid
== 0) and the one leading to the hang.

In frame 415870, there is an OPEN using that seqid and slot for the
first time (but this slot will be re-used a bunch of times before it
gets a reply in frame 415908 with the open stateid seq=40).  (also in
this packet there is an example of reuse slot=1+seqid=0x000128f7 by
both TEST_STATEID and OPEN but let's set that aside).

In frame 415874 (in the same packet), client sends 5 opens on the SAME
seqid and slot (all have distinct xids). In a ways that's end up being
alright since opens are for the same file and thus reply out of the
cache and the reply is ERR_DELAY. But in frame 415876, client sends
again uses the same seqid and slot  and in this case it's used by
3opens and a test_stateid.

Client in all this mess never processes the open stateid seq=40 and
keeps on resending CLOSE with seq=37 (also to note client "missed"
processing seqid=38 and 39 as well. 39 probably because it was a reply
on the same kind of "Reused" slot=1 and seq=0x000128f7. I haven't
tracked 38 but i'm assuming it's the same). I don't know how many
times but after 5mins, I see a TEST_STATEID that again uses the same
seqid+slot (which gets a reply from the cache matching OPEN). Also
open + close (still with seq=37) open is replied to but after this
client goes into a soft lockup logs have "nfs4_schedule_state_manager:
kthread_ruan: -4" over and over again . then a soft lockup.

Looking back on slot 0. nfs.seqid=0x000002f3 was used in frame=415866
by the TEST_STATEID. This is replied to in frame 415877 (with an
ERR_DELAY). But before the client got a reply, it used the slot and
the seq by frame 415874. TEST_STATEID is a synchronous and
interruptible operation. I'm suspecting that somehow it was
interrupted and that's who the slot was able to be re-used by the
frame 415874. But how the several opens were able to get the same slot
I don't know..

Regardless of how we got into the soft lockup. Client shouldn't be
using the same slot+seqid on multiple operations.
>
> --b.
>
> > Is there any other way to catch the behaviour?
> >
> > Thanks,
> > Jiufei
> >
