Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56998 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab0KQKoS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 05:44:18 -0500
From: Andi Kleen <andi@firstfloor.org>
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [patch 01/28] fs: d_validate fixes
References: <20101116140900.039761100@kernel.dk>
	<20101116142028.254946611@kernel.dk>
Date: Wed, 17 Nov 2010 11:44:16 +0100
In-Reply-To: <20101116142028.254946611@kernel.dk> (Nick Piggin's message of
	"Wed, 17 Nov 2010 01:09:01 +1100")
Message-ID: <87bp5orzzz.fsf@basil.nowhere.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Nick Piggin <npiggin@kernel.dk> writes:

> d_validate has been broken for a long time.
>
> kmem_ptr_validate does not guarantee that a pointer can be dereferenced
> if it can go away at any time. Even rcu_read_lock doesn't help, because
> the pointer might be queued in RCU callbacks but not executed yet.

I wonder if that is a problem for NFS ... (which I believe is the only
user). Could these races be used to break the NFS server?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
