Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57268 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab0HYRUW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 13:20:22 -0400
Received: by eyg5 with SMTP id 5so471052eyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Aug 2010 10:20:21 -0700 (PDT)
In-Reply-To: <4C754DB4.5060608@scalableinformatics.com>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
	<4C754DB4.5060608@scalableinformatics.com>
Date: Wed, 25 Aug 2010 12:20:21 -0500
Message-ID: <AANLkTimUzC8yvZNjLR7Rx0F4W4h9mf0FW9c3gq2rkuXP@mail.gmail.com>
Subject: Re: fsync/wb deadlocks in 2.6.32
From: davidr@ressman.org
To: landman@scalableinformatics.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 25, 2010 at 12:07 PM, Joe Landman
<landman@scalableinformatics.com> wrote:
>> [88792.122324] INFO: task awk:7184 blocked for more than 120 seconds.
>
> Did you get an "nfs server not responding" type message in the logs?

Unfortunately not, and no messages like that in any of the clients,
deadlocked or no. From an IO perspective, the NFS servers have
capacity and bandwidth to spare. We haven't been able to see any
load-related causes to this, although that's not to say they're not
there. We *have* seen this problem under a lighter load, with just 4-8
servers running the same 8 processes per server, but that's quite
rare, I suspect just due to the rarity of the problem.

This happens over both GigE or IPoIB (QDR) as well.
