Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33651 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbbL0Adf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 19:33:35 -0500
Received: by mail-oi0-f45.google.com with SMTP id y66so160174342oig.0
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 16:33:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <874mfjay1l.fsf@notabene.neil.brown.name>
References: <87twnjb7lq.fsf@notabene.neil.brown.name>
	<CAHQdGtSbawsf+=uqz3D5UAPntHVKFnUgVZAYh3ym_Fs_+fHAoQ@mail.gmail.com>
	<874mfjay1l.fsf@notabene.neil.brown.name>
Date: Sat, 26 Dec 2015 19:33:34 -0500
Message-ID: <CAHQdGtTekchy7+6phSJikhPYk_FW4G6fuFEHy8WPn_t2iRUvEA@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: restore fair scheduling to priority queues.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 15, 2015 at 10:10 PM, NeilBrown <neilb@suse.com> wrote:
> On Wed, Dec 16 2015, Trond Myklebust wrote:
>
>> On Tue, Dec 15, 2015 at 6:44 PM, NeilBrown <neilb@suse.com> wrote:
>>>
>>> Commit: c05eecf63610 ("SUNRPC: Don't allow low priority tasks to pre-empt higher priority ones")
>>>
>>> removed the 'fair scheduling' feature from SUNRPC priority queues.
>>> This feature caused problems for some queues (send queue and session slot queue)
>>> but is still needed for others, particularly the tcp slot queue.
>>>
>>> Without fairness, reads (priority 1) can starve background writes
>>> (priority 0) so a streaming read can cause writeback to block
>>> indefinitely.  This is not easy to measure with default settings as
>>> the current slot table size is much larger than the read-ahead size.
>>> However if the slot-table size is reduced (seen when backporting to
>>> older kernels with a limited size) the problem is easily demonstrated.
>>>
>>> This patch conditionally restores fair scheduling.  It is now the
>>> default unless rpc_sleep_on_priority() is called directly.  Then the
>>> queue switches to strict priority observance.
>>>
>>> As that function is called for both the send queue and the session
>>> slot queue and not for any others, this has exactly the desired
>>> effect.
>>>
>>> The "count" field that was removed by the previous patch is restored.
>>> A value for '255' means "strict priority queuing, no fair queuing".
>>> Any other value is a could of owners to be processed before switching
>>> to a different priority level, just like before.
<snip>
>> Are we sure there is value in keeping FLUSH_LOWPRI for background writes?
>
> There is currently also FLUSH_HIGHPRI for "for_reclaim" writes.
> Should they be allowed to starve reads?
>
> If you treated all reads and writed the same, then I can't see value in
> restoring fair scheduling.   If there is any difference, then I suspect
> we do need the fairness.

I disagree. Reclaiming memory should always be able to pre-empt
"interactive" features such as read. Everything goes down the toilet
when we force the kernel into situations where it needs to swap.

Cheers
  Trond
