Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E341D4AAC75
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 20:17:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791145046; cv=none; b=aGbtrHtY7o4K6ugllFU0W2/2wlJLW4xQHIFiayz4KlXf5ajgWfH+Cqli4HURpNgk/vMwLlKIgt/3aLIwI5r0WY1062gLN7y10jv9Clzdm9i8YR+ea1t/T8H+FfZQrrP64EG3zkEZ3EvSeREfyrUcvVheHSRp/X9K+o8BVLEpXcQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791145046; c=relaxed/simple;
	bh=SZxzzKhPnDsnif35ljedjBOQWO7hJlYBYtTZu9YwJ4w=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Bxgd52n1Uj2lQNVMtxugATGOA1LOPZbNitOjj8Wqi05v+k/DF2I+1b4yoNxGvm/YP4Ks5pgsWlIpGBbux804htwvlJE2dyUtD5PIBs759xbTJ/wNCdQWxLAnIfNrA3lIv07Ri+Nz0wfeTPD3QKsoGXTdnBUL1Mms8DkoOBzCMh0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=L3Bp1vYd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="L3Bp1vYd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 64D6F1F0089B
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 20:17:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791145044;
	bh=1HMvKD2ePcfGsX7XFdfQKJuH0Tly99YvmdXK/FGIShA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=L3Bp1vYdkdR+fWPzH7l2DGgK2buc4Th36PZnsWjwMIfICwkpDeQ+eEYdlEaGEbMxy
	 77EQyBCUdzPfFNoOOp2VikM6tSdLnAW/rZ4VQ+1AUu0zVwXf2KNfHmaYnuFgjhT2Yu
	 9Q0aCTPG5522RNvCs38EnWcuMTTWZ75Mj0TDuE+LWldKqclVEbWNlg6VpmcmS5sMkT
	 xP0NXQC6ukgMLccLGRThAjy0e3hUkk4r4ijOLPWfg0NWaYOKpFUIuko5++AINOzLfC
	 4MBtd9NHUPY0Arh7iHMnhh6nZVK6Ah+VRZhB5gHKG4uKMyDLNRY8M5mQkKLf15bCld
	 BntAhDnPSxn1A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 322A1F40067;
	Sun,  4 Oct 2026 16:17:23 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 04 Oct 2026 16:17:23 -0400
X-ME-Sender: <xms:U7TCaoSBQt_CsvoPDtErZXm_XOx_e_wureDy50ro4yrML9tw2Ztdaw>
    <xme:U7TCagmR7IioZU-1f3nvQxMvapgZd_a_ZHgEhzbhPy5_ds7FR7SqYOsFyGKwMO5rE
    siMmbf9XnFKK4wWqWN7oOjsG7QO_TFXj-QOnkCLNTk6YEx4i1Uh27Zs>
X-ME-Proxy-Cause: dmFkZTGOUhqAJhXySWEUw5XUMmciwYYGApt3uiZtHFL+fPKy3W2Q2mPUcjFnMEUz1uAptX
    L+htqbEgy1qd+bF0T6R+fBfVjfaynJaNG8EUdLyZHb1kmC+fFjAMJkajpx3I5ELQpL4S+m
    IzLXiTVPS4xFVBpkEzeY5Jw2PMS8m/uam6FubeCjgiuYlYzzdk6ouuul4rS4bDBilEDqtX
    +qmJCBftBnEOSL2Ix/JFRyL3v80S/2Fk89EPOGYO3DVisqQaiGSjEp65afBCusv9nsYLfp
    IubMBI7WnmEtqrF7zCb0TpsmnLZNi6TUkHW0PNnioRhp/dEo2v6Caf9fypYBuJ0WxUeIne
    QNv4u1Xi6XWFMhJCPFS+nSwZ7itVoPxPk8BbpjheDdwiccSfVAayRCHx71S2z1jKCo+nVV
    vmwi9xhpKdnzxxean8X77URzgXJLmBQvNBqD3+igeGOm4aJPjtXzxL79snlrwlx28PGHCb
    oIuIRhr2R2NeLmtzOjyCdrXWS1iPwGnMZJQdZrFRDNIRVqJAVaIpmxASPGEqPwnd6ohgX/
    714RHajcUw+55flSmbfeZNXkaUWXVkU3Zbm3xYHdfR821ZyjEHHozzdrvwS9rbMMz39Vmv
    1V0kSWeW/JPWLIi6dE9baYxNt08rFiC34OlINJUHH8epqQ2Mc1IvFrxGhe5w
X-ME-Proxy: <xmx:U7TCaq9RAGCzl0GltdUpmKySOPN5blUQXtMVcA0ap7xNxcc-RHSjEQ>
    <xmx:U7TCaopKtGCbaybq3N25M-lAsJV3_tNvHTgKKtKU-bDlskDmtxcEww>
    <xmx:U7TCank2unRXsDhHoNZLZVMnqrnyVBAmpfbjU1xSst_nqTt0uzm-0A>
    <xmx:U7TCavLSXcNybrJqh0dYxru5oG--67nIytVtVh-6NGrVl-_WBhvRFw>
    <xmx:U7TCaszvJKnpT-eNm_rb3rQfctM7PJ85qgPOdbUpeVjOGcJOEZAhDV_3>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 14CF8780070; Sun,  4 Oct 2026 16:17:23 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AQq9afuTvUIV
Date: Sun, 04 Oct 2026 16:17:02 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Calum Mackay" <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org
Message-Id: <ece49885-7f63-4be8-a8b8-810c9ae4580f@slotpi15m67>
In-Reply-To: <20251007204806.15560-1-cel@kernel.org>
References: <20251007204806.15560-1-cel@kernel.org>
Subject: Re: [PATCH] SEQ_FALSE_RETRY is allowed for a solo SEQUENCE replay
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Calum -

Ping on this one. I don't see it in pynfs master as of commit
cd4701827a82 ("Add some tests for unsupported fattr4 attributes").

Is there anything you'd like changed, or can it be applied as-is?
I'm happy to resend if that's easier.

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
