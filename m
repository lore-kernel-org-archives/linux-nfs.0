Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4C4336E48C
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 22:04:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787954699; cv=none; b=VF91kA993GOri2a1siRb2qDkol8F1Owt2y++NQkc3iLdf82qckOKsf2wxxSX9TrhItdVJXZfJ+tQvE61+u4oHSjjIc6WEg7be2P+8dDTYpqVoqMcpfpb8TKWUutqiVsyLwcJ3R86m5PmZz3RZZaeYztWeQW2IzwUMyOdM1CdTYM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787954699; c=relaxed/simple;
	bh=USFVvhs+4+LOIzDtn/8SxDvspggQYoN8U00U17gWS9A=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=PLD019joftFdKRAvg03YCfoSiApy/O5FU24Q2s23B7Ne37jgK3SMGNYqgBDisjpfBdFLTS9O5jICeIBYm8vlJdI5BnN4ax8rMPqnnvD1g+tS3avZ2TRhiFRJeznAvl9w+Vq6N6Ngc1494Hfx8pH0YFpPgFjds04dGx7JPCBK+Rw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BFWOAyPv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BFWOAyPv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 169281F00A3D;
	Fri, 28 Aug 2026 22:04:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787954698;
	bh=7CftNfgl4Zvlns4e6S6ql/EYJowzj+xga6e3AM/yM8M=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=BFWOAyPvBKyMK7N5axiDcjYmOOIM96tB4Ijs7Hz35o9XjKS3Fl4tlqnb3CASgl3wn
	 Is+pAlmW4qJSeEXEHnA9X+7fmeF/Gkyaew+4wmYRcam4D1e8jCSUF5xjSwzc5p9O0d
	 QUz8pOMRUX/lk6piBXZKDI39e2YYWxk1zTb0+ni925tUvzHd1BZ95L0njJmNf1qwBd
	 MyY6WzNv+6eeE1+RKY5maLIl+fvAVzOWsl1s64gq3PR+l3aO/QbqnxS1NshNkoxeyT
	 bacd0IhfU3TpEUfC0rmglHJ5Up8YJ/w3zO0IaqeZ38ApQkaVla1EwJpIBIJEb6Zl8V
	 H07G8NKHbTosQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 4E28BF40066;
	Fri, 28 Aug 2026 18:04:57 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 18:04:57 -0400
X-ME-Sender: <xms:CQaSatEgY2A-3P7YUrGVhrzNlOvUgwVYxC4NZucPMG28FaqJvXfGUA>
    <xme:CQaSatKS63N4F3fLA48sxpmubrVYm7ZcN_zRFDQ5m7UMYoc9Tn79DUnmmFi31w-_D
    ltc2Y0htIds5GVYS_R7dFaZASO2i7qQ5PsCyRzfKQ5uMeRWh9dVdHoL>
X-ME-Proxy-Cause: dmFkZTFBdtWwfcHm9HQoYymaKuepRm9DD1EMwulI9Myk9BEFabC3m3lb1G8w0/TVbkk1if
    L5Y0886+Jr2WiefLG/gAgdVvro9kejgKmwtgbyn+eKQhWsa4O/9P8sc40kJU8WFmy2ieTu
    5TOwj44xlMwtb/8T3kgVYXW4yR5TzfnWfGTJKzy7hG8KlMJsussw9v2nfO/bXevnylx0Dd
    I2Z40pRjo5tQb9zZB7C4m8snNHNAMuE+QrA//fdPNj5r5/zoN4fLe9NDiI0UahMV7h2Pb3
    9J2rTJV3xpnAf6blUOMyRatLScou40yKTQIgvBVywnI6wyTGY+A/m0kPdlWcX5tz6WWDpM
    2cbfnIs4eZJ3SqxUAq4EPL0BfnyvP+IpgOkrtOGd9B8z8+hGems//6joR+bEP6Bd82DbvX
    z+2qQYrf6nlOvsSXNKFBJdLNrCnJfrCkLKXqIVTInpOdXZFO2RoeZIoAILkyIV8ClHebsi
    SA7LPbLRBbu2kuLq6qUFDKi+6hv+vNZ9wPjQI1tlb3h9IcB8Rx5+ii00UJXXhl1bMpPbx6
    5JmfHoncQzDkXOABTEKkdD9ldBXzJA+ERuTKKXZXVVx0Kt1u03CxUfKuwKpGakyElnWkHq
    VmPf3xDanSsc9W3vJ28R+5X/laAFfsPIUnzLwaNgeUXbtWJIWWGAQIJBbJTg
X-ME-Proxy: <xmx:CQaSapianNlPnsIVybhgvOGSdeekrgIoEf6RwIcPE5yCIz_zmNiJJQ>
    <xmx:CQaSai8YP7xZxUZn3nrT6UVN0YNRkHI9ertL3IbiTi0c0QdkbnuvDA>
    <xmx:CQaSatW1a2XM6js5jS4A9dMTWBAhZ8GoO_4HYCzWJx45PhjueaX1HA>
    <xmx:CQaSauB_N1wrZAGGXrUUgyvPl8bba5n--xS3-yeexDuxAmbAKrcTsA>
    <xmx:CQaSaqGuCwyT0oy6RP235XzyrF8bMQcy2Qz6h0RAO6QRXxVln_d4-9OJ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 24E497811F4; Fri, 28 Aug 2026 18:04:57 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AcUrMSdZQCF-
Date: Fri, 28 Aug 2026 18:04:39 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tom Rini" <trini@konsulko.com>
Cc: NeilBrown <neil@brown.name>,
 =?UTF-8?Q?J=C3=B6rg_Sommer?= <joerg@jo-so.de>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <a832bec6-fdcf-4405-b8ed-87418bc704cf@app.fastmail.com>
In-Reply-To: <20260828211855.GL3959812@bill-the-cat>
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org> <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
 <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
 <20260828205116.GA266670@bill-the-cat>
 <a9a48faa-2663-40d7-86c8-ec2eaa967cdf@app.fastmail.com>
 <20260828211855.GL3959812@bill-the-cat>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 28, 2026, at 5:18 PM, Tom Rini wrote:
> On Fri, Aug 28, 2026 at 05:06:14PM -0400, Chuck Lever wrote:
>> 
>> 
>> On Fri, Aug 28, 2026, at 4:51 PM, Tom Rini wrote:
>> > On Fri, Aug 28, 2026 at 09:27:41AM -0400, Chuck Lever wrote:
>> >> 
>> >> 
>> >> On Fri, Aug 28, 2026, at 7:33 AM, NeilBrown wrote:

>> >> > U-boot has
>> >> >
>> >> > 		} else if ((rlen == -NFSERR_ISDIR) || (rlen == -NFSERR_INVAL)) {
>> >> > 			/* symbolic link */
>> >> > 			nfs_state = STATE_READLINK_REQ;
>> >> > 			nfs_send();
>> >> >

>> The "deployments can't be updated" also doesn't make sense: if
>> they can't be updated, they won't be able to get the revert
>> either.
>
> By deployments I mean U-Boot deployments. It's notoriously hard to
> update firmwares most of the time. Some testing labs refuse to because
> of the value in testing the firmware most people likely have deployed
> rather than the latest and greatest. So most of the time, it's never
> updated. Can newer systems take advantage of good and specification
> following update mechanisms? Sure. In practice? Only maybe.

I'm talking about changing NFSD to return NFSERR_ISDIR, which would
be picked up by the first "if" check above, which already exists
in U-Boot.

That addresses the regression and can be backported into the LTS
Linux kernels that have commit 0ac903d1bfdc [*]. It does not depend
on making changes to U-Boot.

Since the problem was reported on linux-nfs and refers to a
specific Linux kernel commit hash, I assumed the only thing on
the table is a code change in NFSD.


-- 
Chuck Lever

[*] AFAICT, the only two LTS kernels that are affected are v6.12
    and v6.18. The stable kernels (v7.1 and v7.2) would also be
    impacted.
