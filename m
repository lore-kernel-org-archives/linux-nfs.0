Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 332B743FD18;
	Tue, 22 Sep 2026 15:50:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790092245; cv=none; b=rUznNUR2Fee0+wq/N8uJmeEOwfaYdb7JioA3U0QCLjzI0MkWw9DFNd6Or1EZ+G5SXs3/mROZtkbVQDwR0rqyHeOtx+FeDLqn5OOuFPpbgPtIIXnNi5vXuKnkoNRPAZaKJ+TeXDaDn9TPFo08FRGI17JfoA95i/mNRBuldTuFN/o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790092245; c=relaxed/simple;
	bh=f+Imo4b1lwgAyODO1NhF2C/2oPWOE6s4hRbPghNP2oc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Z2vTJo4dzrwXy8XK8HVSCmbygBBr5G25iG9rzJXOPxr+RqgVDKQYOtwYxlguI9bLzlfi6ObixwSiBDK5zhHD6nAmg90EQ53RacgKnS8ztyNVX30maohl+CpZ7fI40jeNHXrTAGrKKZT/GB+5Djy0pqO/I7B5b2otAuqR6jML1qY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f13Ggwt1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f13Ggwt1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E7BF1F0089A;
	Tue, 22 Sep 2026 15:50:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790092243;
	bh=mFC/KqKwts/3O7F2OeiAqUhvzsqgNKQHaS0taMQl8Xg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=f13Ggwt1EiAxovPb/vbiXzDRe7OOxnOFjk6okTx1J8mrkGBK/FWMKeGKPuS0L6gav
	 eW+J73MXDNgCtz7wMPiLFLeqJIR1Z7rFjKT+HZT+TCFRRpnXWtXWxUt0uEXeRHkYOa
	 GIyJ2KPlbFswbvZ36zn8RJ7VmAtg0PmBj7Ck0gLsleVpUxNlqcIBQdSWklI5PcuhQy
	 PRhtkANZOOyjg7LkYukVFxiBB8r0o9+RnLIX9s0F9VXpRUMMGOlEnpCciMEwPImGXR
	 TAZ0JqoJBI8u4tva87sioWIOG8AVdupBp+9+eycDB/VgrqxWb3nMivQCETX9x8IiHV
	 C5foc49ra0K8Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Shuah Khan <shuah@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-kselftest@vger.kernel.org
Subject: Re: [PATCH v2 0/8] nfsd: reduce the scope of the nfsd_mutex
Date: Tue, 22 Sep 2026 11:50:36 -0400
Message-ID: <179009210791.3799844.13806982251385485248.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 22 Sep 2026 07:34:01 -0400, Jeff Layton wrote:
> Currently much of nfsd's administration is serialized under the global
> nfsd_mutex, even though most of the objects managed under it are
> segregated by net namespace.
> 
> This patchset does a couple of small cleanups and then adds a new
> per-net mutex and moves all of the appropriate per-net data structures
> to be protected by it instead of the global mutex. The filecache is
> given its own mutex, and the global mutex is renamed and left for
> managing just the few remaning global objects.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/8] nfsd: clear NFSD_NET_UP before dropping the generic resource reference
      commit: 77881893d52fc4ac737bd55727eca54cb95d6002
[2/8] nfsd: make max_blksize a per-namespace setting
      commit: 4a29b69535eb2778255634b795ad9c026269a95f
[3/8] nfsd: move the control plane to a per-namespace mutex
      commit: 88815584b68611c3eeb6f536b8dc1f4a2274c129
[4/8] nfsd: rename nfsd_mutex to nfsd_global_mutex
      commit: 828e48566b8145969f93df212628349e4d2849d0
[5/8] nfsd: give the open file cache its own mutex
      commit: 4ad8170fd7287fbf7adc493c785a284fe213065f
[6/8] selftests/nfsd: factor the netlink plumbing into a shared header
      commit: e99f6a7157acd18cda500c2bcbb17761ecfede3f
[7/8] selftests/nfsd: add cross-namespace isolation tests
      commit: 20801469b68a678a06b51592a1f90cb018983cf9
[8/8] selftests/nfsd: add a cross-namespace control-plane soak
      commit: a55e35036b7e984e601264565c767a23582c2175

--
Chuck Lever

