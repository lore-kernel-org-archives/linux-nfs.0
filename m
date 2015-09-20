Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33996 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbbITKfk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 06:35:40 -0400
Received: by wicfx3 with SMTP id fx3so111297943wic.1
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 03:35:39 -0700 (PDT)
Subject: Re: [PATCH v1 03/18] xprtrdma: Remove completion polling budgets
To: Chuck Lever <chuck.lever@oracle.com>,
        Devesh Sharma <devesh.sharma@avagotech.com>
References: <20150917202829.19671.90044.stgit@manet.1015granger.net>
 <20150917204435.19671.56195.stgit@manet.1015granger.net>
 <CANjDDBgokeHEZ7jWhRKRRU4Usr655zRoYY-qUHc9jeuyjYBzpA@mail.gmail.com>
 <A3B1A836-81AF-40E6-B551-587B7173B72D@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55FE8C0F.1050706@dev.mellanox.co.il>
Date: Sun, 20 Sep 2015 13:35:59 +0300
MIME-Version: 1.0
In-Reply-To: <A3B1A836-81AF-40E6-B551-587B7173B72D@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> It is possible that in a given poll_cq
>> call you end up getting on 1 completion, the other completion is
>> delayed due to some reason.
>
> If a CQE is allowed to be delayed, how does polling
> again guarantee that the consumer can retrieve it?
>
> What happens if a signal occurs, there is only one CQE,
> but it is delayed? ib_poll_cq would return 0 in that
> case, and the consumer would never call again, thinking
> the CQ is empty. There's no way the consumer can know
> for sure when a CQ is drained.
>
> If the delayed CQE happens only when there is more
> than one CQE, how can polling multiple WCs ever work
> reliably?
>
> Maybe I don't understand what is meant by delayed.
>

If I'm not mistaken, Devesh meant that if between ib_poll_cq (where you
polled the last 2 wcs) until the while statement another CQE was
generated then you lost a bit of efficiency. Correct?

>
>> Would it be better to poll for 1 in every
>> poll call Or
>> otherwise have this
>> while ( rc <= ARRAY_SIZE(wcs) && rc);
>>
