Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A0164BA1D3
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 17:15:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791825309; cv=none; b=fxUmJ52X/sHOXDzsuLTtCJ6pgR32wTR4y7uMEa28qGWoRz11jIP4Q83WQqH2qt212pUbauhASygtvWy0eLD6RsAhE1QUDtfvEXqfWpseUsxzsnnShi/p3uaCgniZ0itXTSdmvDPwG7Kwo37csPE9fFUPAKIXssJaVHP6+JjZqmQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791825309; c=relaxed/simple;
	bh=xb8hGY6EVVscpDL96Rky8moZ9A2rIxvMeN95KlSolyk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Z9n3O2g+YzLUfbBjCgVBv8MQ2cw0OD3upreDmaYGVwyYTMNcLCz+3t4VlVOMq56+P72R73uf4ZXpm6IFVN5p05YkzJ3nrc6XNtoNuwVCoyxbO62HrwdbxEriBPhBtmkYDRrzWOdq8TMxCLCh7zN19KUIB9tol88KEeaspY0C1Cw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=h9AXNP1J; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="h9AXNP1J"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9052B1F0089C;
	Mon, 12 Oct 2026 17:15:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791825307;
	bh=WOSic3bsqy09MSAuiLL/95sqJGC9DFWU9Ea6XtlUexQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=h9AXNP1JeRTf9h5s84J99HDmxo/QsjDduPSWjOeeg5rN1+1+6EO4azRGxRIh6sHxy
	 lJdZCF4WkAX9WXNkwKmyygLvXlU/sN5BLH76lMxM9zD/neUelGWI2VpHs4+rtYvTAa
	 gWqtwMnLpnanBrzb7SJHblFAR1lhLy9QRc8ZixVDA1dqXLyV5ebck5ymSB14doOiSn
	 3ehLC4tVjtlmZEPvVso3NEq+7Ju/I8IKsVtjAek1pVRSJaWudN/Ycd1QyeQ91ifPWq
	 yIdJYtkQoLpHD2x4z0bS3M4+opNKWfajsRlEaNpHCHsPJlFA0s/Gmg4b5jPbghR6I4
	 pUd9cN0UffhlQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id CB263F4006A;
	Mon, 12 Oct 2026 13:15:06 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 12 Oct 2026 13:15:06 -0400
X-ME-Sender: <xms:mhXNamY045grLgQm6zBSi4jpKneG3bB6S5g-MW2xb4poBzLCuYZICA>
    <xme:mhXNakPHZ9dlxM5pMM0hxTaHQtf6bNsSeR8zIOJ4TGDzPF6lJ9qouBQHZZ8ZrWgsA
    Tez4LL1qMuIPmyrcSBE9ZLrhWCZ7LtpgEW_Gj5PJlolsxzQH8ZzrdZ1>
X-ME-Proxy-Cause: dmFkZTGzy3X5iPwFWAhBRlYjFECOvsaHsV2ec/Nu1T3Jnw9vlE6wSl8eRvSMVHRaShiaO8
    2WFDm1nL6OcMoxaQ9QaLnx/ew8dQTz6igrOSS2gcMr3ek5TSP6cPUwGfUWutahmJFFjyUR
    I+SWMLEiDqOtrqkHI329fOtlwhhLnCCuwGvkcEOUbB7s4dRZmK0iNzrgDfYRfBXOqDeg8O
    DNbpuAy5qxLmiC+qE51zbnOk9i+A8QEtOBLwRYh2PQrhNCoJ6iQcMpwSTxTDJyTJJMaZQH
    vaItIpks59kydkHYFOkA6w3tuDY1QcWUHf49cgRHbMCfz1WsvKXUNYuZUA8Eqjw7BKlJF7
    RATR2tAlDvqJmvCsH6MRaB3WnS3sfs8ASA+mNBdAlZGyUAGE2ZqvBsaJAXQhlkn+kwQa+h
    3WqHXF/MQK9Y+qQqnl/jVSsq+t/hhSvHMeA4AI+ZbTEC6ydq6N/Wees8zDeeddgMCNI05p
    VPW2PoFH5qODAFAyNy32jdlLZezvdMV+C2jUaQqfRNDR6xe+2FuYL4ZG7XFz+V4Qb/6D54
    9E3pNtSR1HANZY9sp8U9MX8DPjFMM4xVqZovlYPcsvWWmtRlQhdsYmD/Z2pnaNvZab3CL9
    jNIDGp3WITUsOaIj3g4slPptmeyTDbtlMAVOd29zB5QqKDebqubVN4SoNmfA
X-ME-Proxy: <xmx:mhXNah4u-4Cn3JjsccHekKpPqxkkhi7ZBaN-MTjJ51WfayDq7RzuEg>
    <xmx:mhXNah-Yfk5LatKFPnEUkHgEO_i4I2l1j6pk1eX24pasgqYt_E_NUg>
    <xmx:mhXNajF3RKP4fptH79tlHE8ia__mfevDW4h0ruvvRAIcnElOOlmFnA>
    <xmx:mhXNamU9az_kapnoTo8eZiB-En-bpWwyGdqRP1EEYAPG1jnt5lI1uw>
    <xmx:mhXNav9Krhxkv9RKDMGqHi5s_y9MNBYdXRP8AJNNZv8aXbveKkrwSEEx>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id ADF9E782738; Mon, 12 Oct 2026 13:15:06 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AF59KJUIYQhJ
Date: Mon, 12 Oct 2026 13:14:46 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jinpyo Lee" <bint4b13@gmail.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, BoB_Tobabz <bobtobabz@gmail.com>,
 linux-nfs@vger.kernel.org
Message-Id: <a87481d1-1246-49e7-8f3d-196b65301e5c@app.fastmail.com>
In-Reply-To: <20261012112710.773-1-bint4b13@gmail.com>
References: <031205cd-1099-47a0-889f-ae203fd6c8c5@slotpi15m67>
 <20261012112710.773-1-bint4b13@gmail.com>
Subject: Re: [PATCH v3] nfs/localio: pin UUIDs during global invalidation
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Mon, Oct 12, 2026, at 7:27 AM, Jinpyo Lee wrote:
> nfs_localio_invalidate_clients() moves UUID nodes embedded in nfs_client
> objects to a private list, then walks that list without retaining the
> containing clients. Concurrent client teardown can free an entry that
> the iterator has already selected, causing a use-after-free.
>
> Take a reference to each selected UUID under the namespace list lock.
> Keep this reference count in nfs_common, independently of cl_count, and
> have nfs_free_client() drain temporary UUID users before freeing the
> client. Releasing a UUID reference wakes waiting probes and signals
> completion when the last reference is dropped. It neither calls into
> nfs.ko nor performs final NFS client teardown in the NFSD invalidation
> context.

Until someone tells me otherwise, I will treat this patch as going through
the NFS client tree(s).


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
