Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46B1A4C10C5
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:08:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212909; cv=none; b=WmoqxJIfIY5Nc35o894eQPtzIIFMosiH0uQuH/sAT2DMrAgYEPxtngLPBKBBOFcgOehTMGK+9RZ2HmjO+Qw0RFtAshOpFmblYKvJ0WFtrOKhOcOAZ+SKwR3iKL1Za1ku4vpjCeldqJGLFmrbtjwoZbDL8WaLT3pcSdpq00omNi4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212909; c=relaxed/simple;
	bh=RwkgmCsvfiUPCt7JS1wSoEGZb5YO0N1jfrw7O2mcMC4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=OBATloyvIGeEapFpnwPviwtwS3We66ozUe9t5hjwehkgLTlnPeZ0l51j7ER6urEOuuoQ5BSC4FJc+krCRWLYsqSU03iTjsDPh5Kr9zST2iHA6RzDGAv1pAvZjb2dcnB7crOxIX4m7TFQYLMW/bJY5TYTyv99TP3udwL2CAZ04AA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a7WnK9Ay; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a7WnK9Ay"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7186D1F00893;
	Mon,  5 Oct 2026 15:08:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212908;
	bh=wAzJeWUMlP+QPmfN4qaU3uFa0gpyuUIQ0vrhNq5TvEw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=a7WnK9Ay0a7p7CUTENlkbbEIVGyzmrI2LUfIqxH5rGnpHBpOxkOdQGQwqGFwIbJ1o
	 VpiCASuoT04V1RUqAoVWLgV91czotGFNU66cZmaUAWzsjkOIPsUSM9bYCSLXp01j11
	 IX54d7LBGhBQyxntftVYWKnYXj1Q31QIYSqXJO5ZqCaqQ8TjeiR99OJBta6615z/qy
	 oLq4Sk9nCVFoo9+pVH9Boot+/ALwKHb4vJn/lLGCVfPWYOhaN79AzYQPYgihdxI5eS
	 6IOMGj3JzWogYYEg9y36MySQlhmlFCW7afti2T39WlUGy+EU0IAgWOfPhmr19AJhIY
	 pVXq40EJ+D2WQ==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] lockd: make the nlm_file reference count atomic
Date: Mon,  5 Oct 2026 11:08:24 -0400
Message-ID: <179121288076.1503704.1303462722224373341.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <3caeffa75660e6d9a9e0646f38263157b3b6d56d.1790963561.git.bcodding@hammerspace.com>
References: <3caeffa75660e6d9a9e0646f38263157b3b6d56d.1790963561.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 05 Oct 2026 09:44:05 -0400, Benjamin Coddington wrote:
> nlmsvc_create_block() takes its reference on the nlm_file with
> file->f_count++ while holding only that file's f_mutex.  Every other
> update of f_count is made under nlm_file_mutex, and can come from
> another task: nlm_traverse_files() pins each file it visits and runs
> from lockd_down() in any network namespace and from nfsd's unlock_ip and
> unlock_filesystem, and nlm_release_file() runs from the release of a
> GRANTED callback.  An update can be lost, and the count then reaches
> zero while a reference is still held:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] lockd: make the nlm_file reference count atomic
      commit: f58e28b7b1accb462ec995f3a0bb8b87806dd29a

--
Chuck Lever

