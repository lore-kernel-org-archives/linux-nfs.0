Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44143 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920Ab1HZXv7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 19:51:59 -0400
Message-ID: <4E58318A.3080305@panasas.com>
Date: Fri, 26 Aug 2011 16:51:38 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: nfsd4_open Avoid race with grace period expiration
References: <4E45C164.1070604@panasas.com> <20110826203924.GC17196@fieldses.org> <4E58119A.3090403@panasas.com> <20110826215451.GF16090@pad.fieldses.org>
In-Reply-To: <20110826215451.GF16090@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/26/2011 02:54 PM, J. Bruce Fields wrote:
>> You might get by, by rechecking the grace period at the end of the
>> processing and if passed issue a "reclaim request failed" anyway.
>> So the first check is only for optimization but the final disposition
>> is the post-check. (Just as if you dropped that refcount above)
> 
> I guess that could work, but you'd have to back out the operation you
> just did if the check showed you'd left the grace period.  I'd rather
> avoid that.
> 

Yes, you'll need to "back out" of the operation. It was just a suggestion.
You'll have to see what is easier to implement.

The above is less invasive and does have merits. It is a bit like the RCU_FREE
pattern when at the end of the operation you see that you lost the race and needs
to "back out". But in the hot path it is very cheap, (No reference counts no locking).
And only in the very very rare event, Those that today we fail on, do you do
the extra "backing out". So overall runtime and coding wise it might be the
cheapest solution.

Just my $0.017

> --b.

Boaz
