Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:34348 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbbG2IZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jul 2015 04:25:17 -0400
Received: by lbbst4 with SMTP id st4so1674188lbb.1
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2015 01:25:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150729073330.GA13361@infradead.org>
References: <1438173661-12497-1-git-send-email-devesh.sharma@avagotech.com>
	<20150729073330.GA13361@infradead.org>
Date: Wed, 29 Jul 2015 13:55:15 +0530
Message-ID: <CANjDDBhOHZXLR=ih5s8r4kMi96XAUU0uUYuhk8FEZDVfFGaw3A@mail.gmail.com>
Subject: Re: [PATCH v1] xprtrdma: take vendor driver refcount at client
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 29, 2015 at 1:03 PM, Christoph Hellwig <hch@infradead.org> wrote:
> Hi Devesh,
>
> I don't understand your use of "vendor driver" here.  It seems your'e
> talking about the HCA driver.

Yes, I mean to say HCA driver. I will change this in next revision,
its confusing rigth now.

>
