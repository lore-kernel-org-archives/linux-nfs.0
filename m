Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B54041C2FF;
	Tue, 26 May 2026 18:39:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779820748; cv=none; b=NU3dxarBQMBTWdAe/daqI2okyFUAqI0UzAzVleRZa1mZLeyiWItdyUEDGEY1AYqPUQVSaG35zrA2uorbeFOE4hHhqupPNCQ/iH3ylJcaSFLfe8uJAlphV7X8RjyPgjEVSVU41wIXId4939LHh+yQlvocSZTseB7GptMe9zvCFjg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779820748; c=relaxed/simple;
	bh=zoo1dZzT2TKaPFYd2Afv4DY5BGYpGjlGtbWt5lnQrEw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=VIbs5frFBN+lxHwiSCLGnhzJqKdBmMQVt0+6wNP/1CzyfzbOJGTxPgQYhvWNXTkbgal00ZgKSyjZKJDRe6atNvyxhx3JzNcze0gkAf+Js4OyLEZxgLONrU+XnABTDXJypphygJI2Di/4GuJvM61eH/WO8Wth5xfrBjf5MbQJn0I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EEF74yAC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EEF74yAC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E95F1F000E9;
	Tue, 26 May 2026 18:39:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779820746;
	bh=R3k5/oNTeSPUABKDky5qbmvUFNsQ30aZo6y/dTTH9D8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EEF74yACAQvVyCVG5W1mEd5D70QQY6moNAXQ8TK5DxGtOELYQcx7S9WLLC40/ovAn
	 Ei0KGp2dMKjX5h42X1gB6S09FKy3aATb5okqndFSU+OnF7Anx4i0Kdmtfz1v+mkELM
	 PAvv3TEaXkWdwDkLiLgbci6qHyx6aIIwfooAjaUXLpdQJts//HYojbVTOlxlPIUNpD
	 qpjQNMrwkDG7c15ye4awO0gpobWUXDq+ev6ugy8LHlWiobjF537XdiFhfn3t6iWtXB
	 fTOrvZe10MisL7iMwqfcio/EVuc8s04qpHEx1ew9UQMsOUi+4fxN6jVBeQ11tAeCkh
	 CFxQdnSvFUh3w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsd: callback channel fixes
Date: Tue, 26 May 2026 14:39:02 -0400
Message-ID: <177982071777.99111.11306650283701065645.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260526-cb_recall_any_callback_running_stuck-v1-0-310011a028f3@kernel.org>
References: <20260526-cb_recall_any_callback_running_stuck-v1-0-310011a028f3@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 26 May 2026 12:38:44 -0400, Jeff Layton wrote:
> Some fixes for the callback channel machinery. These problems were
> mostly found via agentic scans.

Applied to nfsd-testing, thanks!

[1/2] nfsd: defer setting NFSD4_CALLBACK_RUNNING in deleg_reaper
      commit: 02b9bb6ab68a77b1112d48411e4e08308a077ea0
[2/2] nfsd: clear CALLBACK_RUNNING on failed delegation recall queue
      commit: e02bd0e5a983b4d617dd2222c81c7f057132c211

--
Chuck Lever <chuck.lever@oracle.com>
