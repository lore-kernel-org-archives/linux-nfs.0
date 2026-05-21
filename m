Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC5EA397321;
	Thu, 21 May 2026 19:38:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779392327; cv=none; b=jWUg8j8BE0rrE2tL2fo3X5+k5tLfSI8NdeuyHtcFBwAwiNSSqG3zzW0TlCOy/9sHxWsFCCSijR5EoVE2EgeYBDI0VmSwjuK6qT0A7PqaGEVM6Cin5ETmLVUqARk9Q4NeDuC28hdF2RCBtFE/vTwbFAwptE+cwVnlcJxBMCSUtPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779392327; c=relaxed/simple;
	bh=hLAWrY5EfTh7ozRdcUjUcWx7WDqSweAOzebdbaPmoec=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=dO4GZrD3soZFQeswzCejJM7ztb05dKJ3G786rNLzF75+eWrNHQiG7IDw6EwtT3/+fjxHMHwNiSJYcFINAKtf8vYdeMRovYTLGnxY0hRDgWu20LZAtfphwCYBksnjmcn8bOuXzVUgV+mzb809eDN1NIisRtQmYG3WfXB2BQSPNOo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E+2nlIv3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E+2nlIv3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9336E1F000E9;
	Thu, 21 May 2026 19:38:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779392326;
	bh=Ep0cKs7zbgNLj+rlvFTgvev9jNci4ouADjfa/iRdvAE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=E+2nlIv3RN+GcM4KtorhXo9+ZECr9nu1kP2K8XA1VqYo6rwp+CH+sdjkrU85WXJGW
	 aeTkpRgNBG+L2OHxDEMM9usmDn8Kdk+f86b1gvGb1XQKeAT8K1IB4R26YmDSeuldTq
	 yFaWkd4IyxkOepe65umpX37Y8hfDg8ncCtEvR3nP6c2cVx5zcHXI+FWGXPVmxnVFKu
	 jgHs/50GKl5L/gmdbl1IBMUqomPGEc6U2nkvtO/6Ci+ltyQqfVE5FF3o75ck4D6d0G
	 aGH0eqBIe9UJbxmN3Ro9NFDwoPHFWGDoVVsH9PGtblKAhhur9NKOFDZcJPkb7EzThU
	 wEC9FXqss+CIA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Christian Brauner <brauner@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Chris Mason <clm@meta.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix posix_acl leak and ignored error in nfsd4_create_file
Date: Thu, 21 May 2026 15:38:42 -0400
Message-ID: <177939228456.181423.10188484271133255273.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260521-nfsd4_create_file_leaks_attrs_on_start_creating_err-v1-1-646697806453@kernel.org>
References: <20260521-nfsd4_create_file_leaks_attrs_on_start_creating_err-v1-1-646697806453@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Thu, 21 May 2026 12:37:33 -0400, Jeff Layton wrote:
> nfsd4_create_file() has two bugs in its ACL handling:
> 
> The return value of nfsd4_acl_to_attr() is silently discarded.  When
> the NFSv4-to-POSIX ACL conversion fails (e.g., -EINVAL for
> unsupported ACE types), the file is created without any ACL and the
> client receives NFS4_OK.  This violates RFC 7530/8881 which require
> the server to reject unsupported attributes on CREATE.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: fix posix_acl leak and ignored error in nfsd4_create_file
      commit: 15906201636c0850eff0e2e86791f24e007d4160

--
Chuck Lever <chuck.lever@oracle.com>
