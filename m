Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31DEF2F5321
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 17:14:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783358090; cv=none; b=BqUGAcJ6CyV4iJw4tWB8EYaYg05D9NKhnXuT/VgJtK3S5oovHG1J7zz6Q9r5XhojE2jxMCtXmOlkDQ8dSCapsQJ3vNHEgClssjIahoswoWQxs3jLg1Vx17Q3PI9FG3k20UYNQ/O6TU+tQbDxL5EGd92ndClRnHbUzv1TCc7yQYE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783358090; c=relaxed/simple;
	bh=/F6Czpvi8jjap8qoinl95+/dOW5hRHEazVmBSTN8AtQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=kvaiBfnigbqnEHmVt0FF9qcRfevvp4fn3Pr6YQhYuhLMMcb55eQUoCxkGNHuwC78T8owBnCs+p1fXZ8Dn+HibZRPI6SOSAk62cKN5o/Cu9T70JTaV8cMxg91XypwTwB+gvpN53HoQa+avLW/xp18r2pfJLFIsY3rHqZ3sOj8zUg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=obIfG/LX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="obIfG/LX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4FC161F00A3A;
	Mon,  6 Jul 2026 17:14:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783358088;
	bh=m+WMEWpODhFul2NEnYRbQ6F8ZafAiRsvrYL9zDTH94k=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=obIfG/LXyzHc3NLrF9YhvSkcvATGrNzYnKE+Jr5dW7UEEwt+Q9dg03IxGuKcR222a
	 w6yQ9qm+fDMWkvyi5oEtnKSz61TsjlrCAYkAz4E8RdK1RyXXEBcXMgFazVa0sB3NJX
	 dr90AoOIjlO82HcUlD3LOfW+oFvyI7KcjsHniePWdUJQ0/zMmPpZUKFufgtWyO+D2s
	 bvzxlA5ZbsIjkswfscQJNvWgcqv7JrHWfm7SV11hPMjh0wWydpUoeJvQOmfGxhLBqd
	 n18Y19roU7ogo+80/PfpZRawH6tjT6L33e0HjqMPKuuoCvt0ry9F7CkJl025Mo8k62
	 U1pb85nWPYPoQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 61690F4006B;
	Mon,  6 Jul 2026 13:14:47 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 06 Jul 2026 13:14:47 -0400
X-ME-Sender: <xms:h-JLaqq2UXghVu1bzW_U-2B9yUi9Y2sq4YNSVjo8YJ3rp5gvKXcQAw>
    <xme:h-JLajdWLlEX5J7YMc-Dacu35i6RAkU7YCFq6m5PpsI2aAKLCmv2UFXI0SmzlJWQU
    v29g2kWVh-JkjSGHnDheNBB4JmxHcO9eCrAv0CGH3t1BY4UrYDzNGM>
X-ME-Proxy-Cause: dmFkZTGwLFChWrcq6R1Y77RK4mj1sOXF7/evI0lqibCS3mkPB2AUToGD1j0cjsMipRZhKt
    FkBh89zIwm4sT+mGuZsqWjkhhvtE/AHr/cUG+02Aa/8h2larZUNKitOlP5uG0k7HgeMhZJ
    K032/H2h/+Dw7rdgpuKtwB5CtQSPXYI+oS5khjUHw9sscmSyf6I94Y8LcBN7UTKKdu7pjU
    LCHbmuh6zmZ3Ndi5O8o54r7p7NmidDGZptF3iLq0iAZwq7VfRa5aBaBTuQCIMNzWjf4Iop
    PAe+lA49aEcHHn9Z8CTj1UdUCdjtWLqv5UATPFwA05vQr2woEJaaMiS+xWLKul8TX410bu
    JUOQ5ilTZh6ePcMkuktxDLaDSNZaDk+P9ll/OScHoaiFM6hbflGScSfL1obE6AgMqL3Q33
    XQA120KWG9iLdzcZupRYtJt63QQmPWRe59ZgU/yb/sGUNP/v69Q4xXOvik9BuUXL5kTm36
    p9T3MGYVAH2mubVNtyvmK2FifXrbzkGTv5HD9MUY0XhHYgTwgPqU2e+FWYg82TzNWJVzJd
    5MIecjqrdEbJNCApFhcOlolW+XNfBmXxpjJX2mEFtwVMKJrqDKFMVc/Zr9sSH+7CrAFXQX
    q6z/4IfRIKsYc6NRe+6vDlJQDDCMHUna8kjLSJxA7EDwiypTlITwJ8VHIcaQ
X-ME-Proxy: <xmx:h-JLaijShHNcrfEvAH7KoPERDQsrBlXpY3SNYwIAweEHYrF-BGMXsQ>
    <xmx:h-JLajvZ7H_MGojzars9-37FJEnsB-HNj4scXkyv_j62HC1e-FyI7Q>
    <xmx:h-JLaoRUHPd-qCbxbxk0MXEvHjWQ9vUJ6Zg0Kn4I51ju-vUPqESWLw>
    <xmx:h-JLav3z-15Pthj9-OKsRs-hOBMAa9ihpIEFNalBWkRSxQmwLrkXhA>
    <xmx:h-JLaluMkpX1ziKTWPlddOFvnNAVlIBw5QuE19EVcN6vojNGK1l_65Qn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3DCBA780AB5; Mon,  6 Jul 2026 13:14:47 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AM-t4W2tTbs-
Date: Mon, 06 Jul 2026 13:14:26 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, "Wolfgang Walter" <linux@stwm.de>
Message-Id: <32ecb693-3d45-4550-b74e-487bd515c111@app.fastmail.com>
In-Reply-To: <e23f733abb0274d8ecb0404478e5fec8ebe849a2.camel@kernel.org>
References: <20260705-cel-v2-0-d88c3b68e8bc@kernel.org>
 <e23f733abb0274d8ecb0404478e5fec8ebe849a2.camel@kernel.org>
Subject: Re: [PATCH v2 0/6] NFSD: Fix UAFs in client teardown and state revocation
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Jul 6, 2026, at 12:42 PM, Jeff Layton wrote:
> On Sun, 2026-07-05 at 21:25 -0400, Chuck Lever wrote:
>> A NULL-pointer dereference reported during NFSv4 client teardown
>> (patch 1) proved to be one instance of a broader lifetime bug in
>> NFSD's state-revocation machinery. This series fixes the reported
>> crash and the sibling races found by auditing the same pattern, then
>> consolidates the fixes.
>> 
>> A stateid, and a bare lock owner reachable through the client's owner
>> hash, hold only a raw pointer to the owning nfs4_client; a reference
>> on the stateid or owner does not keep the client alive. The client
>> outlives its state solely because __destroy_client() drains that state
>> before free_client() runs. Several paths break that invariant. The
>> laundromat unhashes an expired delegation before revoke_delegation()
>> re-links it, leaving it momentarily on no client-reachable list
>> (patch 2). nfsd4_revoke_states() and its export and NFSv4.0
>> admin-revoke siblings drop nn->client_lock and then dereference the
>> client again (patches 3-5). __destroy_client() walks the owner hash
>> and frees blocked locks with no reference held (patch 1).
>> 
>> ---
>> Changes since v1:
>> - Add matching UAF fixes in several other paths
>> 
>> ---
>> Chuck Lever (6):
>>       NFSD: Prevent lock owner use-after-free during client teardown
>>       NFSD: Prevent client use-after-free during delegation revoke
>>       NFSD: Prevent client use-after-free during admin state revocation
>>       NFSD: Prevent client use-after-free during export state revocation
>>       NFSD: Prevent client use-after-free during NFSv4.0 revoked-state cleanup
>>       NFSD: Consolidate the revocation-path client unpin
>> 
>>  fs/nfsd/netns.h     |   6 ++-
>>  fs/nfsd/nfs4state.c | 108 +++++++++++++++++++++++++++++++++++++++++++---------
>>  2 files changed, 94 insertions(+), 20 deletions(-)
>> ---
>> base-commit: ee6ae4a6bf3565b880dfb420017337475dfbc9ea
>> change-id: 20260705-cel-61c1c70caa03
>> 
>> Best regards,
>> --  
>> Chuck Lever
>
> This all looks pretty good, aside from patch #2 which seems like it
> might cause an ABBA deadlock (according to Sashiko).

Reconfirmed that Sashiko's finding was a false positive.


> You can add this to patches 1 and 3-5 though:
>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>

Thanks!


-- 
Chuck Lever
