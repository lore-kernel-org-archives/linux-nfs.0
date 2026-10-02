Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E1B846A5EE
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:07:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=170.10.129.124
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790950040; cv=pass; b=tdjQDglA9s5VysWjd+7HCo5wQcU4oD3oDH/+O3/ZXSdGYBlGePlr8W2UplOKgxMquHh+/Uu89+azQOn8yg0pPmwDNeP7n9NnUEjyD7wLeDuyjXMDWx49fZISToQzdqamrJcU0ktRL8V3/ksEUy+mjtz29QCAgBLI3MdvOj5t/Mk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790950040; c=relaxed/simple;
	bh=yfDvPO4H/mIRlRzgF1ehHxShRFO4ABWe5fq0yL3+cMs=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=EXqzJIGlQa6Eds5opdf358NFrAxCZEvpHb+JEnLjAuD44t1u3O+WYkmypZamAXYNxO/BzkNAIC6qScHOawqMUlqvjo1y7ojL+1LgpQOCww5Z96QRabfdOkcps2e6hNyRVxU9TF3PSEWAvTkTuxr0DGPHwOw6RFznGyIFcruQcHM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=eftsUuVY; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=KGWOl5js; arc=pass smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="eftsUuVY";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="KGWOl5js"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790950038;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=XDp0RcD7HYWUzlsOLtsxZUXX4GvVdXcns7B6N4dcr9I=;
	b=eftsUuVYCPvq8xq1ZIWulJtLktke+IJKxMUPlpxs+dnvurIJRsHIzkktOuF9D5Ahq0jI/x
	l+tXmaJahlnXTKfbpRs1xjld/rqqEaw3XrrYZwCCpXntHkHMKvnR/PPdRhYtfMasumhS9f
	HYVRKPdDZlElN7gLpbj2KoeFU7N/9kQ=
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com
 [209.85.208.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-43-nKMrwYb7PhKa8WnxDgxaCw-1; Fri, 02 Oct 2026 10:07:15 -0400
X-MC-Unique: nKMrwYb7PhKa8WnxDgxaCw-1
X-Mimecast-MFC-AGG-ID: nKMrwYb7PhKa8WnxDgxaCw_1790950034
Received: by mail-lj1-f197.google.com with SMTP id 38308e7fff4ca-3a782ba9e23so325181fa.3
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 07:07:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790950034; cv=none;
        d=google.com; s=arc-20260327;
        b=D13GF+4nuW564pKYZrCXQBGYkjtXcgT+Ixjgy3rYl9sT4A50CH4Qg/FjAV2ddA37OZ
         NbiCQfylqEQhOZfvStScKmagnCg7FWks0yk0ZpEE6lrRQZna/SM0yEyyURLc+FHsAfzB
         p4NstOBd1iPA8/WUgQF/G4vFOIwFIVnje9sHjTnqddtBsiG91oAfsTW8iNoM5CDPbLF1
         AM8dGqR1ysIzTgQFgINdoX7mwjcuOs8khb8Q8neIud1/HxA6Qp5yK3Dw+FdjAwUrWxQK
         XRJy3huJi9QjhLEiu3Go2rfde0dm1q+tO8PvpVCk/Sr8PwJ1MRjXmePCIoChoLfgUTRj
         ZZzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=XDp0RcD7HYWUzlsOLtsxZUXX4GvVdXcns7B6N4dcr9I=;
        fh=1zSUO/tjvuavuaD0qygcvip6i03yX/Rs6fBBCgojquw=;
        b=qBDYW6cju8feCwN4trERXpx7XAY/WDM3O08Pb8vXSK6QmeegTv6hdE793Ch7eccN8N
         l6eSEMFFHpC+Qs2WybRnxfDvo68EMgGi/0LXzO8nUmaHzmNf+UJzCwSMZELFATCf5j3E
         yUrBhGX9WjfHq2/EQYRL6SFYvN8n8bXGTFKvFjmYro2j3hCi8c+XubL4FRkWKy/G/UtD
         YeDog0L8lK8vEST94dXp0IvA6yvKMqRuX1CmWv5bhGW8xroSFaL3HOlaPy+5uwOutjE9
         /jE3couyJtY3o2DaCw/9mUa767w3xfqbMlcvlE1xZU0D2ng5IDwzEzrmFHGkn4v6HpJ3
         KzFA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1790950034; x=1791554834; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=XDp0RcD7HYWUzlsOLtsxZUXX4GvVdXcns7B6N4dcr9I=;
        b=KGWOl5jsE8QQb4D8FZHcRRf3lRLbD4irayVANcnlm/qIwAMXnpXYCr5QJieryHqkoR
         v8CifHXoKNYHPgb8wwYE8PE3JvUUxGLoJGMuIuuXimaP+vSCt4DZvhTkRoE0aPZ36cOg
         cDvxMLqNnDpny0iv0KhmN6FkPKmYAgCTQjwzbJG4/S+UhFW3/QiJViXFXpN/aqhmuQiD
         RIT/SSGL1YkAbAxc3Sj3C7IXPjBH+SUjKGKT46M7E92U0iYhOY3jNO/djKP63ET9H2N+
         ucb667glPv00LkhYIybgLn34YJt3hzpP9MyqdZQrg97ckmkkBIsmhxEoSZUaCSmbaTBz
         KEcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790950034; x=1791554834;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=XDp0RcD7HYWUzlsOLtsxZUXX4GvVdXcns7B6N4dcr9I=;
        b=jHee/+mJY2FSn58poz11EsgwUpUV7q8Ql2s+Re7IRbxRZ5FUMoX0IBaic188Jb+2AL
         Xshwgi1e5fRFbaz1Pd6qNalFyCw4Rw0L/AcTSWY31KQY3u5r75nxUQdKiJjx4NbcxdBN
         O7Eh7vXP/BNbRiAw4m+jBuqzf5ghDtSX+5a7czW1XxFazu4uXcnvmYbcLHaj4VrtzsfB
         CZM2pcrCvjyOvDP5zBObbqmYyck8dwCvQK1b6jgiRmfFUKheM8L4BsbExYZ/2VDN/oGo
         U+xY+shrXyrhRoee3g49a0Ah6Mj+7XSBmOeG5hmD+DhKwKj1Q6jDlgVZoyStZ0g17XDS
         Lyww==
X-Forwarded-Encrypted: i=1; AKwUvBz/yYQyyukfo1WeUTosAcRaJH0171LrTEU09GOB5JLLV8tpvx1MvCXfKI0Mu6GdFngLE3kFcehXMq8=@vger.kernel.org
X-Gm-Message-State: AFq9FYIlbsXv6eutG/A4rT7EKLBxP89iFceToNNbyGyCqGq3d2ZRCBON
	mNTk/1GqhFxkxZtvl4WeyWUdwYLiz4Y4wxW7FcBq7Hu5JVg0dlGeH5LchIFb8Xulz7Ylmlt4plX
	0kjE6QpacURADgsrbCCfqR0lpYyNLWZ/D1OZmPrtBW1c1o29eX0vpRlWBsZWHIohfui4t0rKogX
	zNtzC+JsaSWEwNKZESWA8rfRb0kKiOY/kifp3S
X-Gm-Gg: AYBFou0TCymYacSKxP9mJLZOxSobvhAKTDYf2uDNDFNWe8TVV4B00VRWm0lNTIhSSzf
	SC1+Mo7Ewk02V5SZfSOoJFeb75FD4tkcQ0yOnITy1sY/fpD0FD9VNe96kYisgAKXHryZLf1zSyh
	TzAwVli0TewDqMYz2VsKKWdGbXFV2RApm3Y4c0z+M+5l4rqBA90oYGKEci
X-Received: by 2002:a2e:bc24:0:b0:3a6:95a:52a6 with SMTP id 38308e7fff4ca-3a8877b72d8mr7514341fa.20.1790950033915;
        Fri, 02 Oct 2026 07:07:13 -0700 (PDT)
X-Received: by 2002:a2e:bc24:0:b0:3a6:95a:52a6 with SMTP id
 38308e7fff4ca-3a8877b72d8mr7514081fa.20.1790950033516; Fri, 02 Oct 2026
 07:07:13 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260929071743.23624-2-edumazet@kernel.org> <179090395863.434549.3668493667259120759@kernel.org>
 <CAL4WiipAe11BJA0rs33_0=bzYXMr0qQvQMPc+6-awyFQdQ1yCA@mail.gmail.com>
In-Reply-To: <CAL4WiipAe11BJA0rs33_0=bzYXMr0qQvQMPc+6-awyFQdQ1yCA@mail.gmail.com>
From: Alexander Aring <aahringo@redhat.com>
Date: Fri, 2 Oct 2026 10:07:01 -0400
X-Gm-Features: AclHuK_sfowi4LPKpSWl8IXP3uRNzWbqORQfvYROS9BqQto16BFcN8kPZWF14yQ
Message-ID: <CAK-6q+ga-MNEXgENToB2hLB9jzpsGMrz-1sOo7WQP5M-scnAxg@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 1/9] dlm: fix send buffer backpressure handling
To: Eric Dumazet <edumazet@kernel.org>
Cc: netdev-bot+sashiko@kernel.org, davem@davemloft.net, kuba@kernel.org, 
	pabeni@redhat.com, horms@kernel.org, ncardwell@google.com, kuniyu@google.com, 
	edumazet@google.com, netdev@vger.kernel.org, teigland@redhat.com, 
	gfs2@lists.linux.dev, john.fastabend@gmail.com, jakub@cloudflare.com, 
	sd@queasysnail.net, jiayuan.chen@linux.dev, matttbe@kernel.org, 
	martineau@kernel.org, geliang@kernel.org, mptcp@lists.linux.dev, 
	guwen@linux.alibaba.com, dust.li@linux.alibaba.com, alibuda@linux.alibaba.com, 
	cel@kernel.org, jlayton@kernel.org, neil@brown.name, okorniev@redhat.com, 
	Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org, anna@kernel.org, 
	linux-nfs@vger.kernel.org, achender@kernel.org, rds-devel@oss.oracle.com, 
	philipp.reisner@linbit.com, lars.ellenberg@linbit.com, 
	christoph.boehmwalder@linbit.com, axboe@kernel.dk, drbd-dev@lists.linux.dev, 
	kbusch@kernel.org, hch@lst.de, sagi@grimberg.me, kch@nvidia.com, 
	linux-nvme@lists.infradead.org, idryomov@gmail.com, amarkuze@redhat.com, 
	slava@dubeyko.com, ceph-devel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Oct 2, 2026 at 4:33=E2=80=AFAM Eric Dumazet <edumazet@kernel.org> w=
rote:
>
> On Fri, Oct 2, 2026 at 3:19=E2=80=AFAM <netdev-bot+sashiko@kernel.org> wr=
ote:
> >
> > Thank you for your contribution! Sashiko AI review found 2 potential
> > issue(s) to consider.
> >
> > Critical: 0 =C2=B7 High: 1 =C2=B7 Medium: 0 =C2=B7 Low: 1
> >
> > If you believe none of the issues are legitimate, please reply to each
> > issue of Medium severity or higher and explain why the AI is wrong.
> > If any of them are legitimate and you plan to respin, please let patchw=
ork
> > know by including "pw-bot: cr" as a separate line at the end of your re=
ply
> > (one such reply per series is enough).
> >
> > - [High] A TCP reset or TCP timeout while the connection is waiting for
> >   send space can stall the dlm connection permanently.
>
> I dunno if I want to spend time fixing all dlm bugs.
>
> It seems TCP changes are now stuck because ood pre-existing bugs in
> in-kernel-users.
>
> Sad.

I will take a look into it and cc netdev people.

Thanks.

- Alex

