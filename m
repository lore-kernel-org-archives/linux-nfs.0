Received: from mail-ed2-f12.google.com (mail-ed2-f12.google.com [74.125.228.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E1AB3C5DC5
	for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 19:04:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789931095; cv=pass; b=PIPXwIOo2P4imCDaiypfoVgURY+aS/cUVrR9ixUzDbXwYJ6kDLvCRbmizodbyvEkUClLEVejgIR1O6rkUsNFpWoEk4uKmanrkH92dzmLKkS983YM702tEZ6WALFI/wjgATuZ9IK+/JH/GQYbfwCkp1/YBIFIMmJAI3M9K/+t5As=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789931095; c=relaxed/simple;
	bh=sGhlhxJwZ1HItBngvfzuMJ8qcyAiUKnY9H0c11sxk9I=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=rfizpYR2L5rnLgsJt+EGGFNDdzGrF8W9lKOIX1FME8+A4EXSMDJu/J2RVmwDJK0KguTtskPJvxdRTg1bfI7vekccUsIt8LUVi4QMObkBLcVpL0t/dHCHpt488OUaYp4EVQYDtTFth9cDU7g+uZ6gZnFfow+rllMqpWOUdEug1I0=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=EZLsE191; arc=pass smtp.client-ip=74.125.228.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EZLsE191"
Received: by mail-ed2-f12.google.com with SMTP id 4fb4d7f45d1cf-6a8038a9f10so3093549a12.1
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 12:04:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789931091; cv=none;
        d=google.com; s=arc-20260327;
        b=Emg3dhCVShybfsn65d4iblHxw/RFBtjsZ5kvQRG9Q4/LsITi2Mn4SI87R6ti40idoy
         wAKINqANpvxGHfKFOOOP1TLKjQ8Z5zo+4dXVPSM6lRQU/TCbKbxncAtWD0dPMVOyw8Wv
         csLDQvUm3kcss8NSXICMPAoNkCXRfaqzOju98rLTIsYiVfMgN/flmkJP3Xgc3SnwUEVx
         ZNbRTs1NeoL5xRPHbNqF2KI795PhWf0IIOxwXqZsFOgEqQPrTcAtDC5lRLxB54CmWqF9
         b2HtdPGxE8wRiCrEPSfYtxiErUOTCr9sAAdvgPcee0pmNbaCD4v2zkmRAhEyFWVg27/j
         mLag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6FcuklV7Ok0OiLiWfC2X9EkhRtCI8Ufeoo4QuXLBmjQ=;
        fh=fQehWeCvLKlc8Gmu9zdjKfk0DFCUd729nRJ6lmij8GQ=;
        b=qCDif6d7cNCCyf/JTRXIN+sccyJ3WPhaUSifaVYxC6RVZDDR9sj8lvrgUNk6uj2Hct
         R+VS8LLirVXbalGQekiIlLYzajHY/Mr63hNp8H4k7Qx64QJu49K5TmoDX8ywP4zFG9BT
         cZQDjmS3JTeECEaCSkM+sOl9i78ocHjR9mSdDeGTYrudod2CgntxArycECJwAkD1qKrs
         edYv9QDZKDOD1yiCEMZNfVhSIy4toKx7BQyXz3PhJaufU+1EsvqK4k00wNj7Z3Vz5PHY
         obT+mbwl/77LOD5ptiqFuSO/nxmgJBuCGh8ou5i/gAhLuso0/t/ATgzTvxrUlqa1wnhK
         z34A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789931091; x=1790535891; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=6FcuklV7Ok0OiLiWfC2X9EkhRtCI8Ufeoo4QuXLBmjQ=;
        b=EZLsE191ZLgoAsGI+Mtsvrej5eNlnlZRozo0+SoebL+jgDzP3FrHdO56QCN13uo75z
         aYO694inn0MkHo/pHeZDIod6/RBpDWrOtu+JL380IiE5ikujv12ooUluZmFT8kRKcBtz
         n4AlDwy+EY6cL7TfQNz8p/aEWzBYJzUHNtauRPUjaBCLnrKaIrzOzb8xFtpCtGBtlvnw
         sLLIMhjINUjNsO93VKeCPTRBbGUA3e339gebwdjJoKDtDp1acALbfqeQ93OrLKqfG+AA
         i2OOw4LXgBlIojeBFdgTUQin4fSQUd+uj5sAOIdsOyHxjxgzHnIyaJjqc5bKDO8AqJBY
         ElzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789931091; x=1790535891;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6FcuklV7Ok0OiLiWfC2X9EkhRtCI8Ufeoo4QuXLBmjQ=;
        b=1opUctOeYTZAAAPiDYPiqSfmCxgum6qG7BTSJMEwVjI/8ZOppLAk4E7/i+Hp8lGn3V
         9gQPIwhoqH5NmaSHfC1169eDQEGz5pxzyd5pUECTdL5z6CTCy5Z5etIB2wIaqcfGiCXI
         XhqZOZ5Z09/UuL8wC0wXT9Uu6lBYnKfOtLKRTXWdz9X6ugc79nGqUdSULTglbge5Tg73
         oT6chmha9UrkbfjQVs1eMZmxZSb+TbZDOSecdo7ZDFdWiNCi6iXZBD9aw8fR03b9ajL8
         A8S90RXch/Bki3d2ticRib2INs2zpdQkLLVsIK99ejxIzL775pxDP5h7rVjTRdzn+Irc
         8cZg==
X-Forwarded-Encrypted: i=1; AKwUvBwg2lCVxcg/XYgiirn39r6H3Pv4kCkDxYzc1uwkMlotOZdRbIXLSnruM1UM+q10zaoPSHrv99UiG/M=@vger.kernel.org
X-Gm-Message-State: AFuF++n6oSl0j1G3JaXx1m2ZwTtY3ep5v375zrQrnagGpOVPD6x8tqHo
	Pmdem5nL6DsE91SjVdP38zMURRFks8DMySAImg0i6JfvYVrOnhRYQoq9HXfiQyN60YT06BZmgET
	zWyrmS+MGuVAteCOESSWObIm5ryTL2w==
X-Gm-Gg: AYBFou2+Y1P6KKCopa88uD5vqaBxD4wtvJrLNmWum2YVDd24ygFeyTA01G7fcqQmnnz
	mh6Fr9a6MhsmAgIpwNaMuKyMSyvLstaWsZZGWnyFp17cTkf1U2PQQ2Etx2OZFHZgWE1qG/2Ta8D
	ylN8plkGblgXotwtLWrp50zLtPGcEldbyLUEZDSI/SQ9I8e8oIwc4zIJgpG9WWqvkz2tnMWa+5b
	y+dGkuvYMYewpDpSbj5CXKIy1RP3bn1YPVNXWEyiwUNUpJoYDZL2loBUW4/jtyycfJbMP4vAs8o
	5wb1MCCThckwY7nsx8lTNFSa7vFfvMOHJe3Qa958k3CXKbKWWGu51ltNVPVv6tBOSmnBLMZCtUe
	lwamYeNgEAyCd3YtcquivJg==
X-Received: by 2002:a05:6402:5d6:b0:6a9:ae27:d6ab with SMTP id
 4fb4d7f45d1cf-6aa562f39c1mr6766899a12.19.1789931090968; Sun, 20 Sep 2026
 12:04:50 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
 <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com> <CAPJSo4XZcAvXE6gP1vXFSfGZnjiQ8BwgeqO02obd_nWc-boR_Q@mail.gmail.com>
 <CAM5tNy4Jm=Mu4Tu1QUQV4JjMj0iabFJ1NqnytWioWtu6bDYUuQ@mail.gmail.com> <CAPJSo4XuHo7jed5AThjooh2E8uuoxQYDFV+7x+CrBsrKoN3Lkg@mail.gmail.com>
In-Reply-To: <CAPJSo4XuHo7jed5AThjooh2E8uuoxQYDFV+7x+CrBsrKoN3Lkg@mail.gmail.com>
From: Rick Macklem <rick.macklem@gmail.com>
Date: Sun, 20 Sep 2026 12:04:38 -0700
X-Gm-Features: AcwNN1XC8iXrzRchAaxw6wqb5zmIbDRq8gvrf2z6GUVjws6UlhnS4HF3T_8pyTc
Message-ID: <CAM5tNy69D-4NPAReG+NPY1+R1ARNyg1K934XzhAVBH2KAir7mA@mail.gmail.com>
Subject: Re: [Ms-nfs41-client-devel] Need NFSv4.1 "WANT_DELEGATION" op ...
To: Lionel Cons <lionelcons1972@gmail.com>
Cc: "ms-nfs41-client-devel@lists.sourceforge.net" <ms-nfs41-client-devel@lists.sourceforge.net>, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 20, 2026 at 10:32=E2=80=AFAM Lionel Cons <lionelcons1972@gmail.=
com> wrote:
>
> On Sat, 19 Sept 2026 at 21:22, Rick Macklem <rick.macklem@gmail.com> wrot=
e:
> >
> > On Sat, Sep 19, 2026 at 4:43=E2=80=AFAM Lionel Cons <lionelcons1972@gma=
il.com> wrote:
> > >
> > > CAUTION: This email originated from outside of the University of Guel=
ph. Do not click links or open attachments unless you recognize the sender =
and know the content is safe. If you are unsure, forward the message to ITH=
elp@uoguelph.ca for review.
> > >
> > >
> > > On Thu, 17 Sept 2026 at 15:50, Chuck Lever via Ms-nfs41-client-devel
> > > <ms-nfs41-client-devel@lists.sourceforge.net> wrote:
> > > > The RFC treats the absence of WANT_DELEGATION as a normal case
> > > > with a fallback. Section 10.2.1 notes that "since the server is
> > > > not required to support this operation," a client reclaiming a
> > > > delegation with no associated open can instead use a dummy OPEN
> > > > with CLAIM_PREVIOUS and then CLOSE it (rfc8881.txt:9596).
> > >
> > > I had to refer to a colleague for this one. The answer:
> > > "... CLAIM_PREVIOUS is only valid during reclaim. Outside the server'=
s
> > > grace/recovery period, a compliant server must reject it. ..."
> > Yes, the above does refer to reclaim during grace.
> >
> > However, I do not see why a client cannot do an OPEN/CLAIM_FH
> > for a file where the client already has an OPEN for the same file
> > for the same owner.
> > This is normally done to upgrade from OPEN4_SHARE_ACCESS_READ
> > to OPEN4_SHARE_ACCESS_BOTH, but all the RFC says is that the
> > access bits are or'd together. (It does not say that the new bits must =
be
> > different than what is already done for the OPEN.)
> > At least for the FreeBSD server, it appears to allow this for "same acc=
ess bits"
> > and will issue the delegation based on the OPEN4_SHARE_ACCESS_WANT_xxx_=
DELEG
> > bit, using the same rules as an OPEN where file is not yet OPEN'd and t=
he same
> > rules that a WANT_DELEGATION would apply if it were implemented.
> >
> > I'd suggest that you explore using the above,
>
> At least for MS nfsd and OTAP nfsd this does not work outside the
> recovery period.
Nope. I said use CLAIM_FH (not CLAIM_PREVIOUS). An OPEN with CLAIM_FH
for a file that is already open'd is a normal "upgrade", so it has to
be supported by
servers outside of grace (and not allowed during grace).

RFC8881 says..
   When an OPEN is done and the specified open-owner already has the
   resulting filehandle open, the result is to "OR" together the new
   share and deny status together with the existing status.  In this
   case, only a single CLOSE need be done, even though multiple OPENs
   were completed.  When such an OPEN is done, checking of share
   reservations for the new OPEN proceeds normally, with no exception
   for the existing OPEN held by the same open-owner.  In this case, the
   stateid returned as an "other" field that matches that of the
   previous open while the "seqid" field is incremented to reflect the
   change status due to the new open.
Note that it does not say anything specific w.r.t. the
OPEN4_SHARE_ACCESS_WANT_READ/WRITE_DELEG bits,
so I cannot predict what other NFSv4.1 servers will do w.r.t. those
for this type of OPEN.

>
> > since you are only doing
> > it for an "experimental caching model" at this time.
>
> Well, it's already in the tree, and slated to be the only caching model.
Ok. But if it doesn't work well without WANT_DELEGATION and servers
aren't supporting WANT_DELEGATION, that doesn't sound like a great
plan to me?

rick

>
> Lionel
