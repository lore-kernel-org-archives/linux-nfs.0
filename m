Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7012379CD
	for <linux-nfs@vger.kernel.org>; Fri,  5 Jun 2026 02:08:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780625332; cv=none; b=Fp8ei7PFO9crtWl75fM5RNcxLG14CLVTOSx0ricCt0nl/fSkPr4iapc8waAwBc76TPnX5o9cZMBCvSzFRb3B83akZ1SWyi5pktCh0rziyUR1oGYn60GIlwcN2zHZMfoObV95kbqsox/qrRXPAI8L6vb0pX9O53dnAj9fwSzbHoM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780625332; c=relaxed/simple;
	bh=al0QnAhLSAgEXum1lOnI28v6ykn+5+V5QpCvUyfrWZE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=SlpxSCfa823Wh/KDYBjTIK/ucyFpR3DpBb4GnIOxEyRvrwL9652ZliDT0BH3qJGmn+sBe8CKtPQl9rb0cNYDafYcbJgiYp2L4i6iXahoGwmX8L42fTrNh4HIdkd38Yfoh2oU2MpRveFF6ejaFAY4xiZaOfOiveWbilnQM4fhRp0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nhshbzyY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nhshbzyY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9CD8E1F00899;
	Fri,  5 Jun 2026 02:08:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780625321;
	bh=Yra6/5otM6D44WU+GtNZh8VvZVNp7h+T74mAXKaSs/A=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nhshbzyYxyBJfg2I5HinhnmIkQTBgmgOTeO3EuODX/YTdLb68oY5DahcJXLuOOY0T
	 wRq1t/5KYidOnPoKwCnpfD2jIIbVKu+zSM4sDiFqGC2E4ej8fkRzmyBmVwgHem8bBs
	 EXCTNel1E9RhiKRoQEhZZAhZ6OuFIeUSRaoWzeyOnngWphphlYiJjok4vI4CL/dyma
	 BSj2Hh/87hVZTYnRRDDeLXYzwANL2wP/OHuXrNzDVh3dpT1deuGxuX5m25DTOmS6lM
	 Cvqb9RzvMVAhDBh+CU6iMFz1Cvx1QYFJfNinOjrgM/RzmTz9RO88ByIJE5IFTmcFSI
	 Rm/BOzwg7p3lw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id BE1B7F4008A;
	Thu,  4 Jun 2026 22:08:40 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 04 Jun 2026 22:08:40 -0400
X-ME-Sender: <xms:qC8iahUXtJs0qudBRuRHm_Uvxf6qnQkFfLmVRxZWkGMizh6qFJtTpQ>
    <xme:qC8iasaFVXF5brMIKMT3KULg2rdQYy63K643B0SO4wUTE4WAl82wePZZ9wRvY8zpW
    l9DAZ832wx1MyWis7apH4b172MBzxEmLjJIoQgwMpGUlvZSLVvGOYA>
X-ME-Proxy-Cause: dmFkZTEplS3Oiti3q0tqtt9ZH4IVY7q5y4vaFUhG0Wp82vLw27VryXUak2NcJxnuonFsoZ
    AqoQD+1tsLql8AGKG6W3ExH4Q26uGHIp8wOSjPcB+6FrFOJINvroqo9NDXTXH+QWu9IdJB
    48JVzQF6dbFcaCTPWZGWRXE82yXPJsJOmnLl/qoPH5Yt7DEBnYJcVt8tCxaBBGaJnALYRc
    0Mn40SKwU4TXF++Z/Hs4bfovXK0Q6ccVHE1picIsLls3iOUWxAV1h69wGBFiKfvUFgquD4
    dmK6ugIYcdDquRK4d7tek9z0y2FbZF3gKvKv/pg81h4TfUHDjUrhx/gMVeE+OrjJ9rXDlc
    6xxzG6NeEvI7I41X5q9jNc+d1HdICVSjWcttKweXWZm+zm1bEulydbOcCbs3uMlYcVf1rt
    6O+gHizIGjnf9Zg+wQdi4lVrBcNAHB4LXpsal70KHnVZHCb/R0orep67rixLRSD/80+ye7
    N4Q+NgN3p2t3FwviYcUElMcwHNqLPw8RtpDlQHkL6cl6Mz7TUNrnrdtZsPmLJwOsmy8YMx
    hk5hRGzD1kMs55ISjOhfyJ4TSMgsvnkqV6keIUd0pwHBUbC0A9FcEtaxcVq3Hbq1nQekgE
    vwv3LJ1DEwmSmduGOhy385OT56eikrmO27Hx9ZzewoQ26qYAksymytDmEk+A
X-ME-Proxy: <xmx:qC8iasBpfQYqj7AYrnrwUfCUQoLvAd_Fi7TO1RG7D4rVR4OFgk1TeQ>
    <xmx:qC8iaswM4c8gQ0djTAjK36plJc8OTUJuo2FlxAwf9j-K6F_NmPdZwg>
    <xmx:qC8iao7-r1-Amxzy4S_paUmgZTpMWotoegO7J-i8AmAm64m4_yBl5g>
    <xmx:qC8ialzJb6KiekpEGdO8RaoLWE6fsgvYKqCA6gdBP69bOEn_rWw3mQ>
    <xmx:qC8iakd_HNEDjDwIAa61Xp6Uygbvs8ntxpkcmmQhQm_ngXM2iBjaYW7q>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 9D292780070; Thu,  4 Jun 2026 22:08:40 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AOaU__H_yjO-
Date: Thu, 04 Jun 2026 19:08:20 -0700
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Christian Brauner" <brauner@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: "Jan Kara" <jack@suse.cz>, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org, "Jori Koolstra" <jkoolstra@xs4all.nl>,
 "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Mateusz Guzik" <mjguzik@gmail.com>
Message-Id: <b86f4070-c2b8-4989-b956-ad0f40f88acb@app.fastmail.com>
In-Reply-To: <20260601070042.249432-17-neilb@ownmail.net>
References: <20260601070042.249432-1-neilb@ownmail.net>
 <20260601070042.249432-17-neilb@ownmail.net>
Subject: Re: [PATCH 16/18] nfsd: switch nfsd4_create_file() to use vfs_lookup_open()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, May 31, 2026, at 11:38 PM, NeilBrown wrote:
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 5bd19e5d9e34..61ecd4123817 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c

> @@ -302,33 +302,18 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct 
> svc_fh *fhp,
>  		oflags |= O_RDONLY;
>  	}
> 
> -	host_err = fh_want_write(fhp);

This fh_want_write() is removed, but ...


> -	if (host_err)
> -		return nfserrno(host_err);
> -
> -	child = start_creating(&nop_mnt_idmap, parent,
> -			       &QSTR_LEN(open->op_fname, open->op_fnamelen));
> -	if (IS_ERR(child)) {
> -		status = nfserrno(PTR_ERR(child));
> -		goto out_write;
> -	}
> -	path.dentry = child;
> -
> -	if (d_really_is_negative(child)) {
> -		open->op_filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
> -					      current_cred());
> -		child = path.dentry;
> -
> -		if (IS_ERR(open->op_filp)) {
> -			end_creating(child);
> -			status = nfserrno(PTR_ERR(open->op_filp));
> -			open->op_filp = NULL;
> -			goto out_write;
> -		}
> -
> -		open->op_created = open->op_filp->f_mode & FMODE_CREATED;
> +	open->op_filp = vfs_lookup_open(&parent,
> +					&QSTR_LEN(open->op_fname,
> +						  open->op_fnamelen),
> +					oflags,
> +					open->op_iattr.ia_mode);
> +	if (IS_ERR(open->op_filp)) {
> +		status = nfserrno(PTR_ERR(open->op_filp));
> +		open->op_filp = NULL;
> +		goto out;
>  	}
> -	end_creating(child);
> +	child = open->op_filp->f_path.dentry;
> +	open->op_created = open->op_filp->f_mode & FMODE_CREATED;
>  	fh_drop_write(fhp);

 ... the "matching" fh_drop_write remains. Harmless since nothing
has set fhp->fh_want_write, but should be cleaned up.


> 
>  	status = fh_compose(resfhp, fhp->fh_export, child, fhp);


-- 
Chuck Lever
