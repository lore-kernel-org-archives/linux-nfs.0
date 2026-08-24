Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C48F456DE9
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 15:57:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787587050; cv=none; b=qLi7xqrdT+YS9e3AtqeWGyOZhAnzprhLNY77uH2YYA1b9sV/fgQ/N1HgQb3n7BmaJHV9Z/ynVMCfaEO2QdPrUtVO/ofxBNr59LJKwGKse9rB/3uzCx5hPT+AXkLf0/+9lsCrTrGUR8UCX6WQf1ivnKugqEsUCPED5cnVlk3Ek28=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787587050; c=relaxed/simple;
	bh=mK3cYQeUFwXR5DJyGO6Ph3vFmpkvWsY2voup6EStBNQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=WasGHsy5P1np/sIPpaN7ChCZVOjbzY2tXdg1JrfcInXEe3RQXLfC7VdDoI028OfDiAXRc4PTRuYruhdnNUinPhsa7bZqSGPmCKGuj/BWzbAUpVcECRwYi2G5Gh+jJmQlQbVzSbMe+IJBrIMyHTPeislFnq5kBqh8U5YRt0XIZQA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bfzPCJWJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bfzPCJWJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 994D71F000E9
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 15:57:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787587046;
	bh=mK3cYQeUFwXR5DJyGO6Ph3vFmpkvWsY2voup6EStBNQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=bfzPCJWJiFd0uugh/uYxSYJaSjplBIuS4tLKHDIWc0jcRxItjLIQfL5RrPVDAw//g
	 chCQwRuMENhhuVVD8Abwvmgxe8fLIb64NU8DRUyu5JSpp0EGeiXhS+jXh9n/0TlaqI
	 JKYW9AUOavo+ppV9cnTMEexEF7qeFl2hF8tb8TIvTT4z0rszIVpAQ7mdNk9m/nHQpc
	 /cKt0ndw7dc7BJynTxCfbrN/P2d1qyz6rUccaXs5oyLGiiyPM/SEyNzXbCKFN759Nt
	 cj1JZ5gZMho3JIqA1Q4IpfW6ucZuHtKkExQ17vBjp+k/7SCfNuIIAx4qpiVOCN1rMF
	 zVvmgjI6x1ktQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id CA50BF40066;
	Mon, 24 Aug 2026 11:57:25 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 24 Aug 2026 11:57:25 -0400
X-ME-Sender: <xms:5WmMage4-hm3UdGbMioygoHAQbWxeT93Q6h8HWqD2Tls4zYC6-64kA>
    <xme:5WmMatB4GeWtbLvQezej02llFgzAvCm48Lq4YnWkXSkhGFZYrveW9huPhKWFRtz12
    u-i1LRyxmRXUJBvl1ShdoGnHtAvYaNzjde48GW75W7vvUhjmD6Cb9js>
X-ME-Proxy-Cause: dmFkZTGr5dA6Vf/7e9wcB35+nOnNkGtIeXCIMDD8e9HknXI9KqxT3ONvdIYQKJIWxZVMPG
    GzGRrN8xECw4DAsP++/ZsIorve25/Wx929FR+QjOIzst80IzAASzoD8w56zGI0qjLau4j1
    bq+bXQLfhCrmSs3OI6TfPLfkceD/y3G99Qb+6HJDPxhQYuP8mUlPyvDn9jL6yEwGsbBjdO
    y4KKOT9gbKMuemq0U5g4kMtpMRDpGD6sYH+LHBxOOzJrqoEp44hAr2746B3EmUysRFO/o5
    6d358I2WpwNqy+357Ca1HzkTcAoiZVOmT3+DisZuRtnJkDrCxthi66H02R5cpXZT2nx2bp
    EMtIrvdJEKvNlfYBVoFWLF3niPG3c+elfsfTPbv3eBL43rmbQhnikVNPO4MQtXjibGdSHf
    hValo6xTUPsKVlIZYubkgWF2oUN64EN3pp7rWsXikqCciVqYHVEQEixV+dUcuTZMaPfGBE
    KG376XTSZbXHKG5zZYZVCr8jKeFnASl2StY4vq74Irz46CrSVqMZ9Se7hFv1rXmpz7DRrE
    9G2gkRN2Nd3IsN6y5Ku7KS1tS98kETUjSh4Q/8DM0U8zQ++sdmqu1Xflg5UlkKZtBDE32/
    TK9XK8/VSJJxm2Z8QUQbGiw84GzWS+IfIzEcRpvFWp9JltmJx1qXZzDl1puw
X-ME-Proxy: <xmx:5WmMavIuj4wI6tWJWQsOpFw-J8BrnHrS_e_LjV8G0TEIE4e9kzbYiQ>
    <xmx:5WmMahGyFsivGKoop0ISFj5g5xwjGq0BpNK1B8IqpASHl3LuWz874g>
    <xmx:5WmMavSUF2WO90PdMtvuEjQvV3Icjotoq0RcLvaLEB78MJnbl_kgOw>
    <xmx:5WmMalGPZcFpThfJjNapa5OE1PVRcCUtLRWmlwSaKVhKuAmhh-AUMQ>
    <xmx:5WmMaj9-Qc-XA8RREg8Md_ee3sTqqtB42NyNHdU6a3RfhlzwQb2mlgOP>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id AD2617811F0; Mon, 24 Aug 2026 11:57:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0sSqJrMC6DV
Date: Mon, 24 Aug 2026 11:57:07 -0400
From: "Chuck Lever" <cel@kernel.org>
To: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Cc: linux-nfs@vger.kernel.org
Message-Id: <00efd625-90e0-4ddb-b996-69a952d4d420@app.fastmail.com>
In-Reply-To: 
 <CA+1jF5qAbz2pMSAnSdJVo0P1d=jM5ysDsUi6BpW_+v9LgaLsPQ@mail.gmail.com>
References: <1759357733-64526-1-git-send-email-dai.ngo@oracle.com>
 <CA+1jF5rAMkb44Pu8XGDnu9WUE54sHVf5TurMsQXfrUrmu0Ojjw@mail.gmail.com>
 <CA+1jF5qAbz2pMSAnSdJVo0P1d=jM5ysDsUi6BpW_+v9LgaLsPQ@mail.gmail.com>
Subject: Re: READ_PLUS broken in Linux 6.12, worked in Linux 5.10! Re: [PATCH 1/1] DIO:
 add NFSv4.2 READ_PLUS support for nfstest_dio
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Mon, Aug 24, 2026, at 11:40 AM, Aur=C3=A9lien Couderc wrote:
> Reminder: This is still broken in Linux 7.2.
>
> Aur=C3=A9lien
>
> On Thu, Oct 2, 2025 at 10:22=E2=80=AFAM Aur=C3=A9lien Couderc
> <aurelien.couderc2002@gmail.com> wrote:
>>
>> On Thu, Oct 2, 2025 at 12:29=E2=80=AFAM Dai Ngo <dai.ngo@oracle.com> =
wrote:
>> >
>> > From: Oracle Public Cloud User <opc@dngo-nfstest-client.allregional=
iads.osdevelopmeniad.oraclevcn.com>
>> >
>> > Check for nfs_version >=3D 4.2 and use READ_PLUS instead of READ.
>>
>> FYI READ_PLUS is **BROKEN** for sparse files. It was working in Linux
>> 5.10, but as soon as we switched to Linux 6.12 it reported only data
>> and no holes in sparse files. We're back to Linux 5.10 and cannot
>> upgrade because of this.

Aur=C3=A9lien, "broken" is not an actionable bug report. It's a
complaint.

Do you mean that NFSD returns READ_PLUS responses that contain only
data segments, never holes? That is perhaps not optimal, but it is
100% spec-compliant, as far as I am aware.

NFSD was changed to do this because there is no common race-free
way to detect holes in files on Linux filesystems. If kernel VFS
developers know of a way to do this, please reach out to me.


--=20
Chuck Lever
