Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5EC035D5FE;
	Thu, 12 Feb 2026 16:44:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770914660; cv=none; b=ZcLnQaKL1DRXAdZBZ+HPPxESuPF2SawFkURih8S5lKlLpZDGiGKh529ALgX07CrFuo7QJe+b3/Vch6T0JClMGYefjCReShJiXGyyEO80AKun537zu/5xAD/un4aiXf2P0mPwXLwfCT8Q66uEiLNdDu6G5Mucroc9Hb0WchEt6Hc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770914660; c=relaxed/simple;
	bh=kL139iZ17lITMYQ7JOfVYPeNYaJMn3yHJhBNBHl8NB4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=pAxX/opTYjb0pSKXkIhhv+5J5IsOuCGS4ibyEH9r1Idim2p1rjk5EkqwvKd9gore4P4/rzju9o2JgJjKXrWrGBenFX9h3ZdjEckmezfQuleWgkXPsnev3L9RsWYqBbJwgfBMKnDcnQGmndjDIX0XGcPC16vN/bPucU11GA8mFIw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CK7rjrtO; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CK7rjrtO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5AC7DC19421;
	Thu, 12 Feb 2026 16:44:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770914660;
	bh=kL139iZ17lITMYQ7JOfVYPeNYaJMn3yHJhBNBHl8NB4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=CK7rjrtOn3b/ZaJu3Yg5qFcHhCAiwKdFwBd5jq4yA1LWBWkN0W7TwxwfJrRv2Z5wG
	 6vQt5tpomZYvO8lBcxKTM/IQvO69gACjwScQABSZnIQTW4bhNKCUj57kJ2LvLTkF26
	 xpOah97FmbaPfxWlwzyAUKwUtPGCf8BzpQgHkXdYpJ/dHCc2J6xEcLakLNIifqQY9f
	 NwqO7FRPKH1UAS5mC75BV5C7A0QhrI+iBVJcpJbAqjAFD2I/58Iq4/UR35z/wJI2yA
	 RSfNH7FfoGugDvo9PDWTQAS9SAeezZJC6TvqqlONoC8jWE7cgjPhLV2WQq0aUXYq1E
	 I4xkUYEcZb7aw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Eric Biggers <ebiggers@kernel.org>,
	Rick Macklem <rick.macklem@gmail.com>,
	Benjamin Coddington <bcodding@hammerspace.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-crypto@vger.kernel.org
Subject: Re: [PATCH RESEND v6 0/3] kNFSD Signed Filehandles
Date: Thu, 12 Feb 2026 11:44:14 -0500
Message-ID: <177091459809.39395.17906159035130936914.b4-ty@oracle.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <cover.1770873427.git.bcodding@hammerspace.com>
References: <cover.1770873427.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Thu, 12 Feb 2026 00:25:13 -0500, Benjamin Coddington wrote:
> The following series enables the linux NFS server to add a Message
> Authentication Code (MAC) to the filehandles it gives to clients.  This
> provides additional protection to the exported filesystem against filehandle
> guessing attacks.
> 
> Filesystems generate their own filehandles through the export_operation
> "encode_fh" and a filehandle provides sufficient access to open a file
> without needing to perform a lookup.  A trusted NFS client holding a valid
> filehandle can remotely access the corresponding file without reference to
> access-path restrictions that might be imposed by the ancestor directories
> or the server exports.
> 
> [...]

Applied to nfsd-testing, thanks!

Cosmetic changes were made. Please review the patches in branch.

[1/3] NFSD: Add a key for signing filehandles
      commit: 622534d4910f8cddbf7cccb502cd896e023b654f
[2/3] NFSD/export: Add sign_fh export option
      commit: 482e15caec14726c6612dba3f482ad525deb0be5
[3/3] NFSD: Sign filehandles
      commit: b4169318a0afd386290548418e8d5f23b2cf2cc3

--
Chuck Lever

