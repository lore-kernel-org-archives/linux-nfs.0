Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FB7634EF0C
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 06:17:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.54
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786515426; cv=pass; b=p7wbnsN3Pwpzs7MBXSN/RR4oZp9WtDoWdi1A+hcU1sO2GjjSzLtV3lgZUzkYRHnf/B5NS4eVz0vRiCWomrb9z6MDi2YSuOHGl8K3Uqlw9xG290s1/rFmzKy3FW83HLZPbJNn6Yslagi8df8eEdNI/9ccBxV2i/EH16b+m0YZNsE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786515426; c=relaxed/simple;
	bh=LXl7BrqzqXwTRS8jMN1RBu6UzEntwVKt1rN8dzTDVqk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=TW/b2MbOIxpOejK8p9jv8d7CyCiWOLkCtaEEH62NGTffoscL8BF7eibSsh0WShiydaOJ2hXCCBdiabi9UgSJwBX/Fj5jtleg3UKhSWmRgebRnRfIykHDK+QOhsjoViNN7o040KHtHUZIXU7rpL0hys2qQ8N0IQRk6l88n8wrWB8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fTVImhat; arc=pass smtp.client-ip=209.85.160.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fTVImhat"
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-459281bc13bso368995fac.2
        for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 23:17:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786515422; cv=none;
        d=google.com; s=arc-20260327;
        b=no1XkqNgLiyO5HSYG2aHniOvGZaoF9PtaW/ZF6daa35VEOBOn/SPffptQZRZoGKsb0
         a2Y79BseL+WyUy7vrzjYpAz/omr+xDz54Oi5sMfeiMKJ3U7CSPtrmPhpJ6Zv8oDNnSdU
         SpO4MOFhygzqNAT5YZBH5QXHrd9xEngBxcd/vJ8tOM8ufg2jZrijeZgL9wQNC8XPof9E
         yZkKISGnDNySJiiGEbrBWHCoiRYaTU78rwMshB69rnyL3BOJgjZJtUiGK1FEeTtkJMSK
         0rlwW2q6LZ2nDxHOZNIcztfW4nalwzREYFResBTpo3NAxXp7OIieCsH5Kxbw54jljENr
         8S4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IQ9zGywIcuABVN/oeLCBGsPZxOuB0JajQofLjw/eNss=;
        fh=MvBGFMmnTRizgudY9xcE9tJ4CejMKQ9kUJ/aPkButX8=;
        b=NSmlAlseK1rteKHyHphSFJhD0Aybr1m1N5j3oC7O5wC9UJCk2f3KsHbaD0iPRIPXEn
         FpxSp7IeId2OhMQjZldaM9AvL/ynBkmZbtndpuyrtl3/YNwcKUJMjmyXnjfv023yndC9
         cV0gEdgMHISa21kkcIs8GJiMUQ6lkmTEu93vYmSzX1Y1xQ00s4YZJL1P+mR7SWmUg05z
         PWEnFrS31BLOiZc4n7wpIaqicxd2RdoFVmozOBHF+igmCaAGIcgico2I30kNV8tc9wpY
         YNdMgUt8PQbPPERMrlPNPKSlHzKHtHCJhBnOAEYdVi4IQSYDSdCXaAojCjhbQrCv/iJ6
         r2sw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786515422; x=1787120222; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=IQ9zGywIcuABVN/oeLCBGsPZxOuB0JajQofLjw/eNss=;
        b=fTVImhatse6sN4J/7APg+QqO7Z9zwP55tgzF30zE3Pwc92sNh2PQZ2c5+KP2YZd5Iv
         NTfEeeBRXq+fGxujsbXcKVJjlH1HMbMToMFL1C2l1u5dk4qszFXVD1ON01PRQZaJJBaF
         rcHzvz9dpLhX/ZK3O2gy0CvLd5JlharW9zO0Bi/HqCZR2RtWjIB2repmIWJTarLQ3BO8
         q2Kbn+/NfIjeoHN3ymZ2jjjiLZ+lZq3qbmQt9H7/ZGncDZ6mA+ugSoZLGdkxoc0uIdtw
         puCDg3Bj69fFj0ypAGhadB4xc5p0rkIeGZhGSYmRbs38TPXr+bstCT/belBHVBHONrRF
         4L/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786515422; x=1787120222;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=IQ9zGywIcuABVN/oeLCBGsPZxOuB0JajQofLjw/eNss=;
        b=hsaCjQzhJSEfChBI6uWVdPPPWrJgPV+dNzvsDtzrz3AeTax5LOwjUlFcAgBqCXDRWW
         7s00nJmJfJe5+rTU0nFiu7dCehLKTulsuOI+XbxYs//fVTXbehF1b/P3Tb+hDMzcm+8v
         MMq8NLkcfw0mtvCYUJFT5beYKaMUs2EZPDUjcp8ulVG8N+vJkHKomBWfGz+hPf9HwL6e
         o/D00VxOET/rBkyJzT6GHHpC3awYOhkuwEQ9nMj5iN9E7EGDAR4X8fSx9fuphZx2YyKE
         JP+Y702jfPZra3nGeOIeMo4Wl6LYpOfmEXjDH9/EugIohZ2zx6jWpgeuRTR9L44qZiaP
         ZCGw==
X-Forwarded-Encrypted: i=1; AHgh+RqhC6WL6+qF0n5orO+zF4uSA1GzkljTIAIG9REbMphjuH/+mqt1aA7MPM5ry6zEcSsWTDIT1fV0kKU=@vger.kernel.org
X-Gm-Message-State: AOJu0YyaVO+BTSRMR+F1K+AlHUNk4pmJqrX1i5MmfGRBCGATEErYOUcX
	MSZiiF6v0L4EB+rgst8k7Vaqu3hDcP9u8tb/59302Cn+3P3EPQKEzzGATeeNkNecr+fwxjIkjxi
	hV0yw2LVqzbfZyWRi/U9yEnwck5PaI4I=
X-Gm-Gg: AR+sD10HjUnn5DDH9FX7hmaY5X3vNP4j/Cw6lE0XpVpdZuvr7PJmqZoCm93hi0u//+7
	yvnU7e6NqOROQohZL1dl98hOHyOPwyP5+Bso/gShIWUlL7tJ9pkLd5As9+Qa5dOWf60BG67cR8Y
	HApYSOFnGyxfxqo8I4UZwYcJB3nG+cSMfTrj7W6hGcIn0BaOUtUSQclMgSX66rs11mRS54WGrrb
	CSeaUapX/EpZ2HhCR0pC6TtY8T45fpvgVBtFYMiWni7OYB0lpvRmbtxWaR2zoIQHZ98BqOmhasV
	pKoK1dQzrFQ5mxX0sC2vSywYQjxHKNI4UcM1BrCtxRaWzA==
X-Received: by 2002:a05:6870:ff98:b0:442:175:cea7 with SMTP id
 586e51a60fabf-45e3e634ce6mr2516216fac.1.1786515421866; Tue, 11 Aug 2026
 23:17:01 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org> <20260811-recall-any-keep-count-v1-4-de9ca00493b7@kernel.org>
In-Reply-To: <20260811-recall-any-keep-count-v1-4-de9ca00493b7@kernel.org>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Wed, 12 Aug 2026 08:17:00 +0200
X-Gm-Features: AUfX_mwkR5QWa7OEAOSEIdcfNjEbM-go0maaprDm2bc1WoyXYyUFSE718za2dwI
Message-ID: <CALXu0UeKoYPq0FOGe2vQP2p9txTzEkscc10hy4Lw_S6=wK1a3Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSD: Send a meaningful CB_RECALL_ANY keep count
To: Chuck Lever <cel@kernel.org>, 
	"ms-nfs41-client-devel@lists.sourceforge.net" <Ms-nfs41-client-devel@lists.sourceforge.net>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 11 Aug 2026 at 21:57, Chuck Lever <cel@kernel.org> wrote:
>
> deleg_reaper() sets craa_objects_to_keep to zero on every
> CB_RECALL_ANY. Per RFC 8881 Section 20.6.3, that asks the client to
> retain no read or write delegation at all, whether or not the
> delegation backs an open file.
>
> The field names a count the client may keep. The client picks which
> objects to return, because the server cannot read lack of recent
> use as lack of usefulness. Zero leaves nothing to choose among. A
> client that complies returns the delegations backing its open files
> and reopens each one with CLAIM_DELEGATE_CUR, so NFSD trades a
> delegation for an open stateid and recovers nothing. A client that
> reads the zero as "unspecified" does nothing instead, and
> nfsd4_cb_recall_any_done() inspects only the reply status, so NFSD
> cannot tell the two apart.
>
> Derive the keep count from cl_deleg_count and ask each client for a
> single delegation. A larger request reaches delegations an
> application still has open, and both callers re-arm while their
> condition lasts. Skip a client holding one delegation rather than
> send the zero again. That gate subsumes the list_empty() test above
> it, and it belongs above the NFSD4_CALLBACK_RUNNING test_and_set. A
> continue below that point latches the bit with no callback in
> flight to clear it.
>
> The Linux client ignores craa_objs_to_keep and returns unused
> delegations from the type mask alone, so the count changes nothing
> for it. The gate does. The reaper goes quiet for a client walked
> down to one delegation.
>
> Fixes: 44df6f439a17 ("NFSD: add delegation reaper to react to low memory condition")
> Signed-off-by: Chuck Lever <cel@kernel.org>

ms-nfs41-client hit that bug when implementing CB_RECALL_ANY
(https://github.com/kofemann/ms-nfs41-client/commit/3abe73c8ab0d924450a1c1c480f0b14f963f9531)
with Linux 7.0 nfsd.
What should existing NFSv4.1 clients do if they encounter a
objects_to_keep value of 0? Right now it recalls ALL delegations,
which basically is a "reset" of all delegations.

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
