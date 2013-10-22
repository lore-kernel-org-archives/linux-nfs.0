Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27850 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751688Ab3JVOtZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:49:25 -0400
Message-ID: <52669069.5050700@netapp.com>
Date: Tue, 22 Oct 2013 10:49:13 -0400
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: What is the long term fix for the idmapper key-quota problem.
References: <20131021160514.4dbcbf12@notabene.brown>
In-Reply-To: <20131021160514.4dbcbf12@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 21 Oct 2013 01:05:14 AM EDT, NeilBrown wrote:
>
> Hi,
>  as you probably know, request_key() imposes a quota on
> the number of keys that can be requested, which by default is quite low (200).
> When idmap exceeds this quota, request_key() returns an error and
> the result is userspace sees "nobody" as the owner.
>
> A short term fix is to fiddle some sysctl values, but I wonder if any long
> term fix is being planned.

I don't have anything planned.

>
> Probably the sensible thing would be for nfs-idmap to bypass the quota.
> As keys are not held active for very long at a time, they should be garbage
> collected in due course.
> There is currently no interface to request this but I suspect one could be
> added.

Adding a new keyring interface might be a better question for David 
Howells, since he's done a lot of keyring work.

How many idmap keys do you have active at once?  I'm guessing the quota 
is there for a reason, and increasing it in-kernel would probably be 
much easier than adding a new interface for short-lived keys.

>
> (I want to fixed this for openSUSE-13.1, and don't want to diverge too far
> from mainline).
>
> Thanks,
> NeilBrown


