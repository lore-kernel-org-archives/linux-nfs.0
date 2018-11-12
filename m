Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C7A7C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 16:40:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 53C9A2241E
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 16:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53C9A2241E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729106AbeKMCeI convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Nov 2018 21:34:08 -0500
Received: from mail-wr1-f42.google.com ([209.85.221.42]:34622 "EHLO
        mail-wr1-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726221AbeKMCeI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2018 21:34:08 -0500
Received: by mail-wr1-f42.google.com with SMTP id j26-v6so10107713wre.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2018 08:40:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=9+fMSERECUURwYdhBCxpn+mTNZqYTpoftxTS3ySDEwc=;
        b=p9I13DNUGpoq2kX5CQol4NBuVw3OGoln740sRiKrY0xds96TQj2kfUPlusml8/8Mpu
         TUJy0AKTVR+ax7oHIJeT9l9IP2ALiVuL7QHmd0X4AwwDu4n6V7OhpsinUhBRiK2iFZ+A
         sZL8dF8k4C8RXRIkabTUXaOnlqa3isUeFMoeMUZ7WU1GPChPhbYW62yWuLLogmZ0R6c0
         7ZgPphh9iUzZay4fExNXMGIZKBGfkKAfwx2TdKZHc7l/BLGzDQA8omN1DsQH6tuyUh6U
         sWYBKXHL0dUh+cQPBH+oeDzH+wEgSgzP2Ga6OCg1M6i8qUnFKBGOFTfcMaO7EZJwZBVO
         /l2w==
X-Gm-Message-State: AGRZ1gIbrV8NRRfscKeo2wR6BjxpsiDBIwFAaBcL8g0hdH/f73RvEVDQ
        PeUeZCxcckgmxGgeMdY2RiMxt9TznUQDBlar2o1Bzg==
X-Google-Smtp-Source: AJdET5fy4aBJGzPiIY+8Q5lvXQpTSjlzMik6fTI9ww42KTDZUXrvvXysMhQdZcZk6i8TMl1b0ezcT9oZWaClN5+Q4n0=
X-Received: by 2002:adf:df82:: with SMTP id z2-v6mr1602363wrl.118.1542040805674;
 Mon, 12 Nov 2018 08:40:05 -0800 (PST)
MIME-Version: 1.0
References: <b608aeda-358d-18c9-ebcd-753b698580e9@candelatech.com>
 <20181108011429.GC30776@fieldses.org> <efe334ad-4905-fc24-1b36-3c4129b72888@candelatech.com>
 <20181108153136.GA4947@fieldses.org> <90f8e9ba-3953-e2d1-56f4-421a4991cef8@candelatech.com>
 <74f0a2e8-f631-8d8d-5b98-8248dadf5aa6@redhat.com> <d0a3a3fd-4952-db37-4ca7-54391edc3c48@candelatech.com>
 <CAGKpdE9YMQNisieoOUbenwA8a7PhTngLTX=v8Bkznfqc2816dQ@mail.gmail.com>
 <CAGKpdE-UEG1ax_cDwXbnkXvm4J07QOgO6S8AV4N1Qm9aqH9ASA@mail.gmail.com> <b8409915-0249-35e1-d6ee-86a1c65d2244@candelatech.com>
In-Reply-To: <b8409915-0249-35e1-d6ee-86a1c65d2244@candelatech.com>
From:   David Windsor <dwindsor@redhat.com>
Date:   Mon, 12 Nov 2018 11:39:54 -0500
Message-ID: <CAGKpdE9FzypnAN_g8g7bL=EGwaJCrPDJ0SAwNJSeU6sDss=ewA@mail.gmail.com>
Subject: Re: Fwd: Support for VRF in NFS?
To:     greearb@candelatech.com
Cc:     linux-nfs@vger.kernel.org, swhiteho <swhiteho@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 12, 2018 at 9:48 AM Ben Greear <greearb@candelatech.com> wrote:
>
>
>
> On 11/12/2018 06:21 AM, David Windsor wrote:
> > Forwarding to linux-nfs because I forgot to disable HTML formatting
> > when originally replying.
> >
> > ---------- Forwarded message ---------
> > From: David Windsor <dwindsor@redhat.com>
> > Date: Mon, Nov 12, 2018 at 9:13 AM
> > Subject: Re: Support for VRF in NFS?
> > To: <greearb@candelatech.com>
> > Cc: swhiteho <swhiteho@redhat.com>, <bfields@fieldses.org>,
> > <linux-nfs@vger.kernel.org>
> >
> >
> > Hi,
> >
> > On Fri, Nov 9, 2018 at 9:48 AM Ben Greear <greearb@candelatech.com> wrote:
> >>
> >>
> >>
> >> On 11/09/2018 01:59 AM, Steven Whitehouse wrote:
> >>> Hi,
> >>>
> >>>
> >>> On 08/11/18 16:35, Ben Greear wrote:
> >>>>
> >>>>
> >>>> On 11/08/2018 07:31 AM, J. Bruce Fields wrote:
> >>>>> On Wed, Nov 07, 2018 at 09:08:16PM -0800, Ben Greear wrote:
> >>>>>>
> >>>>>>
> >>>>>> On 11/07/2018 05:14 PM, J. Bruce Fields wrote:
> >>>>>>> On Tue, Nov 06, 2018 at 01:03:54PM -0800, Ben Greear wrote:
> >>>>>>>> Hello,
> >>>>>>>>
> >>>>>>>> I made a stab at implementing VRF support in NFS, but it appears
> >>>>>>>> fairly complicated and I ended up reverting my changes....
> >>>>>>>>
> >>>>>>>> Is anyone working on this?
> >>>>>>>>
> >>>>>>>> And, if not, if anyone would like to be sponsored to work on this, please
> >>>>>>>> let me know.
> >>>>>>>
> >>>>>>> Um, sorry--what's VRF?
> >>>>>>
> >>>>>> Virtual Router logic.  It is sort of like network stack containers,
> >>>>>> and has been solid and fully featured in the kernel since 4.16 or so.
> >>>>>>
> >>>>>> In the end, you effectively need to call the logic that SO_BINDTODEVICE
> >>>>>> calls on the socket before binding to an IP.
> >>>>>>
> >>>>>> The NFS and RPC logic is a giant tangled mess to my eyes, so
> >>>>>> hoping I could bribe someone else to do it :)
> >>>>>
> >>>>> So it's not enough to support network namespaces?
> >>>>>
> >>>>> What's your motivation for this?
> >>>>
> >>>> Network namespaces are difficult to uses for lots of use cases, and thus VRF
> >>>> was born.
> >>>>
> >>>> My own motivation is that it allows me to make hundreds or thousands
> >>>> of individual NFS mounts from local mac-vlan (or other virtual/physical interfaces),
> >>>> for testing purposes.
> >>>>
> >>>> Similar to my patch set that binds to local IP address, which gives similar feature
> >>>> set for non-VRF configurations.  These bind-local-IP patches are not upstream and were rejected in
> >>>> the past as un-wanted.  I'm hoping VRF support would be more acceptable.
> >>>>
> >>>> Thanks,
> >>>> Ben
> >>>>
> >>>
> >>> For similar reasons David Windsor has been looking at some extensions for DLM along these lines. Improving our ability to test seems to me like it should be a good thing to do - in both cases. Likewise VRF support seems also like it should be useful in a number of contexts.
> >>>
> >>> Do you have a reference to your past work? I think it would be interesting to get some discussion going here - maybe it would be possible to have some common approach between kernel-side socket users, and/or bounce some ideas around,
> >>>
> >
> >
> > Did you have anything specific in mind here?  AFAICT, the separation
> > provided by VRF wouldn't buy us much over using SO_MARK/iptables with
> > DLM.
>
> I don't know anything in particular about DLM (is this Distributed Lock Manager?).
>

Yes.  DLM is used in clustered environments to provide access to
resources.  The DLM runs on every node in the cluster and normally
uses TCP as its L4 transport (SCTP is also supported, but not widely
used).  Currently, DLM over TCP is restricted to only supporting one
IP address per node.

I'm working on extensions to DLM to allow it to support multihoming at
the TCP layer, as well as adding extensions to make it more robust in
the face of network failures (retransmitting lost messages, automatic
failover to the next available interface, etc.).

> In general, having enough ip tables rules to support 2000 virtual interfaces/mounts
> appears less efficient than using VRF, and VRF gives some additional abilities such
> as allowing duplicated IP addresses, so that is why we are interested in
> VRF.
>
> My existing patches do support multi-homing using iptables rules though.
>

Thanks.  I'm currently looking at these and seeing if any common bits
can be extracted and made into a more generic interface.

> Thanks,
> Ben
>
> >
> > With respect to a common approach between kernel-side socket users, I
> > would be interested in seeing if we could come up with something here.
> > In the case of DLM, the changes needed to support *just* multihoming
> > could perhaps be abstracted into some sort of higher layer, but the
> > bits required to support failover to other interfaces are fairly
> > specific to the DLM protocol itself (i.e. adding sequence numbers to
> > DLM messages, etc.).
> >
> > Thanks,
> > David
> >
> >>
> >>> Steve.
> >>
> >> Here is an old thread on the topic.
> >>
> >> https://www.spinics.net/lists/linux-nfs/msg34811.html
> >>
> >> My patches are in all my 'ct' kernels, and the needed patches are also in my nfs-utils repo.
> >>
> >> My 4.19 tree has just been ported, so no idea if it works or not.
> >>
> >> https://github.com/greearb?tab=repositories
> >>
> >> My patch work fine using routing table rules without VRF, but they will not work with VRF.
> >>
> >>
> >> Thanks,
> >> Ben
> >>
> >> --
> >> Ben Greear <greearb@candelatech.com>
> >> Candela Technologies Inc  http://www.candelatech.com
> >
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
