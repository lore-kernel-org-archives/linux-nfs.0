Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 113CE246766;
	Thu, 16 Apr 2026 17:09:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776359381; cv=none; b=Y0DvnhDTOAfZIDUarLYX84mqlqoRtJpQEXXD2BQ7Wp9jtLzEaCMQrxbKgyvcIgMMrb5nQVwUILnzI3HPyfZ0yUoOBMekxHqulVQHyC7xH2qPAeN8C4pNtP+HDHKVgmRi2qbHpQ9Qu7SnXtGqJpKbpxwlSeRHDLG9pSIh7ONiFHQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776359381; c=relaxed/simple;
	bh=KAiERxxymUZpTj+6Dq8+1Qx+Mxf7DJP+uiI9pcwBTAo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=sDWIUfEnv+ba14xATq8so3L+U4ejudGAj50YAnJ9LTJydRmleRFdx5v/8njrvnH85A4wLR8MDatRhi0oNeJEzIXob0U2E301PyzJz+t00Xgw9uVdOi4spxn4/NB9qGgyhf+JXX0tb2SKaQbiUqcRmTR3bcdX72xaxZCugSreglw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VrnAIRHn; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VrnAIRHn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C1D8C2BCAF;
	Thu, 16 Apr 2026 17:09:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776359380;
	bh=KAiERxxymUZpTj+6Dq8+1Qx+Mxf7DJP+uiI9pcwBTAo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=VrnAIRHngsP5l6EAmhIcERhAOe18S2Hs0LRqntV+xTKqozCUT8OsmQmffb053F1FN
	 zyKARiD12meyvOqNCrW/VqA5cRONe96bFF+IInym+SKGIhGKGZ53yhSDcAQUl7rVE6
	 dR55xaQRLauCUSp7g0/XJSUI9mzfyyeC7pUt6udtPzh2IHPaU3chsLLu6oEFhN0O1I
	 SBEl6jgybcBXEouL5YZpas4c20cqzFt+q+TX4v9svEUcJ+1yZkq7zUn3eJFh/1Jato
	 Jv9rKQgBDEbfobSAWq97I2HDNL3TmoY7t9DHh+6VPD2z8WKbqZX2fyJmd3vDnulEFW
	 uEz15RSiChxbQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Nathan Chancellor <nathan@kernel.org>,
	Nick Desaulniers <nick.desaulniers+lkml@gmail.com>,
	Bill Wendling <morbo@google.com>,
	Justin Stitt <justinstitt@google.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	llvm@lists.linux.dev,
	Anna Schumaker <anna@kernel.org>
Subject: Re: [PATCH] nfsd: add missing function name to kerneldoc comment for nfsd_nl_parse_one_export
Date: Thu, 16 Apr 2026 13:09:36 -0400
Message-ID: <177635936245.12505.1422177037243680976.b4-ty@oracle.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260416-nfsd-doc-v1-1-313ee1b29ff6@kernel.org>
References: <20260416-nfsd-doc-v1-1-313ee1b29ff6@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Thu, 16 Apr 2026 09:10:00 -0700, Jeff Layton wrote:
> Anna was seeing these warnings with a clang W=1 build:
> 
> Warning: fs/nfsd/export.c:845 Cannot find identifier on line:
> 
> @cd: cache_detail for the svc_export cache,
> Warning: fs/nfsd/export.c:846 Cannot find identifier on line:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: add missing function name to kerneldoc comment for nfsd_nl_parse_one_export
      (no commit info)

--
Chuck Lever <chuck.lever@oracle.com>
