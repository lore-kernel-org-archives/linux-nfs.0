Received: from mail-pl1-f172.google.com (mail-pl1-f172.google.com [209.85.214.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED8963AB47E
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 23:10:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.214.172
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787872237; cv=pass; b=Ye4vuA8fOhDIgchQIHUg6ze6WpBXMEtfeusjUQN/TL3TIVSt9Occ8z+Hun8BFXGPSv6gWqr851jX/zusR7ZZrIuww9QR5C55yqoH15T9jAFq2NyBdthiMwqLtRx0ceuoAZIhSvvES+91EH3iPXnvpZOCuX13yzqfayGGjPWqWcg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787872237; c=relaxed/simple;
	bh=50LdrEoltKdAEooP55W9pVrl0kRy8ytzQq3fAZ0chw0=;
	h=From:MIME-Version:Date:Message-ID:Subject:To:Cc:Content-Type; b=SDgSKHzUMpqhp5ODgIdcyMZ92b50w9Wcux6Dk4vsXKphanfp15G8RpEYEAGw7BLOwYVC0f2lJjDpZBum1vqxpaEWmwMz6DfTAC7l1nr6MCAjkG7jhtCQB07tW0AguRApRNM/qz9oHzo8dwXaN4xI7OBJ366vwhoyTQcH9GUNFsQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=berkeley.edu; spf=pass smtp.mailfrom=berkeley.edu; dkim=pass (2048-bit key) header.d=berkeley.edu header.i=@berkeley.edu header.b=l4Dsvyn9; arc=pass smtp.client-ip=209.85.214.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=berkeley.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=berkeley.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=berkeley.edu header.i=@berkeley.edu header.b="l4Dsvyn9"
Received: by mail-pl1-f172.google.com with SMTP id d9443c01a7336-2ce7d2adef4so6120865ad.3
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 16:10:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787872235; cv=none;
        d=google.com; s=arc-20260327;
        b=NJUIBwvqb2kZsu6i45GtQFtilrRTPNDM2Nr2oM6TfoZQlmerlOVbo3wBrpQbc4gvzZ
         eQKwwabs/AGWzfImYKh755fnILtBVGtNRl2XozSLE9/SxazTP3uv2JzlQ45FgJUFnOCR
         5nvn/npmKiynrEl9Fp/YGqFmHmWPOsvoz+hjgATvWOJ4zn7AQ2i6w3FAK6net44I/XII
         TiUDrBYWrgDaTR3DuaUvpU5/yVG3ExvxUdLtoIOTmlv+0H5b/TwyKt7pBRBBcvkShuuZ
         prrCeQaJlJEbpqQFgyDj8SQmmwNoABEWsM3Wcz14TK0us77ISxoaFm0aObfRF8wdtGmH
         Sb7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:mime-version:from:dkim-signature;
        bh=0/dlm4IdYFSYRW1eNozPbtx+WAFk89t73wh7qcadLLc=;
        fh=BcCNQognPdJq70r1x5cpjmSf/bTLdFMV+417VGhhp9Y=;
        b=hndjCf80WOz9t4aBxMGleILUXyX+a0H5GvF/KKbgBZlrDsKggFQml63weepCGATAx+
         xcN86KywiTCk7v5MNNS5Qqcp1bl5VLNL/bM74m35MMDLvKMZtL9ZO8u1Rardp3TIDB62
         ooBPCA4t9sBf7kq6bOFm163tY/SS9bAIgW7W8P1H02RZcGvo4TNa+Kn/a4f5aIbmh8tI
         8y5/IcT/NHWjlNttgqIkL7WaXMKcnOnlxbncAQQgb9sb7rlwdbK3KMWeGhO3gxnJnedz
         TEcPX4eUFBWc6Tcq1ymXKINLsswq5L62Hulp1vsoCGwWKl2k819sLw/m2boN3jPCftcg
         +Jzg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=berkeley.edu; s=google; t=1787872235; x=1788477035; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:mime-version:from:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=0/dlm4IdYFSYRW1eNozPbtx+WAFk89t73wh7qcadLLc=;
        b=l4Dsvyn9Tc8fNV1Kbou1+W1u4WksRxczZSFT/HrUZM3dZMVe3QC+Wnw0DoPtMxUeH7
         B5mG/mnIeFkP+qQ90oFuJkxdDrFdiioOoIfiF/UyNuXWCd2ShjRlnNbqEdCfJvTVslsE
         Xf3VTIlTd5PcAO3kVUkPpSpjxkN1ahAxYk1javpgcJNeabUQJnyqTnvB7zt0ZhqnkW/B
         SCt6EsdZ+F13Oj82hl4Y/hbdP95CRwnrwjBXxy8jKwYPoffOcsoknOxbdqTPuGoaA5ll
         LRQRIo1hsuYSEvZDjF8JAzw7wUxITzGhJkmClNWdudCk6zkK2gqh2us7XjrbCETwVowD
         2PFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787872235; x=1788477035;
        h=content-type:cc:to:subject:message-id:date:mime-version:from
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=0/dlm4IdYFSYRW1eNozPbtx+WAFk89t73wh7qcadLLc=;
        b=jc9WhXjqffshkzM3ieZmeA5dHEmZrb0w29lqR2pOtL92VVqFo5pWxuG0Hapq37YUHn
         oY1A/HOEBz9eEf6b7KIFCz2SgsaEIaNR3bnmh8va84QYWDtsbFjJv1Sq1EdNmnf2lHij
         hkUML3epPV81EpUSVg/5rHGYoFD7VgCPdiLcGuqGs+UbS4CoViwRDLc23hqn+5yUxwLS
         gkJqlcC6a3DTXzSmAOnSH4DoWpY9I0JlnsIRFc4oFMQz4dUPrhtpTVJdUo6wttDPyIUc
         N0s8n+eS//h5VCn4RnCsE6nBnpvAQHhXx6MdapLxMdbhkaFvgRK6KXCuu7Fx6Zaw/wvx
         KZbg==
X-Forwarded-Encrypted: i=1; AHgh+Rql/a2uMAoBJSYH5u8/RgbixMzTVEhYKXa0yM9e2/IMkiQW47YP5mFeikwfaLFBos2p+6Hm0PBIWcI=@vger.kernel.org
X-Gm-Message-State: AFuF++lCHjTQgsHiTUMsvn9SD3d2iRLnQAoBLojUnNhudWF2/0dGLPip
	MuTuA9FsxDNp872Z+qClgc7pBkzhu0YpqnUx+7dSGiT0jCAWadd08wAlmQZDM8dsj/pAOK1mTGc
	zhbLcjaV0KcJ9TxK+mJbojHnDV4uFG1dnrrD3qu2w
X-Gm-Gg: AR+sD11V3Y1fzexE0iThVCFMGP1Gc/KwukTp1th9beEuh+VAXEkPvjC8yUDS1Y7s79T
	ZaFFCUMmWNHvkX52yHU55wlaX1anhZO5+oxP95KrS9YxK/61/t49p3EQ/RkbDxpR3tfCCobALZg
	1yZQ+rZYdf8tqsHO9cesgHgeDAA57DNggSwzbi1bFyQwcZ1IqPgdGpmBzup1+B7XlQ4w5Hhk/+S
	oqH2zXYcm9lZbd9DHVdgu6Rc/CbD0R43Wvz+am7WhJ/ZzaLEs361qKPwx7nINgxcgRJRq8o7X5W
	OPqMS6SOqA7tlTWFDUJlYV8vf/9cpx1tyW4z+qhkpmZimkqLgSuudYJ3WZ0wOzNBY/c7ixxM/33
	U3b8OGbeUVu/rYItxvwISxvkIfcPrj7Mw
X-Received: by 2002:a17:903:15cf:b0:2cf:ccc2:6088 with SMTP id
 d9443c01a7336-2d74dc21be0mr48881315ad.4.1787872234415; Thu, 27 Aug 2026
 16:10:34 -0700 (PDT)
Received: from 474444807712 named unknown by gmailapi.google.com with
 HTTPREST; Thu, 27 Aug 2026 16:10:33 -0700
Received: from 474444807712 named unknown by gmailapi.google.com with
 HTTPREST; Thu, 27 Aug 2026 16:10:33 -0700
From: Farhad Alemi <farhad.alemi@berkeley.edu>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 27 Aug 2026 16:10:33 -0700
X-Gm-Features: AcwNN1UYjxJ0J4Uy-WWlv_wrxl6FqqhqS4G-Vh8IC2iQfDd3nuMiaGbL8y28Sa0
Message-ID: <CA+0ovCjVF58WLeen2ctdzHyWUASAAW3Y=Yjihyq0pFApYawtDg@mail.gmail.com>
Subject: [BUG] sunrpc: rpc_pipe_msg left queued on a stack frame (nfsd cld upcall)
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: falemi@asu.edu, linux-nfs@vger.kernel.org, Tom Talpey <tom@talpey.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Olga Kornievskaia <okorniev@redhat.com>, NeilBrown <neil@brown.name>, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hello Chuck Lever, Jeff Layton,

While fuzzing Linux 7.1-rc5 with syzkaller, as part of research at ASU's
SEFCOM lab, we hit the crash below. Crash reports can be found here:

  https://github.com/farhad-alemi/public_bug_reports/tree/main/118-nfsd-cld-stack-rpc_pipe_msg-left-queued/

  ==================================================================
  BUG: KASAN: vmalloc-out-of-bounds in
__list_add_valid_or_report+0x6a/0x130 lib/list_debug.c:32
  Read of size 8 at addr ffffc90007027950 by task syz.0.96/13066
  CPU: 0 UID: 0 PID: 13066 Comm: syz.0.96 Not tainted 7.1.0-rc5 #1 PREEMPT(full)
  Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS
1.16.3-debian-1.16.3-2 04/01/2014
  Call Trace:
  <TASK>
  dump_stack_lvl+0x94/0xd0 lib/dump_stack.c:120
  print_address_description+0x55/0x1e0 mm/kasan/report.c:378

Our reproducer.c is available upon request.

Happy to test a patch if that would help.

Regards,
