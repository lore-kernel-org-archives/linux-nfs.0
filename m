Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34704 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932925Ab0FQOvu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:51:50 -0400
Received: by fxm10 with SMTP id 10so1666816fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 07:51:49 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006171737230.24360@deckard.hut.fi>
References: <1276693350-1780-1-git-send-email-iisaman@netapp.com>
	<alpine.DEB.2.00.1006171737230.24360@deckard.hut.fi>
Date: Thu, 17 Jun 2010 10:51:48 -0400
Message-ID: <AANLkTimgeoc98YJZpKz8ibhnIMuKA5O6F_tUBFP4_59E@mail.gmail.com>
Subject: Re: [PATCH 0/1] fix delay on mount and umount
From: Fred Isaman <iisaman@netapp.com>
To: Timo Aaltonen <timo.aaltonen@aalto.fi>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 17, 2010 at 10:41 AM, Timo Aaltonen <timo.aaltonen@aalto.fi> wrote:
> On Wed, 16 Jun 2010, Fred Isaman wrote:
>
>> This fixes the delay issues we've been having.
>
> What kind of delays are we talking about and since which kernel version?
> With 2.6.32 it takes several minutes to umount a 100 NFSv4 shares. Mounting
> them is much faster but not instant.
>
> Probably will end up using the automounter anyway, but it's nice to know if
> this fixes the issue.
>

Sorry, I should have been more specific.  This fixes a regression that
occurred between 2.6.35-rc2 and 2.6.35-rc3.
Mounts would hang for approx 2 minutes.

Fred

> --
> Timo Aaltonen
> Systems Specialist
> Aalto University IT
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
