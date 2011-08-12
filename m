Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:53256 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab1HLTA6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 15:00:58 -0400
Message-ID: <4E45785D.40103@panasas.com>
Date: Fri, 12 Aug 2011 12:00:45 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Casey Bodley <cbodley@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
References: <4E44790A.8000106@panasas.com> <4E447EEB.501@panasas.com> <4E4481F0.2050806@panasas.com> <20110812021556.GD9761@pad.fieldses.org> <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com> <20110812143228.GD16960@pad.fieldses.org> <4E456BBB.1030605@panasas.com> <20110812183945.GJ16960@pad.fieldses.org>
In-Reply-To: <20110812183945.GJ16960@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/12/2011 11:39 AM, J. Bruce Fields wrote:
> On Fri, Aug 12, 2011 at 11:06:51AM -0700, Boaz Harrosh wrote:
>> I'm confused is this suppose to fix my problem? Because I do not believe
>> it will. There should not be any error writing a recovery record.
>>
>> Please note that the case I have is that the client is a new client. That
>> loaded after the server loaded and started it's grace. Does a client suppose
>> to send RECLAIM_COMPLETE in that case too. .i.e send RECLAIM_COMPLETE as first
>> message after mount?
> 
> It must send one before it sends any non-reclaim open, yes.
> 

1. So you are saying the Linux client is broken? How do you test?
2. If a client is broken and never sends it. Do you claim that it should
   stay in denial forever. Or we can let him off the hook once the
   grace ends?

I can't see the logic in 2. It's that lawyer logic again. I don't mind
and it will harm no one if I do it, but I don't because I'm punishing you
for being a bad boy.

Sigh, what do you suggest we do? a client fix will only work for 3.1 Kernel
say we even send it to stable. Are you willing to sacrifice all the old clients
that do not update?

When was this breakage introduced I did not have it before yesterday?

Please decide?
Boaz

