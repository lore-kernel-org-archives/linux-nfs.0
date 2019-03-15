Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B85A9C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:34:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 598982186A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 20:34:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="MHewWg9g"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726442AbfCOUeJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 16:34:09 -0400
Received: from mail-ua1-f49.google.com ([209.85.222.49]:40146 "EHLO
        mail-ua1-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726097AbfCOUeJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 16:34:09 -0400
Received: by mail-ua1-f49.google.com with SMTP id b8so1899701uaq.7
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 13:34:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=r0Twu6qThUkiSKFsVzACgYiTbAxk4osKQA6MPl5Izro=;
        b=MHewWg9ggWeoWZon1JSKcJbg0IRGHwNP14+1VFaEpvmQfSbBtnQZsGwLrcL7ZrfHFz
         HSbbqHYcEDvBqxSHjM3UuvT3zov6DRGbJhFi+1XSOwdF4ZVwfDPXnQb5Yy0oySsC01U7
         Mup/y4+3vh4+qiRvr7U5PYCFepxw2YR7m9Mi9mDJuu6BuV+uhDzcvQ1Ox1OXqKa+rUOD
         cupCrlU9qSjrs6v4ncLt0PwYxbrEN/glzoA2gBeNJdDajutRvDD3tM/p5O/EYSJqOyge
         x891s31rZpE/lGJ/V6ZJAmpY1QKfsoF5Wq38Zm3BtncGDewYoNLQKN7jt8aFXA/E+Bh5
         RMIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=r0Twu6qThUkiSKFsVzACgYiTbAxk4osKQA6MPl5Izro=;
        b=FZYo2Z630I/6D85TYTIgFtfAI8p2fB8J/FLONfOdhTL9oQsAPZvIri8h+SIoOTj+Qa
         gfWVOP39QjiS/j3Mag+uFKUUJ88di8V7HOM89Oex1eEnuXNuRrzXUa7URBHeO3kHpsaA
         SyyABuuCh8Fr6nQyOZFOhU1xwOR7S3WMIlhl6WdzLoAfy1JPk/CMHisflCi8i3RfYRXR
         hhHG5KMYPQvba80gepcPhDiiXBzx1XdZhMMO1XTSCpogFLUVwv4zOeaYqdU8kTDmGW9D
         RRT1bt236OzJUD6p0qesIP8Y+yQpltXSvV/RuNt5j+Wt38wc3E5xmRgd6kZ3v4RDPNKu
         ifjA==
X-Gm-Message-State: APjAAAULKVyn+Rmz74hg8DqGDQnZqSsz64E4HdvsGtokQWK3TNduWOA3
        ezwfIirW0J4zLxvD8aMreEVlgI3PACSOyGqiDqkuBMjA
X-Google-Smtp-Source: APXvYqx7KhtyJzvoQX4rwg2PrqCGRw3gCsYgTPeyygFj5IJ9N7Uu5P1EMCcASs5R6iGNypM6ZRVCPE0WeAcgvXHie50=
X-Received: by 2002:ab0:156e:: with SMTP id p43mr772474uae.66.1552682048557;
 Fri, 15 Mar 2019 13:34:08 -0700 (PDT)
MIME-Version: 1.0
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com> <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com> <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com> <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com> <20190306160934.GB3066@fieldses.org>
 <CAN-5tyEPSDKao=83sW+voU9SPbcszZyR+XfZzcsD2-ozVa22Xg@mail.gmail.com>
 <ace3659edd3efb70d3d978e108ecf1fc22ee3966.camel@hammerspace.com>
 <CAN-5tyH8hFmEsAKDMDL4uey0MXh9+kY43=LEpgjj711eVUubAA@mail.gmail.com>
 <CAN-5tyEAfV_WA3Vyf8LQ-EN4yn99p1sk7fuu7n43t8H8+un2Yw@mail.gmail.com> <37b3d7db-0bdf-014a-adff-ea401ea92fc7@linux.alibaba.com>
In-Reply-To: <37b3d7db-0bdf-014a-adff-ea401ea92fc7@linux.alibaba.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 15 Mar 2019 16:33:57 -0400
Message-ID: <CAN-5tyFHD5ZCqZ59GJzf_CAaJQZ7OXEhaxtYaSDAdXMLSA-xDA@mail.gmail.com>
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

On Fri, Mar 15, 2019 at 2:31 AM Jiufei Xue <jiufei.xue@linux.alibaba.com> w=
rote:
>
> Hi Olga,
>
> On 2019/3/11 =E4=B8=8B=E5=8D=8811:13, Olga Kornievskaia wrote:
> > Let me double check that. I have reproduced the "infinite loop" or
> > CLOSE on the upstream (I'm looking thru the trace points from friday).
>
> Do you try to capture the packages when reproduced this issue on the
> upstream. I still lost kernel packages after some adjustment according
> to bfield's suggestion :(

Hi Jiufei,

Yes I have network trace captures but they are too big to post to the
mailing list. I have reproduced the problem on the latest upstream
origin/testing branch commit "SUNRPC: Take the transport send lock
before binding+connecting". As you have noted before infinite loops is
due to client "losing" an update to the seqid.

one packet would send out an (recovery) OPEN with slot=3D0 seqid=3DY.
tracepoint (nfs4_open_file) would log that status=3DERESTARTSYS. The rpc
task would be sent and the rpc task would receive a reply but there is
nobody there to receive it... This open that got a reply has an
updated stateid seqid which client never updates. When CLOSE is sent,
it's sent with the "old" stateid and puts the client in an infinite
loop. Btw, CLOSE is sent on the interrupted slot which should get
FALSE_RETRY which causes the client to terminate the session. But it
would still keep sending the CLOSE with the old stateid.

Some things I've noticed is that TEST_STATE op (as a part of the
nfs41_test_and _free_expired_stateid()) for some reason always has a
signal set even before issuing and RPC task so the task never
completes (ever).

I always thought that OPEN's can't be interrupted but I guess they are
since they call rpc_wait_for_completion_task() and that's a killable
event. But I don't know how to find out what's sending a signal to the
process. I'm rather stuck here trying to figure out where to go from
there. So I'm still trying to figure out what's causing the signal or
also how to recover from it that the client doesn't lose that seqid.

>
> Thanks,
> Jiufei
