Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793972658;
	b=nKALC2pwXTjMHPIqzdQLXxWpzTklnv5Nx21wF4itsCfjz0ocin/SEM8Sx+UCBpt9pwoe
	 oWxcN9uUcTcZW2KhzzBrCcYpWgPXdWl8HQUuwkONavZKG+bQGasynmNL+0A5dGO82p8UA
	 1CD9E4LXN+FTLNMaxqbCuNFu6bMPdCn1NibNUrdrC9Jt/OeJ6xTBB/+5ABqXnFIVAUNFq
	 ly/AOEsDt5234hIHUbTAoQqRqb3y+XGMs88nSL4SVVQl8d+VQac6jqzIOx9bDMzZEnv8b
	 GwM2rJsui8Ar0JYDdDXSu3Qg3VfvNwPkRwR/5x7VoLCNkOBo/Nlny/wpvk952YKjwcQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793972658;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=kdvH9N0+RLZ/I1FKn5Ph6lXH4xI1LrLkCwoasxHohy8=;
	b=CQ1iDdi5T8+87jj1BqebiQZbonLyfNT5Fsb8WGcKekmR+AS3GWp1cfRrmbygbdav7gNW
	 yUgPL6pgXAnN+jTezTX9WtgVfWMESjJmTsV3wCAFReqYTd/HxCKxm8/tCmZgL4xoGgewc
	 0O95PLcrARw9osB8rpjhA/9CB4xJTzumJk4VoQvEgZEWCK9gv/ZCL0mNaMMiZjK4u9B6l
	 UEP9iLuu85+5HaGoQKSLVyy3R0xXL05kqtX/W1AVN64gYhQtM65HQiBS1jlE1ua91eLT3
	 TZD+c3h3Jx051AvJOpOJ8MkRsOxYDSmDDUXtKnOG+qzeJFHBUMXokMGkG7ZeVOGckHw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C59y0W3J;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DE51606D802
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 13:44:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=C59y0W3J
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D5B911F008A4
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 13:44:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793972658;
	bh=kdvH9N0+RLZ/I1FKn5Ph6lXH4xI1LrLkCwoasxHohy8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=C59y0W3JFTNBbNWdgv+5O4DoVkuxYNA8/oJF9/rR9KuhoooRUwRSi1T/nc2u6yoPx
	 xMG6joazkriA3KaPOJQARhc3A4APcxN3z0w8HFrYgmcXCFpIsJkAmQsNoNdsKVhq1/
	 LYUfhXGrig7gY03LqAHXWwp7h6P6L3RCYCDLhUbWTYxItMDLipRhbmzZkLlb4tkzKF
	 uxboPZVNKXqpp7g1QtxaADp4nvFL90Jp/jReWg//B+iKBWTYxJzyKrTwRI195zycY8
	 KzXgHqGr5lWKUdOaRk+nORLkSzzGk3I8W0IBV6qd/RuOezVvf5dXF2mN+rWv9VNf56
	 Gh3C6zADyREzA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 084F9F40068;
	Fri,  6 Nov 2026 08:44:17 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 06 Nov 2026 08:44:17 -0500
X-ME-Sender: <xms:sNntajFlDGwGWz8icR3dra_FMr8gwhvmvoDqjmjIEYlv-zxlqc5SLg>
    <xme:sNntarLv68bEZ-4mzY5w-Lnj-sgGltkMcG60l-R_0yFyFAWhgH9meUjGBc-Vv5jF0
    XNmBmkna-6uIG-shPrl10NjUDDzOpjJsNTm1SZEc17w0vShS8Ja7eeD>
X-ME-Proxy-Cause: dmFkZTEJrm6SIZp0eyGRcS2OlpWT4bVs+0FY6WzLK1cY88Rguo2sKkV/kZWrJwT7mPwHvq
    kvNYmcR29I1RKDnnG+O1YQXX5KX5cZYaNdCUExPJylpMoX6LjjpOgURG3OtVc1dDuc06XI
    8TfB+9dFrOtmrrvhTqaZItedqpQ86krx9W/Mg6zLhaoOYCDIEQDC2IygA2rQcs4iAwcmtL
    DSuyd15y/lbdanacnZm6TQ5VMiGUoDwLZAsQwCuxSXi/vGxYaQ+QHIX6xyjJQsG9Dkgk7X
    HmCvx81uInOz5dd49M+ONVVugmwOGKg20Dv+Y/rSPZDgRc1crJ9I0fcXQ1YwnKiuoS+wA4
    MH6wdFS6exZRn6C6zA/azaRyhP2VIeGxkvqF1vhckf3Cm781nD8Zgkl1cMD5OEscrvf8v0
    miH0fhvdrMv3vO4OM5RFf/+8/3Ofav07b+ulR6kuSnanYlEnhf41/2dcaYkzZhuuiIObQp
    02U5/XiL97HIyHhELGe+hG8A4WZRQDW+im9g9HI/8uqTQsfotilM7xQU41wAHop0DHNN5z
    5uIkWH7gsm2TzsF3cYyelICOfFvABSM3z6TNJd/X7CfYdks9LyWy5YktVfQH4gIW26cvti
    8++tKYKj+EKRE2wq56GLCnqlhtTvoq505va6sGS232XyPKp6DOLJo2O7PWbA
X-ME-Proxy: <xmx:sdntakANYznccooGhpEjMCCTq19UcBR4eZRN5vq0WN0tP6Y5t_2Grw>
    <xmx:sdntauSn3gyp7eyq27SvcLtJoOn7PKyL5ePwdPU0AUVjqiowh6UkUA>
    <xmx:sdntaqrPNW4lrjAbNSbyZuDuFosCDyHbDzIJz80EC-JalNIWJcREkg>
    <xmx:sdntaoyoxSwN0AqMLAZFMu2Goz8PtG8_k6Kzj0qRx_HbmyZdqYObhw>
    <xmx:sdntanKVedzN1UnDrB_F5igzzHG9tiDRgo1aRgjWJVXGGi5L7g1O2Jtk>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E2E8878273B; Fri,  6 Nov 2026 08:44:16 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AV0wmJNhj1I7
Date: Fri, 06 Nov 2026 08:43:56 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "HeonJe Lee" <lhj4125@gluesys.com>, linux-nfs@vger.kernel.org
Cc: "Jeff Layton" <jlayton@kernel.org>
Message-Id: <7559d24b-9dac-4da6-b7aa-27d6292b5606@app.fastmail.com>
In-Reply-To: <20261106093457.1682504-1-lhj4125@gluesys.com>
References: <20261015114755.33331-1-lhjnano@gmail.com>
 <20261106093457.1682504-1-lhj4125@gluesys.com>
Subject: Re: [PATCH] NFSD: wait for nfsdcld to open the cld pipe
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Nov 6, 2026, at 4:34 AM, HeonJe Lee wrote:
> Friendly ping on the nfsdcld daemon_init()/daemon_ready() conversion
> posted earlier in this thread.  Happy to rework it if there is
> feedback.

Direct your proposed patch to SteveD@redhat.com who is the maintainer
of nfs-utils.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
