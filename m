Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29355 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941Ab3GOHRA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 03:17:00 -0400
Message-ID: <51E3A1D7.8090901@parallels.com>
Date: Mon, 15 Jul 2013 11:16:39 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>, jlayton@redhat.com
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS inode cache zap on lock - please advice
References: <51A6EC86.9010201@parallels.com> <20130530114216.GA11854@fieldses.org> <51A73FA6.30503@parallels.com> <20130712205242.GB10562@fieldses.org>
In-Reply-To: <20130712205242.GB10562@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

13.07.2013 00:52, bfields@fieldses.org пишет:
> On Thu, May 30, 2013 at 04:01:42PM +0400, Stanislav Kinsbursky wrote:
>>
>> Thanks, Bruce!
>> I'll have at
>>
>> BTW, do you have any decisions what we will do with UMH tracker?
> Crap, apologies, I completely dropped this.  Have you looked at it
> again lately?

Don't worry, it's all right. And I added Jeff and mailing list to 
recipients.

I was thinking about using kernel_thread() instead of kthread_create().
This might work, because will give us kthread with same root and same 
capabilities as mount caller had.

What you, guys, think about it?
