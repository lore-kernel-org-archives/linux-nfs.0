Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C88D2E413;
	Sun, 24 May 2026 15:31:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779636668; cv=none; b=uH4S3ztzCrVG4FEv8HNK/CubdRixeK0l3jId4hi/H+wwFSBhzEIY+++pIq2ihJTcRN2EYT5mmGBpadtrMzOilWTT69kArTclKXYzMDkFh2NbZXZn3R4kcpBaStyuLr+qYFjf0fCLZMtxRONMeyxb57BMHIbjhCFLDXc/r6U/Lx8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779636668; c=relaxed/simple;
	bh=C00Ax4c4AQGKa9phZox02SRyGPXRYKSMAEfaHk+QQz8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=h+gk7G/9VPCh/bta8NipOgGXPadD3bkPX77/w3nc9AADhCvGmkVHQ66jRcG2bGuUyiGYtt7OZtDoAEJTAgyqEIb5zyMGw8PGrnRbhhbYawDtEVJFdRmilUxsS2+UjktlHnseqR+GeM3tTcjWnWrIX7YE6Fu9v05RXqXXTSTnI50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QavMYLht; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QavMYLht"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0088D1F000E9;
	Sun, 24 May 2026 15:31:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779636666;
	bh=thlOW3rj4xgfZPrpsrtCg2C+MUszqMCfs2pN7SkJyMo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=QavMYLhtVu0hVQS8hiN9U/Ql8San5HDjaHqLyeU+O7EXsXnWhYU4FTRuvy9cZU3ZQ
	 CqxRkVVEZ0UCo7raL/HG7iL0V4NIHHkE1Qg1Ol/ZHmVTGAJxunQ89YUf5LcT6n8GdH
	 rlFcMj8Rz0tWLCZsYB8/pId2U+df4Xp1B4UJ580kLHP/4g2+Kvu9wWFSxMmr16SSbg
	 bk6VgEocWZtRYEzxPG0RiOpUAUzxZ7FePLD3H1Pw5RiSdXWk3usOnj2GGXg1jyMFAh
	 xs7DqHeXCCCrmzHatE78zWqTJEGG/wTl7pkoi9M8sF1QtZ3g9V3dt6IS8CukoUP5Mi
	 poFMtQpyp8fkA==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Michael Bommarito <michael.bommarito@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: restart ssc_expire_umount walk after dropping nfsd_ssc_lock
Date: Sun, 24 May 2026 11:31:02 -0400
Message-ID: <177963663875.586332.15111798957693443226.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260524130654.1924556-1-michael.bommarito@gmail.com>
References: <20260524130654.1924556-1-michael.bommarito@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Sun, 24 May 2026 09:06:54 -0400, Michael Bommarito wrote:
> nfsd4_ssc_expire_umount() walks nn->nfsd_ssc_mount_list with
> list_for_each_entry_safe(ni, tmp, ...).  For each expired entry it
> sets nsui_busy = true, drops nfsd_ssc_lock to run mntput() on the
> source vfsmount, then reacquires the lock to list_del + kfree the
> entry and continue iterating via the macro's saved tmp pointer.
> 
> The nsui_busy flag protects the current ni from concurrent
> nfsd4_ssc_setup_dul() finders during the lock-drop window, but it
> does not pin tmp.  Another nfsd RPC thread that fails its source-
> server mount and reaches nfsd4_ssc_cancel_dul() will, during that
> same window, take nfsd_ssc_lock, list_del + kfree its own ssc_umount
> item, and release the lock.  If that item is the saved tmp of the
> expire walk, the next iteration dereferences a freed
> nfsd4_ssc_umount_item.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: restart ssc_expire_umount walk after dropping nfsd_ssc_lock
      commit: e6dc1fc7e8483f9b36dcfdbcd33665298b018ba9

--
Chuck Lever <chuck.lever@oracle.com>
