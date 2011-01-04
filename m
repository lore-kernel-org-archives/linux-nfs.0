Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:36340 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452Ab1ADOAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 09:00:16 -0500
Message-ID: <4D2327E5.3080106@parallels.com>
Date: Tue, 4 Jan 2011 08:00:05 -0600
From: Rob Landley <rlandley@parallels.com>
To: Daniel Stodden <daniel.stodden@citrix.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Cache flush question.
References: <1294130649.3529.96.camel@ramone>
In-Reply-To: <1294130649.3529.96.camel@ramone>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/04/2011 02:44 AM, Daniel Stodden wrote:
>
> Hi anyone.
>
> If somebody's got a sec to enlighten me, there's some phenomenon I
> recently came across and found somewhat counterintuitive first.
>
> Whenever I
>
>   1. Dirty a bunch of pages backed by an NFS mount on some server.
>
>   2. Block the traffic with iptables (TCP, assuming that mattered).
>      Still plenty of writeback pending.
>
>   3. Sync
>
> I see #3 drive the dirty count in /proc/meminfo drop back to
> almost-zero, immediately. The sync itself blocks, though.
>
> So the pages are called clean the moment the write got queued, not
> acked? Leaving the rest just to retransmits by the socket then? Is this
> just done so because one can, or would that order rather matter for
> consistency?

At a wild guess, maybe you're experiencing what Jim Gettys dubbed 
"buffer bloat".

   http://lwn.net/Articles/419714/

Specficially, does ifconfig show a txqueuelen of 1000 for your device? 
That means the device is buffering 1000 outbound packets, for no readily 
apparent reason (other than to screw up latency).  With an MTU of 1500 
that's a megabyte and a half of outgoing data constipated in the network 
layer.

NFS also has some cacheing of its own I don't understand yet, for 
"non-idempotent" transactions.  Described in this OLS paper:

   http://kernel.org/doc/ols/2006/ols2006v2-pages-59-72.pdf

Rob
