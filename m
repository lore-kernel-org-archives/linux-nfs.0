From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 0/5] pnfs-submit fix kfree under spin lock
Date: Tue, 20 Jul 2010 16:36:59 -0400
Message-ID: <AANLkTinrF4uXsia_5fXmps=31C9Ab9AZ0M6kruL_rczS@mail.gmail.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
	<20100720190953.GA22237@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:42316 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761637Ab0GTUhA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 16:37:00 -0400
Received: by iwn7 with SMTP id 7so6011081iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jul 2010 13:37:00 -0700 (PDT)
In-Reply-To: <20100720190953.GA22237@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 3:09 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Jul 20, 2010 at 01:01:18PM -0400, andros@netapp.com wrote:
>>
>> Fix kfree under spin lock
>>
>> Both put_lseg and put_layout are called under the inode i_lock where the
>> last reference will end up freeing structures.
>>
>> I know there has been a lot of churn in this code, but free'ing under the
>> spin lock is a no-no.
>
> kfree under a spinlock is perfectly fine.  That is as long as you
> don't free the spinlock itself.

:)

-->Andy
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
