Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E25D631716D
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 15:56:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790956566; cv=none; b=tOJmzQ5vpBzgeiTa1mI+XlMP44SrJ4gsu1eszUkDrPAgrAWFfZlMBZJDevs6J3ZYvoYyaGXDoH2Jb9IRp0Lits4NJnQ6b55ZiJD193S6Wj1rnmeJMCVA51C0ZswYYfS2uvtX55HQcOZ5mg6H+H1lFn/X+zA5h59bX3pqouZEcDo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790956566; c=relaxed/simple;
	bh=97HFcVeFj1IjNfXvDCv4s0Gu5IwIR8HOKIStZj1DSp8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=tilP31udiWcQ2DCDnfSgPxtwH8kLFXKBY2jyAV0hIYA1xNTF8U39b6Z2g+qCOUkt8SJ7+2aplJIXtzRUuvQ/YNjDQEMKLHGa04ZtxsOGQTFHfFurRjYEa5BymWJxOlHpx8u0Lo3qOGtXfOwboCleisaFzyijHp24nhOJI9y6pqs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dqpbR3Dv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dqpbR3Dv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C75FF1F00893;
	Fri,  2 Oct 2026 15:56:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790956564;
	bh=LGIIvytCABmVBj1yPc+oYk9mQMgPAs5ga7T7KWgrJqI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=dqpbR3DvPi+AWisCJb0mebbvQBamcuIhb+Bd5Fu1SRaZcq2r7utMZ4iKfbdKHIPhE
	 LOi3jAt2A3BNIVHiGHLq8CiPuSnXpiaEG7+meEE78Q6CmbUcfoQf94naphH09ZtI7A
	 3TLrZy9BGUQ6btFfk8V867V9bnVD3sAwnOun4AtD20fH3EKaRc2xZdvreDQ+HIFvJS
	 LSV/C75JtdWO7z6gKWDUhv68X0lf/nhQQi9VZO1lsjZ4bJVAl5pADgeDGUoBD1udT1
	 phd1SokbX3U4IuHWD+BunBqEWptX6CqUIILsdQ1D8Eq3ecQWPx+5ASQ3CxG738D5qZ
	 KHJ173VPYUM5Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id EF381F40069;
	Fri,  2 Oct 2026 11:56:02 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 02 Oct 2026 11:56:02 -0400
X-ME-Sender: <xms:EtS_aiXipf8G-yIZs0-9JEnQnAd5lW29iVa9UAshUhbUvzvSClf0HA>
    <xme:EtS_apZbeU7VnLpDWkNY_uy_MTTlRmmFtyjytpL541K1Gq2AiLMUk4E1-jov3Cblz
    nEDLGU_vXqkB9FAcmevv-dAFzO28_V3ZHJ0g3LyTpbtsgDp8RNaw5yj>
X-ME-Proxy-Cause: dmFkZTG3tfGePU6uYuHTQVga4X+WattHsHDdHFAL4K06YJFwSFypyczymfjijpL6rYWtRw
    azfXjJT/148pveB9CwXcCXnnBQrz8u2CQypWN1Oi96VX8D3vRFW88xPNC5+ec0ALqLcKgg
    fPcO7RcZRr6hI4lgOfMevdu6ZVT7bHNQd8oayD4LTBQwPLZhxK1aZM6TeGXxZ32aQA97ZE
    JMAGI2M3xXNMmIFxpVzSk/G1a4qnCjj36M3ywxGgGz3pDoKvLKEMOYmIktK08eq6QxfulO
    +mGqPb3NH4giGFVQWsQVBv7hWJU7ik1cHR7lkCxF7bBkUAe3wAOvYpT78MuZrogwtmRXqn
    gpWKbSNH950R6LiEPHM0u/s3BGucVwJndc41Xtjd2gD8QtrNsQ2d3qhSzaq/YA/QCXBxAG
    ozLvXOMxGQzBOmIgZzb+D3aLgDt7UQAxkCgyu3Z45D8JzFdMUmE36be/suskB7O8W3ijUd
    KiK6vTGAvdMPQ+Il93bCUifY/lx6+Ppk9UWXUSo8UIOaoJnodhMiZEiBtT3xHvUCWWMGXF
    TVj8YJMvQeSrfdg02jgJDwKEWajb94KcxbcWisEnGFNiEUUbHlg+2rgnP97M6FeYJy8eYo
    QxYuwio6DhqFSaIMAdPUFSyz7/3YzIOVY8atCDiVyRM0GyryNVIYrSmibSfg
X-ME-Proxy: <xmx:EtS_alr3HOpoj0Q3qdq4zGaJam5tk77CrBmPPGIzDdPvSaGX5_NpHw>
    <xmx:EtS_ahpLcTwNfhDxixRsFZyouoU_OGcDlZnd7Iy_oFZcnnPN4rgOmQ>
    <xmx:EtS_ao3k7HU0KTNyVjBYobyXEe-LorpXJGCO4mkRReR2Y43lH7oYXw>
    <xmx:EtS_avH75-NlylwD3y1ayfcfbdOzcSi833T0PWKTlrBLFgceiJyE8g>
    <xmx:EtS_ajEcEDk9yV24Lg_1k_-lS96Bn6phTCCppk8zppgnEIRR3FH6HM-N>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C9C4F780070; Fri,  2 Oct 2026 11:56:02 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Awdsw88ccU0F
Date: Fri, 02 Oct 2026 08:55:41 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, "Hyunsol Mun" <muumthf@gmail.com>,
 linux-nfs@vger.kernel.org
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 BoB_Tobabz <bobtobabz@gmail.com>
Message-Id: <5395aa50-bf30-492b-809d-fc882ea5ac57@app.fastmail.com>
In-Reply-To: <6ad7a2fd190a94aa3b2592314b79109d21f38436.camel@kernel.org>
References: <20260930053915.299362-1-muumthf@gmail.com>
 <6ad7a2fd190a94aa3b2592314b79109d21f38436.camel@kernel.org>
Subject: Re: [PATCH v2] nfsd: pin source client while using COPY_NOTIFY stateid
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Oct 2, 2026, at 12:20 AM, Jeff Layton wrote:
> On Wed, 2026-09-30 at 14:39 +0900, Hyunsol Mun wrote:
>> A COPY_NOTIFY token can resolve to a stateid owned by the source client.
>> find_cpntf_state() drops its source-client reference before returning
>> that stateid, so concurrent source-client expiry can free sc_client
>> while stateid validation or the caller still uses the stateid.

>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index bbc16dd22..43906f87e 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -2805,6 +2805,15 @@ static void __free_client(struct kref *k)
>>  	kmem_cache_free(client_slab, clp);
>>  }
>>  
>> +/**
>> + * nfsd4_get_client - acquire a reference on an nfs4_client
>> + * @clp: the client to be acquired
>> + */
>> +static void nfsd4_get_client(struct nfs4_client *clp)
>> +{
>> +	kref_get(&clp->cl_nfsdfs.cl_ref);
>> +}
>> +
>
> If you're going to add this helper, then you should convert all of the
> other places that call kref_get() on this object to use it, ideally in
> a separate patch.

I applied this one to my private tree, but it conflicted with an earlier
fix, so it is modified in my tree. Perhaps I should drop it instead, and
muumthf can rebase this fix and repost, once I have refreshed the public
version of nfsd-testing in a couple of days.

Jeff, note that one of the other one-off fixes posted this week also adds
the same helper...


>> @@ -8551,6 +8564,7 @@ void nfs4_put_cpntf_state(struct nfsd_net *nn, struct nfs4_cpntf_state *cps)
>>   * @flags: flags describing type of operation to be done
>>   * @nfp: optional nfsd_file return pointer (may be NULL)
>>   * @cstid: optional returned nfs4_stid pointer (may be NULL)
>> + * @cstid_clp: client reference paired with @cstid (required with @cstid)
>>   *
>>   * Given info from the client, look up a nfs4_stid for the operation. On
>>   * success, it returns a reference to the nfs4_stid and/or the nfsd_file
>> @@ -8560,10 +8574,11 @@ __be32
>>  nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>>  		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
>>  		stateid_t *stateid, int flags, struct nfsd_file **nfp,
>> -		struct nfs4_stid **cstid)
>> +		struct nfs4_stid **cstid, struct nfs4_client **cstid_clp)
>
> The bug seems possible (esp given the fault-injected reproducer), but
> this function is really devolving into a big mess. It would be very
> nice to move the COPY-specific code into a dedicated helper that is
> only called from the COPY-related codepaths. Consider reorganizing this
> code along those lines.

That's another reason I should drop this version of the fix and let
muumthf rework it.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
