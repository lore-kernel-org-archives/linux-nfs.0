Received: from mail-24416.protonmail.ch (mail-24416.protonmail.ch [109.224.244.16])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6807E555;
	Tue, 24 Feb 2026 12:50:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=109.224.244.16
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771937434; cv=none; b=KKqabtH1nwirj96lba+Q4JfrZVdzSsJUnmnxclq9KSMeWKIKEfwWS3WVoXWCNSSTuYwqNF95+8YNukLz8MdpG7GbEHqJFDWRbTLPb9LhMOZMMb1L9PDB60lDyFcoIeGdEpZr73DT0W4MMrVFl5dUoCY3nA8KUS9TfpzNVa0vGsk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771937434; c=relaxed/simple;
	bh=4ZpgPKN7lBYy9RyuYxqbYlZFbJqbOUMbCPnhg0scku4=;
	h=Date:To:From:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=NompXfohBXEzRrMfa9MOlerpZvUrskC8Y1qoCdh4y211OMppt2sK7jdPVgG1rvXDC2CKvlsPhy/HvTNW6LPU0MdjEc4xh/WaXL/PTTBk+QlC4bdTNeRJrlxiEhTqFPflnS86wHHrwmRXNp+/L5UXqM+Jnqxx635+KKRlcAn1njY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me; spf=pass smtp.mailfrom=proton.me; dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b=NqRxNtcU; arc=none smtp.client-ip=109.224.244.16
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proton.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b="NqRxNtcU"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=proton.me;
	s=protonmail; t=1771937428; x=1772196628;
	bh=4ZpgPKN7lBYy9RyuYxqbYlZFbJqbOUMbCPnhg0scku4=;
	h=Date:To:From:Cc:Subject:Message-ID:In-Reply-To:References:
	 Feedback-ID:From:To:Cc:Date:Subject:Reply-To:Feedback-ID:
	 Message-ID:BIMI-Selector;
	b=NqRxNtcU2xQk6aOoNjHhk68K4r8sZnjT2ZGUp5XIf7DYPWYLG5RPH2ljTRwTMwlaA
	 5HaWaoDqk5EHm20hzI4dEh8CH4x1qOPGWn8DoJiORf/Uhh8TM3R0RrgkrNc4BfGzxQ
	 JItc+R6tPVqbWCpD4byLpIB/xPP4GIXtAXDrYSB7oKkAACuYKSS6H/Qck/mqmsQqKS
	 i9J28bG10VePn8LaTceFabPQ+ZWbuk2kPPgY73zCsoc2lvRIAG2uN00t5eE7j5TNem
	 eHIeDWdaQ5SxzB0G3jp6JaaNNiZR7bR6ApCWJZDooSqwEVKFCR6kzI+/nNQqnzC1lk
	 iqy1HWigED+SQ==
Date: Tue, 24 Feb 2026 12:50:22 +0000
To: 1128861@bugs.debian.org, Neil Brown <neilb@suse.de>
From: Tj <tj.iam.tj@proton.me>
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <okorniev@redhat.com>, stable@vger.kernel.org
Subject: Re: Regression: Missing check in nfsd_permission() causes -ENOLCK No locks available
Message-ID: <7945477d-f6f9-4311-9ef3-73a92f0e8ea2@proton.me>
In-Reply-To: <c0f15088-3fc0-487a-9f24-cf89c158420d@proton.me>
References: <c0f15088-3fc0-487a-9f24-cf89c158420d@proton.me>
Feedback-ID: 113488376:user:proton
X-Pm-Message-ID: 29d15f7aae71bfa311d3102de9afc722df094a18
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Follow-up with results of adding dump_stack() to nfsd_permission()=20
revealing the paths that trigger the issue.

[=C2=A0 133.185579] Call Trace:
[=C2=A0 133.185580]=C2=A0 <TASK>
[=C2=A0 133.185580]=C2=A0 dump_stack_lvl+0x64/0x80
[=C2=A0 133.185582]=C2=A0 nfsd_permission+0x20/0x100 [nfsd]
[=C2=A0 133.185612]=C2=A0 nfsd_access+0xc8/0x140 [nfsd]
[=C2=A0 133.185639]=C2=A0 nfsd4_proc_compound+0x350/0x670 [nfsd]
[=C2=A0 133.185670]=C2=A0 nfsd_dispatch+0x100/0x220 [nfsd]
[=C2=A0 133.185698]=C2=A0 svc_process_common+0x314/0x700 [sunrpc]
[=C2=A0 133.185733]=C2=A0 ? __pfx_nfsd_dispatch+0x10/0x10 [nfsd]
[=C2=A0 133.185762]=C2=A0 svc_process+0x131/0x1c0 [sunrpc]
[=C2=A0 133.185795]=C2=A0 svc_recv+0x80a/0x9e0 [sunrpc]
[=C2=A0 133.185827]=C2=A0 ? __pfx_nfsd+0x10/0x10 [nfsd]
[=C2=A0 133.185856]=C2=A0 nfsd+0xa3/0x100 [nfsd]
[=C2=A0 133.185882]=C2=A0 kthread+0xd2/0x100
[=C2=A0 133.185884]=C2=A0 ? __pfx_kthread+0x10/0x10
[=C2=A0 133.185885]=C2=A0 ret_from_fork+0x34/0x50
[=C2=A0 133.185886]=C2=A0 ? __pfx_kthread+0x10/0x10
[=C2=A0 133.185887]=C2=A0 ret_from_fork_asm+0x1a/0x30
[=C2=A0 133.185890]=C2=A0 </TASK>

[=C2=A0 144.020165] Call Trace:
[=C2=A0 144.020165]=C2=A0 <TASK>
[=C2=A0 144.020166]=C2=A0 dump_stack_lvl+0x64/0x80
[=C2=A0 144.020168]=C2=A0 nfsd_permission+0x20/0x100 [nfsd]
[=C2=A0 144.020201]=C2=A0 nfsd_access+0xc8/0x140 [nfsd]
[=C2=A0 144.020228]=C2=A0 nfsd3_proc_access+0x6c/0x110 [nfsd]
[=C2=A0 144.020257]=C2=A0 nfsd_dispatch+0x100/0x220 [nfsd]
[=C2=A0 144.020286]=C2=A0 svc_process_common+0x314/0x700 [sunrpc]
[=C2=A0 144.020321]=C2=A0 ? __pfx_nfsd_dispatch+0x10/0x10 [nfsd]
[=C2=A0 144.020350]=C2=A0 svc_process+0x131/0x1c0 [sunrpc]
[=C2=A0 144.020383]=C2=A0 svc_recv+0x80a/0x9e0 [sunrpc]
[=C2=A0 144.020415]=C2=A0 ? __pfx_nfsd+0x10/0x10 [nfsd]
[=C2=A0 144.020445]=C2=A0 nfsd+0xa3/0x100 [nfsd]
[=C2=A0 144.020471]=C2=A0 kthread+0xd2/0x100
[=C2=A0 144.020472]=C2=A0 ? __pfx_kthread+0x10/0x10
[=C2=A0 144.020473]=C2=A0 ret_from_fork+0x34/0x50
[=C2=A0 144.020475]=C2=A0 ? __pfx_kthread+0x10/0x10
[=C2=A0 144.020476]=C2=A0 ret_from_fork_asm+0x1a/0x30
[=C2=A0 144.020478]=C2=A0 </TASK>


