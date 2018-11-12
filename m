Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B46A1C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 14:21:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 809002241E
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 14:21:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 809002241E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729426AbeKMAOo convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Nov 2018 19:14:44 -0500
Received: from mail-wr1-f49.google.com ([209.85.221.49]:43471 "EHLO
        mail-wr1-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729380AbeKMAOn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2018 19:14:43 -0500
Received: by mail-wr1-f49.google.com with SMTP id y3-v6so9532507wrh.10
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2018 06:21:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:content-transfer-encoding;
        bh=B27Ah6bSDzRruukuizb1uenXUbyS3LwDSBnkfOtwzvA=;
        b=cKnnGFJIlItmWKXGnT7XeP5BPiIpGmabHi+ZR5nVVzpoGTe9f+rKH9TRIBre/hhWEL
         RxzFiWa1aUN8AD7OWcg7HVEOraIpw5wqBJ+3jxUiwrmud1OtKNLatf6l1X6YcwANjVl9
         juJLtUNRY0DA5SX8UT81oRRQKfgcawMivDfGd8iqYAgWerUmWOK6UTi4GvuNiHrxGwTo
         mjVVzdu6tofvpNSimW3qOGBRreSB2xZeLnmMHxPSS8nHxYNDJMiJxYoca+DSUk31X/8H
         4pGcCYcKHm3fGnDacn9htDiaP2VJJNZ5fn1PmMj3gB3TwGunCfAR7o8osmyyELDnJ/lQ
         LCgQ==
X-Gm-Message-State: AGRZ1gKSocUn+JSvJxsMB3nLE4XXEVm4InEkHhFTGV/pobV6Vbrt1DCg
        /44c+iX/TuHf8l6hOVJNzhy3YSq8yIQ6QTir+Po1f9KE
X-Google-Smtp-Source: AJdET5eINoS9b67d1c5OjS/kTeEn+l36Xlfoffjgz3ZccBlE6lZ0N3Va4p7FcsxHPD/ZbJeM6Jhx67CkhIjXPlxyDYw=
X-Received: by 2002:adf:80c8:: with SMTP id 66-v6mr1147774wrl.57.1542032473746;
 Mon, 12 Nov 2018 06:21:13 -0800 (PST)
MIME-Version: 1.0
References: <b608aeda-358d-18c9-ebcd-753b698580e9@candelatech.com>
 <20181108011429.GC30776@fieldses.org> <efe334ad-4905-fc24-1b36-3c4129b72888@candelatech.com>
 <20181108153136.GA4947@fieldses.org> <90f8e9ba-3953-e2d1-56f4-421a4991cef8@candelatech.com>
 <74f0a2e8-f631-8d8d-5b98-8248dadf5aa6@redhat.com> <d0a3a3fd-4952-db37-4ca7-54391edc3c48@candelatech.com>
 <CAGKpdE9YMQNisieoOUbenwA8a7PhTngLTX=v8Bkznfqc2816dQ@mail.gmail.com>
In-Reply-To: <CAGKpdE9YMQNisieoOUbenwA8a7PhTngLTX=v8Bkznfqc2816dQ@mail.gmail.com>
From:   David Windsor <dwindsor@redhat.com>
Date:   Mon, 12 Nov 2018 09:21:02 -0500
Message-ID: <CAGKpdE-UEG1ax_cDwXbnkXvm4J07QOgO6S8AV4N1Qm9aqH9ASA@mail.gmail.com>
Subject: Fwd: Support for VRF in NFS?
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Forwarding to linux-nfs because I forgot to disable HTML formatting
when originally replying.

---------- Forwarded message ---------
From: David Windsor <dwindsor@redhat.com>
Date: Mon, Nov 12, 2018 at 9:13 AM
Subject: Re: Support for VRF in NFS?
To: <greearb@candelatech.com>
Cc: swhiteho <swhiteho@redhat.com>, <bfields@fieldses.org>,
<linux-nfs@vger.kernel.org>


Hi,

On Fri, Nov 9, 2018 at 9:48 AM Ben Greear <greearb@candelatech.com> wrote:
>
>
>
> On 11/09/2018 01:59 AM, Steven Whitehouse wrote:
> > Hi,
> >
> >
> > On 08/11/18 16:35, Ben Greear wrote:
> >>
> >>
> >> On 11/08/2018 07:31 AM, J. Bruce Fields wrote:
> >>> On Wed, Nov 07, 2018 at 09:08:16PM -0800, Ben Greear wrote:
> >>>>
> >>>>
> >>>> On 11/07/2018 05:14 PM, J. Bruce Fields wrote:
> >>>>> On Tue, Nov 06, 2018 at 01:03:54PM -0800, Ben Greear wrote:
> >>>>>> Hello,
> >>>>>>
> >>>>>> I made a stab at implementing VRF support in NFS, but it appears
> >>>>>> fairly complicated and I ended up reverting my changes....
> >>>>>>
> >>>>>> Is anyone working on this?
> >>>>>>
> >>>>>> And, if not, if anyone would like to be sponsored to work on this, please
> >>>>>> let me know.
> >>>>>
> >>>>> Um, sorry--what's VRF?
> >>>>
> >>>> Virtual Router logic.  It is sort of like network stack containers,
> >>>> and has been solid and fully featured in the kernel since 4.16 or so.
> >>>>
> >>>> In the end, you effectively need to call the logic that SO_BINDTODEVICE
> >>>> calls on the socket before binding to an IP.
> >>>>
> >>>> The NFS and RPC logic is a giant tangled mess to my eyes, so
> >>>> hoping I could bribe someone else to do it :)
> >>>
> >>> So it's not enough to support network namespaces?
> >>>
> >>> What's your motivation for this?
> >>
> >> Network namespaces are difficult to uses for lots of use cases, and thus VRF
> >> was born.
> >>
> >> My own motivation is that it allows me to make hundreds or thousands
> >> of individual NFS mounts from local mac-vlan (or other virtual/physical interfaces),
> >> for testing purposes.
> >>
> >> Similar to my patch set that binds to local IP address, which gives similar feature
> >> set for non-VRF configurations.  These bind-local-IP patches are not upstream and were rejected in
> >> the past as un-wanted.  I'm hoping VRF support would be more acceptable.
> >>
> >> Thanks,
> >> Ben
> >>
> >
> > For similar reasons David Windsor has been looking at some extensions for DLM along these lines. Improving our ability to test seems to me like it should be a good thing to do - in both cases. Likewise VRF support seems also like it should be useful in a number of contexts.
> >
> > Do you have a reference to your past work? I think it would be interesting to get some discussion going here - maybe it would be possible to have some common approach between kernel-side socket users, and/or bounce some ideas around,
> >


Did you have anything specific in mind here?  AFAICT, the separation
provided by VRF wouldn't buy us much over using SO_MARK/iptables with
DLM.

With respect to a common approach between kernel-side socket users, I
would be interested in seeing if we could come up with something here.
In the case of DLM, the changes needed to support *just* multihoming
could perhaps be abstracted into some sort of higher layer, but the
bits required to support failover to other interfaces are fairly
specific to the DLM protocol itself (i.e. adding sequence numbers to
DLM messages, etc.).

Thanks,
David

>
> > Steve.
>
> Here is an old thread on the topic.
>
> https://www.spinics.net/lists/linux-nfs/msg34811.html
>
> My patches are in all my 'ct' kernels, and the needed patches are also in my nfs-utils repo.
>
> My 4.19 tree has just been ported, so no idea if it works or not.
>
> https://github.com/greearb?tab=repositories
>
> My patch work fine using routing table rules without VRF, but they will not work with VRF.
>
>
> Thanks,
> Ben
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
