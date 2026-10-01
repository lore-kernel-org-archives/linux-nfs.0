Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A71E3372ECE;
	Thu,  1 Oct 2026 01:07:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790816868; cv=none; b=sKTq4ezE5JBd69ZG0PcBo4HMiEnSlaLXCz5JN+wrTX+VTAIa56dH5iQW3uq7pKNzcZI73LtgFRp+T81oAmZIqvn1cB93vIkp3mt43rFzMf2keXqYiXVnMMq3ZKgcaGML8SwaGaQklloAiG68rJqshstoABhfbTIm8qFdpaMZSdA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790816868; c=relaxed/simple;
	bh=RT5A/9HMue+O1wWjxQ4Pjn4DNG4xsbTmgAuu0oIfJCo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=JJ+CVtZhauM+z2JroeSK7O7+35BbrXxOlBmNPjrL43JKRCEHgOT4JV+FZEgIhFXaMM6hMGp2IAlzxkugt4wu0r89wGDV725tS5qF2Cf2nnFqtMe7RG3M+acRbXeMIN8hOGbKZREHDvBvyHgNQzk8K2oegStJ66N5Er+65LHIqh4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LFgJ3oXx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LFgJ3oXx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4BB351F00898;
	Thu,  1 Oct 2026 01:07:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790816864;
	bh=CwGxd9g4HHs/84Ge8XmhcajbmFBf0YozaOvMHk6FYmU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=LFgJ3oXx9MSfEpsQSHbl4GynYqe+Qtnoc27HQH0v3epUoDivaGRy+emKM1oIRQQeN
	 2l43p7i0I7+o7fx2MVmD2XfAgf8uIh2FWChL+7EYeG4qA7HTMkx9dimkNMDDlCVAv5
	 ERP83MNm4WFGldYdh3XXStQW5lHml78EwpwvjYXTTJdIL+ywScvkJ13heqodzIVNYE
	 ACr6KZOyBUSIJf2T2YUeGyKTaRHKcHbQ9UWDqBT6SJy4zX0uUCOHLei1CLSI9wkhAo
	 tjK9SaXj7LZr3AfA6n2Id90b5vJG3VRaAUGm/CJvEcej7TAyg+/FXZZTZPVdGXVood
	 rAvQyHXZp14hQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6D97AF40068;
	Wed, 30 Sep 2026 21:07:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 30 Sep 2026 21:07:43 -0400
X-ME-Sender: <xms:X7K9agIdF9tRWgveFzyyfEuUnDVk3iXGPzBiBqboEg_ooU6WOlzn8A>
    <xme:X7K9aq_5TWJE-hWCwmg9zWl01ylfAIHY16oiVQzLJrL-CZaki7EZI40WkX1n_r12A
    FLlUsg59Jvy2lMnMH6PTH1crnA2vIYjGB8xmaZmNI9KgGabdLe4BKH20Q>
X-ME-Proxy-Cause: dmFkZTEV/a2fjBtwvOeO/zFaNy52ZxTsEZH1L0We3+jzDQcLzqY5tCsX3mQtn/I9WA99/8
    w3zcW93Vpp59fRkTUzBDjlNFLWfnh1NSc3muGBYHpV9FWSoxgJ2wycM6lkJds8A40LSLO1
    Re0SSxugGsc9miYclrDglYx6X+/UivPAsTeRj7o4KLBXlrmCiJxCXs/P660KAHByI5OcLe
    ZvNap1Lh6BnOXmNSIN0IGRR9EqhSFQ/C+1VdqfFBOgaXOTeA6frV34UL+aed0NEWsol8ln
    Jg6NoHr7fPtY0YTv3FB8mbEvR8pu+txLOgW6fmcRfOgRYXOfZDfVxPDyb4GMjwaIw9a9ks
    58tyMw6G2PVKcRF6Ctz45j/3bYgqQJQlmv/j17ClqnZcuSMb8tFRRQz3628Mc+ZMfs8gqW
    3liianVqpV3pz1zprE+Ma+1YPPNkBI4KSi5ZTSFUbSSs6QasVteoVZK6eU2tn4wP6/9ZZs
    NLzCRPfa7bJM3gxuoOsW4oPtEOiuUg9AHN3tUnYOY8RjvgK6ytWL3kyrBZ7H6d1+VZegb2
    slIjjNh4lRpfnAGSuB0xgNwjFHkQZ9u4sqFTlNqUpX75eq/rLmnxV/E4mBp2rDT9jGr+M1
    aLYAYCjb/k3cYZMWhdZlI/NIpq1sefSPWPqXZAAuk0EjRGVzNf0GeEVyrh7Q
X-ME-Proxy: <xmx:X7K9aiq65aDhsoKw-D7VuUbJHbQaVXbtbLAli5kQAKdRUGbTZ_38Yg>
    <xmx:X7K9atPmlWn0Brsrd-dgIHAtxKE880UbP3HxlUCDzkaxKQQGGzgspw>
    <xmx:X7K9aroSX9q4glimWV5AuYONP_j9WQf6Zt7s2ckPRoOM1QLnHwsTng>
    <xmx:X7K9aosWOyWU_I_Ezb-TLHjdajWPBY3qSg6FX5FUizySHk0yvLOd3Q>
    <xmx:X7K9ai1Tq56RRpi7_egbaGGWYfdbY0ayVIwz0xSjh_F1F7_c_ueohLBv>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4B985780070; Wed, 30 Sep 2026 21:07:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: APE9iFNf_byJ
Date: Wed, 30 Sep 2026 18:07:23 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Abdifatah Suruur" <suruurism@gmail.com>
Cc: jlayton@kernel.org, linux-nfs@vger.kernel.org,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org
Message-Id: <6dbeec76-a55d-4e41-9115-99d199997497@slotpi15m67>
In-Reply-To: <20260930202212.1482-1-suruurism@gmail.com>
References: <20260930202212.1482-1-suruurism@gmail.com>
Subject: Re: [PATCH] lockd: fix use-after-free in nlmsvc_retry_blocked()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Abdifatah,

Thanks for looking at this code. I'm not going to take this patch,
for the reasons below.

On Wed, Sep 30, 2026 at 11:22:12PM +0300, Abdifatah Suruur wrote:
> Pin the block before dropping the spinlock in nlmsvc_retry_blocked()
> and release the pin after processing, so the block cannot be freed
> while it is in use.

This part is already fixed. The nfsd-testing branch carries

  lockd: Fix use-after-free in nlmsvc_retry_blocked
  lockd: Serialize block retries against host teardown

The first takes the same reference in the same place, so your patch
no longer applies there. For lockd and NFSD work, please base patches
on the nfsd-testing branch of

  git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git

> nlmsvc_notify_blocked() has the same problem: it moves the block to
> the head of the list and then calls svc_wake_up(block->b_daemon)
> after dropping nlm_blocked_lock.  Keep that wake-up under the
> spinlock, as nlmsvc_grant_deferred() already does.

This one appears to be unreachable.

nlmsvc_notify_blocked() is the lm_notify callback. It is called from
__locks_wake_up_blocks() with blocked_lock_lock held, and that
function clears waiter->flc_blocker only after lm_notify returns.

The block is on nlm_blocked when the callback finds it, so the list
holds a reference. A block whose file_lock is waiting comes off that
list through nlmsvc_unlink_block(), which calls locks_delete_block()
on the block's file_lock before it calls nlmsvc_remove_block(). That
covers GRANT_RES, CANCEL, nlmsvc_traverse_blocks(), and
nlmsvc_grant_blocked().

While the callback is running, flc_blocker is still set, so
locks_delete_block() cannot take its lockless early return. It has to
acquire blocked_lock_lock, and it waits there until the callback has
returned. The list reference therefore cannot be dropped between the
spin_unlock() and the svc_wake_up().


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
