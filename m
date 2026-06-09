Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43CDC25B0A6
	for <linux-nfs@vger.kernel.org>; Tue,  9 Jun 2026 00:33:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780965228; cv=none; b=JFgNNbHm8okP56hkXhPFLHlqkSxYHuhflIYC14X4VX5LqaUIY+ZQZLzBNgUR3GreeZ0RzvzgutSXeQ0cjlVL2ebOkghxqqATaJcuiGO/LbSCEqfPVvOYeC2Ud4breo3U8Y4WnusMDjHio4AfiGFc/Stq2wVEzvqVEJuIHQ7Vvgw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780965228; c=relaxed/simple;
	bh=4BDaSKNnO+9IDR5DcWlnWEKpMx/wr6udWoa6eoDrvnk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=tTNb98wg9o3QtUREwuhO67IlW6pcZ9XYVMJZ7Rx34mKVrnEe5wtSrUAndiJW+Nvf1FvIrylWe6JhCnWsCNWQGQUPonOo6UlDMbm9qu56LvgjXqkg57yACdvzkmsffJSR7L5HQGU56R2q/3fVtjOirG3UIuvmm482vxuY3Dq2WBU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YaskCfwA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YaskCfwA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 495351F00898;
	Tue,  9 Jun 2026 00:33:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780965227;
	bh=/ayfQF7CQIgWL0+T3brAhz1iir9IHt/iYBZr0g2+2mQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=YaskCfwAo9ZxWB3/WMV2vibqPgco/1w2eR92RXrLontD2ejoJgyGMvBIkQxol1yfQ
	 snF1zM78IphgMSx1+hwk0A5XjEIRAsf0YTBPwWP8nclo6HA89aRwp/gDvsg1xF32cn
	 faBBzEG4Xuz/ZcioGGm3Kue34MEuQpu+GigdMaQRfGRT0KiDRUDsk9wnq4czBya8i2
	 vXaadNDGUVhH0oRePfe8yyIJHtaYx7Dcxd6A5mDBnNLeKnA4SE/gEtC9+dvQ0eFXOs
	 8d+4NsCWiWp1HDqG2daxXKuFoBfRBMvYorakBcFJou5XAR5liewEesec16DQNWvDrM
	 fOLY+JRtiu4zA==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Scott Mayhew <smayhew@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: fix up error returned by write_threads()
Date: Mon,  8 Jun 2026 20:33:39 -0400
Message-ID: <178096512219.86595.6779381800614443178.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260608131402.95625-1-smayhew@redhat.com>
References: <20260608131402.95625-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Mon, 08 Jun 2026 09:14:02 -0400, Scott Mayhew wrote:
> Previously, writing 0 to /proc/fs/nfsd/threads would return 0 if the NFS
> server wasn't running.  After commit 14282cc3cfa2, -EIO is returned.
> Existing scripts don't expect this behavior.
> 
> Add a check to bypass the call to nfsd_svc() when newthreads is 0 and
> the NFS server is already stopped.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: fix up error returned by write_threads()
      commit: 36f28c2e37a6a508f5a7be62ebe9c8887ed9bd20

--
Chuck Lever <chuck.lever@oracle.com>
