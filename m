Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9AFBE46AA9E
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 13:45:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787924754; cv=none; b=NnH7hCyyfydqS8YOmkds2soFacwOi/Cm2vQmLb8bv0UwqrwtfzTI8/nMc4Clgq/HDlfggx8psbyY74nwIVjg1RTsrVFlCSDRUwYBCeZzSxJ/lBU244Twqxx4llUaN5mdk1EqNQypKtNPZ/AjuFg+JJR/gfjxo7yRykNx1+lEnQk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787924754; c=relaxed/simple;
	bh=NtoB/PwGYi1IYe64mBKhj480/PgADJc+9jlallI3SyA=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=NDv4vgyCBCsEjps1a+T9Iut3sqgltqrsAy6eC1jmRXFbOKdeRm3wzVWhudbgFrwxHUg+1I/C0tZFqfwun22NIMV4TXsJ5OmlTgdguxkRRNXOzBppvSgh/txdevHd2GvUGtXsVZNO24vpgxuU0gPvfDYqN2uaUWRqYR/02jO1Hhg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Jd3LNTY7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Jd3LNTY7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D24231F00A3D;
	Fri, 28 Aug 2026 13:45:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787924753;
	bh=UsvEpAxVOXL2c0hrmmniPIkC4Dj3YSJv09HPjKZlAEw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Jd3LNTY7TGms/hgxbxckaqegk4ikmjWerfPrlMa9NL7oroWoLN0n4807k9eB0vrJA
	 que1DWMlP61RuVIcm2R6xNWZdKtYBxp8H495vdgDH3NTyLpco5YDaCy8WYVDtjOXmb
	 Y0zccx8xEsA8nIbnnYCz8uk1W0+kQrmqXmzVbpZw0TTiOlTSqDzKcWH3cFf2QtP8G2
	 IkcJrKH+yYVT6BMh3hrqR0MlTylM/y0vvL1OEUC5houR6wPdLD1cyNrBG3bP/lsUq7
	 xZ6gwQUMXYtB2BpuLQlAWUADI89rirhAPaI9JvNRV/ag8alOkHQT5FIFOwDSoxdmQr
	 8yHLT4BPTt9fg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id F2945F40066;
	Fri, 28 Aug 2026 09:45:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 09:45:51 -0400
X-ME-Sender: <xms:D5GRanm39Wa7GixveWNkcff_QFX0XTOCJ_f8rfECaplHhPqJ9Q4klA>
    <xme:D5GRalqokIaazroDqr7sflT-e2bhmItFZ7Iy6rVr-1YN40WcXh9x-TwbiqvS6Y_NF
    jcoGFSacTt2GfPUjqwGfNInWGeRKap-XOVbrN-ermVgDdstkcOrmrv7>
X-ME-Proxy-Cause: dmFkZTFKxBJg2l7TvJN2an8XJKVS9kOrubOAFSJ7rrbSsvtUMjo7v1UATWVFclqcTvtF3a
    nI88C+c2UEyrYIagavCGKYoYaC6NMP27bU+k2qqYY/EQHY0zh0IJwwpM/sde0KZ3fts17m
    CGyDW3MlFBfH0JVja8WlH7pQ4nAeHM8iyT5L7zMGbREJbMHGlLe4Q3siPCFLKqrBrD7DoU
    Mbfs3jvxB0qIEwmHNpAZM8AKLTVuKImD/0S/L+KRNOldY0hGWa5FoLsArpXlAkHx2YBs6W
    KuFwNlpLrEAHdTp8ITaLQEBnLLpP28qhfimOmTrfW5phbzjWYzbYNoQ+ZJoynFDuHtrin7
    TQ6kLo8p1qBo/UBba5GOdhqjyUrxAQpn4qe/q620OW2el20NE0Cc+aVtJsktPBxL3/wGqs
    G/KPA6+XM4iWJj60tLu9C8GWWJXRs8LwGS1Qghoy5ugz83z76UTKFAq2UlZkSgvOdnuddL
    PaLuldsWeM5jtvaWKt1O1jw18kQPNnp6dLjdazn412lvC5XI0pggfzS32K9o7Z+LQEBwYg
    ZkSvHxmCoxhJMryVsWkeQWKQ8rFB90fvExDtXXuezLdlXUhaWUqLMZwEM6e3z5HR/7aFSC
    BJ8M/m/lYVUfhhDfb6g0hzESDkcr9HnLPTgb5l35k92xMhgX9nyJkwYCVorA
X-ME-Proxy: <xmx:D5GRasce66aPY7l8GIS9mj-9ZIUWVayYeMKvM63Z67-Z_gC5L5iDuQ>
    <xmx:D5GRaly0yJdEP32hAdv56XMSmc33j2geh-0znI4-6fDPa_HG9YXgcA>
    <xmx:D5GRatJ9-hmTOc0LL7bdXY7IYld1t486-bK10w6jGo7atPcURORmNA>
    <xmx:D5GRauud_ekpLN-Iq9kq81l4ZkeWfs56ZW4p1aHslDm3WBszNY6_FA>
    <xmx:D5GRavTm0u_dChvKp6X19lE_EfPiTsbgu1XCL4arWmpN1x5wlDzQ4DOf>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C671A7811F3; Fri, 28 Aug 2026 09:45:51 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A2Uxtb9eUQMg
Date: Fri, 28 Aug 2026 09:45:33 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
 "Cen Zhang (Microsoft Security FORGE Labs)" <blbllhy@gmail.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, AutonomousCodeSecurity@microsoft.com, xmei5@asu.edu,
 tgopinath@linux.microsoft.com, kys@microsoft.com
Message-Id: <978293e7-430d-4b11-9a29-1fb479cb0082@app.fastmail.com>
In-Reply-To: <2026082828-palpable-dingo-241b@gregkh>
References: <20260828041925.36758-1-blbllhy@gmail.com>
 <2026082828-palpable-dingo-241b@gregkh>
Subject: Re: [PATCH] nfsd: hold cl_lock in client_has_state()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 28, 2026, at 1:29 AM, Greg KH wrote:
> On Fri, Aug 28, 2026 at 12:19:25AM -0400, Cen Zhang (Microsoft Security 
> FORGE Labs) wrote:
>> client_has_openowners() walks clp->cl_openowners and reads so_stateids
>> without clp->cl_lock. nfs4_put_stateowner() unhashes that openowner under
>> cl_lock and then frees it, so a concurrent EXCHANGE_ID with mismatched
>> creds can use-after-free the nfs4_openowner.
>> 
>> BUG: KASAN: slab-use-after-free in client_has_state+0x10a/0x140
>>   fs/nfsd/nfs4state.c:3718 client_has_openowners()
>>   nfsd4_exchange_id
>>   nfsd4_proc_compound
>>   nfsd_dispatch
>>   svc_process
>> 
>> Take clp->cl_lock while client_has_state() walks the openowner list.
>> 
>> Fixes: 4eaea1342507 ("nfsd: improve client_has_state to check for unused openowners")
>> Reported-by: Xiang Mei (Microsoft) <xmei5@asu.edu>
>> Cc: AutonomousCodeSecurity@microsoft.com
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Cen Zhang (Microsoft Security FORGE Labs) <blbllhy@gmail.com>
>
> Please use your microsoft.com email address, and not a random gmail.com
> address.  It's kind of odd that Microsoft would have to rely on Google
> to send kernel patches :)

Greg, would you prefer that I hold off on applying this to nfsd-testing
until Cen can post this one again?


-- 
Chuck Lever
