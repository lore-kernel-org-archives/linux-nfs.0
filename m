Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 543F937E5DF
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 20:51:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791492694; cv=none; b=uWhzPXNsbxKzGxXOTp4ufRbdStlSmpLdszwVvs2r0Cl5/3D1J+asaJZhUOJyv92T80MuQTcUGVNPJFyZE3cvsj39ELMK5tdA1Fti52yIEdooFK0dVDIefQ9yCcavLjYssSBEWVNvYy+DpevbE/DQLnkMvaAoxYTVexinS4H59Fs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791492694; c=relaxed/simple;
	bh=MKR4q+ZZyfGT7qC/VAthUj/6VNf2NttWlg+T4QlyR5g=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=nKfL0Apb7Bbk1BcVnWNQoQ0ZXNll1a88MFwtaERM+8apMvAUTGfpOpYCDTVTO/1B1d3r0KAAh5daTraF118ov/jYIj+nKCOr0Ycr2ZcAdPDwV+UP0molBRT6wDHyUC1b135QdY+H6C2ILVkh7qpR76fDotjd9YSN3Bz9nYDB7I0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HEyp2ke9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HEyp2ke9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AFC231F00893
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 20:51:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791492692;
	bh=BE9TWsY8RZ6wLvstgPtKi1yjy0I7ru8tERCNPCSpJnU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=HEyp2ke95QWOWj0QP407AD7mpWsFWCcGG4dmCq6//4EYVax45xwhAlDptbCN5g0NA
	 mtlp7JnVwyljvDFyxjZ6BevfQueVC78Ny0hMDZyriJV7UR3LK+Gs6RHoDXbIIhZQDN
	 MSE9ohCuMzirrWyGiL7hhv8TmJnRjlEEGeCv0pfHwqhV/Pu2IXI4WDwYZGQBM/wSs2
	 lE4IzXQQz1df9Vw9WWWvx5sbrkIoNt0JpS1p2NRE6di2p5h/Y4tBnNlbiyX51VcCsC
	 72NPt7rhUU4KG+CJ/0FXucsJyi38gvD21qJ21TGFiVctJliKM/6VDo+3jRQolu9Bv0
	 OrL6aJ/3Uipjw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E89ADF40066;
	Thu,  8 Oct 2026 16:51:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 08 Oct 2026 16:51:31 -0400
X-ME-Sender: <xms:UwLIart_DzDF1SYpIf8yi2cGLnS8lVCRbYdDQ7W_V_4YcdWz--sq1g>
    <xme:UwLIanQ4TiknrjROA7FgkcTIrwQ92FJ_Hl6GRW5m2mjTpkWfV-fNDKcUspDb1yeyY
    4o8jKgc7OfqwwwpD3TwMG3BXPjKKPqtlxnEpS8xrEKQGtmkCl239bxq>
X-ME-Proxy-Cause: dmFkZTGCgn18q6onk7BkDm9agxuveUmNgo3L7iutLSfsmIILsksdIDaubBNPfjkwt2TMDx
    VnnEPAFf+/OxtSUUAmtm5Gq9NEd4YLeYXeZK476PMO4xiZ/jb1RZEZ3/oAgSuhQCuqMCeN
    w9JjpldH1rYKhxB2XEY5j1Orpb6qiB64nxcBSzP0sXieWzCgL7+8Sj4oM0jx3ilioMSABj
    jy6hz8M8vQAChUxRwu5eTeW4PHjlnWuRy1bS5XvTI0H21ukPqVPEZ2Rgfe5MZxqpmNK91w
    HBUOejGyraBdvdmoLfw/wlAncCts4XZEWPek2S+8PMR/mnS5vqhkUmNx7GbXW4YuIT4RSK
    aI9qmQL3bmm+G1zwS+jAN+/x3vLP1r8k1r/vhzP6ageGW+15zB5ggRugjxbW30TunqCDzh
    hORLM79J3S3e1q4By+zHwMvqjbg/Esb22H0+wfduOIa6gB24NKEvX4jDyXJ6Cbn6ghoJCX
    V1+ZECLlCqJ1YQM2+4b/iBvqXNz0fy8JxahONxu7oWsvY7NrP0bKUAE5yd+we+duHPoi30
    P3sXj64wadVm2opzLBqmNbLWXhC582wLT44lYwPmINg7qOt+PtdxeSGqKaLvpbAgzCZU3W
    psOfeZ95w1zWT6HD2jRBbQxwAiKqVsuEWUlF628ZSw7BNiEJ1ByR+bv517HA
X-ME-Proxy: <xmx:UwLIaqZL9U4e8euPCyptIuJpFuQW-HvBGl2TBmSHcnLPyKBlCXT_KA>
    <xmx:UwLIarWiStljZndP0vJ0vLUbKv6KaOJHj_a3N9XfdBhZZTYidjEgDQ>
    <xmx:UwLIashimHF4IaqZEeXTfixEjMfr0GY-zQIDHzsYbm4WmlkU0GJxIQ>
    <xmx:UwLIapWqmWR6qzYQT1dkvhewx5_7yoNDq_tuWBcmVFlJhSezwIkR7Q>
    <xmx:UwLIajMyoDexl0In1OcYjvc8aFM9XzcGo_1WKUJswk-mXJo6a87TUjq4>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CFEDC780075; Thu,  8 Oct 2026 16:51:31 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AQq9afuTvUIV
Date: Thu, 08 Oct 2026 16:51:11 -0400
From: "Chuck Lever" <cel@kernel.org>
To: calum.mackay@oracle.com
Cc: linux-nfs@vger.kernel.org
Message-Id: <8ac9f4ff-ffe0-462d-a5dd-097d0be24722@slotpi15m67>
In-Reply-To: <db8dd3c0-0e51-4d3a-a98b-4ceb4f31daa7@oracle.com>
References: <20251007204806.15560-1-cel@kernel.org>
 <ece49885-7f63-4be8-a8b8-810c9ae4580f@slotpi15m67>
 <db8dd3c0-0e51-4d3a-a98b-4ceb4f31daa7@oracle.com>
Subject: Re: [PATCH] SEQ_FALSE_RETRY is allowed for a solo SEQUENCE replay
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/5/26 9:45 AM, Calum Mackay wrote:
> Yes, sorry, I have a bit of a backlog, I'll get to it asap. No need to
> resend.

Hi Calum -

Let's drop this one instead.

I wrote it to keep SEQ9f passing against a draft NFSD change that
returned NFS4ERR_SEQ_FALSE_RETRY for a replayed solo SEQUENCE. But
auditing the kernel commit log shows that change was never applied;
it was rejected during review, so the test is correct as it
stands.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
