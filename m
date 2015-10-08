Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38045 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbJHIWD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 04:22:03 -0400
Received: by wiclk2 with SMTP id lk2so13914621wic.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2015 01:22:01 -0700 (PDT)
Subject: Re: [PATCH v3 00/26] New fast registration API
To: Christoph Hellwig <hch@infradead.org>, Sagi Grimberg <sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
 <20151008080103.GA29235@infradead.org>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <561627A6.1000409@dev.mellanox.co.il>
Date: Thu, 8 Oct 2015 11:21:58 +0300
MIME-Version: 1.0
In-Reply-To: <20151008080103.GA29235@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/8/2015 11:01 AM, Christoph Hellwig wrote:
> On Thu, Oct 08, 2015 at 10:50:43AM +0300, Sagi Grimberg wrote:
>> - Rebased against Doug's for-4.4 tree (4.3.0-rc1) + 4.3-rc fixes
>
> Does this means its not on top of the send_wr changes now?  I'm fine
> with that as I think your series is even more important than the send_wr
> split and I'm happy to rebase, but I'd also really like to see some
> progress on them..

Its on top of your wr_cleanup as well.
