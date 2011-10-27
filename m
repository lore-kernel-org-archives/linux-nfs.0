Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:33443 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab1J0XcA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2011 19:32:00 -0400
Message-ID: <4EA9E86B.3010408@panasas.com>
Date: Thu, 27 Oct 2011 16:25:31 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Michal Marek <mmarek@suse.cz>
CC: Al Viro <viro@ZenIV.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH] fs/Makefile: Always inspect exofs/
References: <4EA5FAD7.4020806@panasas.com> <4EA93868.8070404@suse.cz>
In-Reply-To: <4EA93868.8070404@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/27/2011 03:54 AM, Michal Marek wrote:
> On 25.10.2011 01:55, Boaz Harrosh wrote:
>>
>> fs/exofs directory has multiple targets now, of which the
>> ore.ko will be needed by the pnfs-objects-layout-driver
>> (fs/nfs/objlayout).
>>
>> As suggested by: Michal Marek <mmarek@suse.cz>  convert
>> inclusion of exofs/ from obj-$(CONFIG_EXOFS_FS) => obj-$(y).
> 
> I suggested obj-y verbatim, at least this is what I meant. obj-$(y)
> expands to "obj-" and will do nothing.
> 
> Michal

Thanks Michal.

Yes that was a stupid, stupid TYPO bug I did and I'm so embarrassed
I already sent a fix to Linus, he pulled it.

Dear, you have eyes of an hawk, how did you see it? I stared at it for
15 minutes and did not get it. 

Boaz
