Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37315 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754969AbbI0HEO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2015 03:04:14 -0400
Received: by wicfx3 with SMTP id fx3so63804088wic.0
        for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2015 00:04:13 -0700 (PDT)
Subject: Re: [PATCH v2 16/26] IB/srp: Convert to new registration API
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
 <1443116118-10730-17-git-send-email-sagig@mellanox.com>
 <560577A4.4080806@sandisk.com>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <560794EA.80103@dev.mellanox.co.il>
Date: Sun, 27 Sep 2015 10:04:10 +0300
MIME-Version: 1.0
In-Reply-To: <560577A4.4080806@sandisk.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/25/2015 7:34 PM, Bart Van Assche wrote:
> On 09/24/2015 10:35 AM, Sagi Grimberg wrote:
>> Remove srp_finish_mapping since no one is calling it.
>
> Please move the srp_finish_mapping() removal into a separate patch.

Moved, thanks.
