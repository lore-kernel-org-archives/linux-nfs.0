Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FB1148C40F
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 15:16:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784042207; cv=none; b=m/st09KnZHtBTE1FA/KF+mzEyOt/hTmuL4iTrek5ASSIMgRiop3BwtbybN2srO8tAFOGQohTQM9+zPBof6HojQf5kqe7Vw1P3uTn/pjl2Nh0mpgOU/aPs5uETr/WDpsUDOQd5KzBOXjMiftoBTnTVeFiYM+8OOl02dZ8uXWKDPI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784042207; c=relaxed/simple;
	bh=XWuH/bkFbRh2NtqZ1UTv/UzmhCRUo5Ubxoqv1ODWHAc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=YxSr58CSKubwaDwmlUlnuIORSIL3qrOWfYKVWle0Rp6YZ+H9k3EtZJ3ErzRbTaNbQIUY+fnGFPyWr3XlfS7IugDOS+iTOk37Xvz8r333iDAOF4Xi6fo4RRE8U3LxjUZ89g+LKZtSSns2LmR7wtft4Ofl608IwIEAZLVTfh4KXWI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Vz7Icj9E; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Vz7Icj9E"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B10911F00A3A
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 15:16:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784042205;
	bh=2SVBonFlIunKYkpmJ+iRuwiOlU5TLF7PSRzcSCCMyEk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Vz7Icj9EsDFSDS/C5Lf76wgcp9wob2V8N3oAayBP4oxV3Q/8giY13J9SsmpP5rG75
	 qSlzLBWh0dVNn1+syVDEIhi9dPCIHYl+KlyEEq2cHWZWuV3y7KPe4e47LJeGgSBNw6
	 4nroIShNM5W7uTHZSX5O7OBOkJvgDp3RK6+ijuiECbJ+JDdO6Ls9fg0ns0zSrkCDox
	 SjI+Ib7wdRH4yyQJ8CnUS3RH+Nn1m9R51Y53IioGidojqeZ5D8yMUUc5c1euD7IOSB
	 8SUeb1piV1X6ayAoR8O326Ef47v0fPOigZczNO549Y4Cq62DrbKm3athz853P0ehLN
	 VcX/jDmdzbhow==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id B1117F40066;
	Tue, 14 Jul 2026 11:16:44 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 14 Jul 2026 11:16:44 -0400
X-ME-Sender: <xms:3FJWaoOondBTVzaU90JzN4qvFJDGro3j1fL4ph2VqgJ9-AOW9KQOVw>
    <xme:3FJWapxF2UYfByR4izjMk5LIHdQbIovzQ4AdHZWzhoyKqfXFLCnS0IgHwZSLRno3O
    atKjmv6qSjcXFDuYB-8Cnldj-q5ku8xkWyB-5Yxc3qYZggO_EBaS65o>
X-ME-Proxy-Cause: dmFkZTEDNHpeYniHqLf/4+To/x8XgZOiIz9BNQlYiYRE285vZRmRmOkkyxJQmU9yKpvzyz
    MpaTlKBuZqGD7NT4SFoI50MOOkuWBBNF2rvTWeRGBnFbDdyx2Nybmsx/pTM2189oWLKQXG
    9ZRNj5CyGH7HmqUJHimhn8T1PjCvLJRNgnLXCYQrdaezmZ9oYOa0WSS8dot90iSt+eOAOw
    rHTL+oDzeEPSnoAi17oI75T9Jf92vHpo/TByemczkefJj0g0gDuYFYiRFv7qG7mtqv57nz
    dEZesM9pOktzvroqsfqYSnrkiuZ9dPjDA+nqymk5gy4cc+Ej6EDFV6TeV6EESvv1p6XXs2
    GJOVvCnojFq+6aPw4rJED1lxk26uSDk8sac+pewQANBjr4FfJF1rJfQkMD2fRbSUhhhAQ7
    6H45MI2hhm8RAQlIGvqauqq0SPrB9RXved/jobKA8ZPj8hE1MuoqOfQJaGoSFLBgNhpgGZ
    jcAVQD9PptzM6JhLfJ9dKLaCIuqncmzdL462xggEbIR0VRO5V0QONEK++w/USK+faFSCAG
    C2EjPO0Lug6PETLh98DjeZdLOPYXc+0eOc1YFSg3mx7swCIHEWnEQc3oJn1HKvLpbJF3h9
    il/mB7pNep2dj99Mx0KHfv4spdJ64dw+vZvC5uw0NLZIfQkrrlV0/UhvvTMA
X-ME-Proxy: <xmx:3FJWan3xrUwUEDo2pGbO0EYPTBYRZYX8vTgIWMRveoFky3I-kcIv0w>
    <xmx:3FJWaj4uYsvmg4vcamMbJhkxqNqEbJmcfmvtUHNOIC199HYn6v5V1A>
    <xmx:3FJWaiWawuAwOSGlv2DW9BFpn-SqM7P06dd-mX1SqIuGV6BOJ1gOfw>
    <xmx:3FJWaqAtCwjaVMA1h27Vf_mkka942BYLhRKbYzoA9USgQDh-CtYJCA>
    <xmx:3FJWap5AK89cWBpaJR9RZEFJ5636lgMevsb9y5bI9-My8JPHzwjsgKh->
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8D8217811B3; Tue, 14 Jul 2026 11:16:44 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AiMPoQqzriiR
Date: Tue, 14 Jul 2026 11:16:24 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "zhangjian (CG)" <zhangjian496@huawei.com>,
 "Steve Dickson" <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <dfd0efac-0d06-47f5-a9bd-04b26f4061af@app.fastmail.com>
In-Reply-To: <356736aa-25d8-4b79-a50f-33b4e7035856@huawei.com>
References: <356736aa-25d8-4b79-a50f-33b4e7035856@huawei.com>
Subject: Re: nfsd: fix memory overflow for haddr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi -


On Tue, Jul 14, 2026, at 4:43 AM, zhangjian (CG) wrote:
> when hcounter is not 0, haddr memory is not enough.
> asan report heap-buffer-overflow error in following scene:
> CFLAGS=3D"-fsanitize=3Daddress -g" ./configure && make
> ./utils/nfsd/nfsd -H 192.168.1.1 -H 192.168.1.2
>
> Signed-off-by: zhangjian <zhangjian496@huawei.com>
> ---
>  utils/nfsd/nfsd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index c95d32f4..e3fcdde4 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -185,7 +185,7 @@ main(int argc, char **argv)
>  				hcounter =3D 0;
>  			}
>  			if (hcounter) {
> -				haddr =3D realloc(haddr, sizeof(char*) * hcounter+1);
> +				haddr =3D realloc(haddr, sizeof(char*) * (hcounter+1));
>  				if(!haddr) {
>  					fprintf(stderr, "%s: unable to allocate "
>  							"memory.\n", progname);
> --=20
> 2.33.0

A couple of notes regarding patch submission process:

You sent this To: chuck.lever and prefixed the Subject with
"nfsd:" so I assumed it was for the Linux in-kernel NFS
server. In fact, it's for nfs-utils. Steve might not
recognize that he is responsible for this patch. I suggest
using "nfs-utils:" instead for such patches (including the
preceding patch labeled "gssd:").

Second, your email transfer agent's DKIM is misconfigured.
This security feature is tested by our patch intake tooling
as a way to spot bogus submitters. b4 reported this when I
imported your patch:

  =E2=9C=97 [PATCH] nfsd: fix memory overflow for haddr
    + Link: https://patch.msgid.link/356736aa-25d8-4b79-a50f-33b4e703585=
6@huawei.com
  ---
  =E2=9C=97 BADSIG: DKIM/h-partners.com

This might become a blocking gate for future submissions, so
you should speak with your email administrator to get this
corrected.


--=20
Chuck Lever
