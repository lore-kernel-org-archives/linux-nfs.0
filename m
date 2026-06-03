Received: from mail-qt1-f176.google.com (mail-qt1-f176.google.com [209.85.160.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8CA827BF93
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jun 2026 11:02:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780484537; cv=none; b=NzzER5JzZ/jjCuZgjAcTnet8qIL1CIZM9ynFE4cOCsVjrb7UK/FaLQDr1LDguU4IztIkPvgVBBCoZcjY/wCKHZL6/sbon9Yh8Dlf6lFpXjBMMYYTdqb8T5ru6crntMLQMILmbHeGFyqRM1dk9YlNXwdm2QozhbmHPNdYKzbRSlU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780484537; c=relaxed/simple;
	bh=u5g5DwSt5q9TvN8+oJgpOjZm4wjKuGhymyxIlp6JDHg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=hn1TpohAfgBzy2kZAhln3DRnO8c9EzoP3sAU/q3GY1w1OnuwbiO+co3sMVmH2cpItEgQ1XCitVCcWMd9Al6Qao9xOMJBpxFDIkc8o6gAfdGR8M+gOEhGDVmtVIoVECEmWBia3m8VVuGL4d5p9XcMg1DxLl/S6WdYKGybENw37HE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=fail smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=ZbVo80zb; arc=none smtp.client-ip=209.85.160.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ZbVo80zb"
Received: by mail-qt1-f176.google.com with SMTP id d75a77b69052e-5177945a22eso5161761cf.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 Jun 2026 04:02:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1780484534; x=1781089334; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=u5g5DwSt5q9TvN8+oJgpOjZm4wjKuGhymyxIlp6JDHg=;
        b=ZbVo80zbeH81BSai/7lLu0HwTkw7+tyk9pxgO8SFXfzbzTQ9+01RyzDKkUfCEzs1kD
         snrOkoUHaTaKH7oFPiwT2Q+Cx/uMXJanGyFl2Yvt7s77m6WFaDzXahFwyeqNnerJGGuJ
         tsb94Cu+Uz/6EjSj67/Ny+0Tp9voIAca432QpO7JlyykA2kmElqQZQRMS4V79ZyGtHac
         nuwfxYApqnHmstTIbq4Yp8tIhL3hTcM5jlx4lRml4JIX8AhEFnkQhK9bluhXsXKO1pF+
         tCfgVJ1ju1ybgN78bWysQx0xsA/61fvzch9WJaK6FMGLxvamadsxks5O685qhn7+XDjm
         uBZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1780484534; x=1781089334;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=u5g5DwSt5q9TvN8+oJgpOjZm4wjKuGhymyxIlp6JDHg=;
        b=T3W2ZU6Vbej56o74em/MYQk2Pn5S00UK6XazGnUPLC1EKlyYvyQ+4rcoFH/dLdGfIY
         H8oSGGmSdeBiZ0c/EJSazmynjvo6aBiaaUpB9/mhIpEpNzRK9y42EQm7KKT+62mTtIHZ
         eZ0bk5Qlv8JxVD1pvB7nm0+4G+FB/TpJ3SKwMH8RTHMLxbtfAYq5aQctZlmYkD4bchi3
         CAOJhdUA3CiSmTJ4Ezk0Ne6XNh8EWow9oDHRuxSCNG1j8L2BH/XHHXAg6lxAHi8Jqlwk
         fV8rbet2L2VGT5Vee3cRhtt9cuwiuNi1cQW3jCBDaPhsmol55c1k9L+ffFtm3e2YiPys
         +4jw==
X-Forwarded-Encrypted: i=1; AFNElJ8hrzYgiUjw6IQIej/WKN+CpRxD+NIZ8wUsBWC+/XbposFaXn0eEOIRN8FqnyDAU05wbAlM/w/+nd8=@vger.kernel.org
X-Gm-Message-State: AOJu0YzacoYbEJr7JmzQZWf9TN1I69TvRo2u2X+ve1rlD5G3saebr4F9
	5mhr7qg/Ev7ngm7vkc/rcSayGU1XABhIqp1FSMtdeLtxtEUXgrwy9iwZygZF0xlwOQftjTHMPZv
	AgGY2
X-Gm-Gg: Acq92OGViKnEmAdRw8g/Lu3Bt1kLEpKTRaMdWc+nwQKEVsiATYmATImRO/A42E2wWcZ
	MZ7/BSS0K4OohBifpBuptkD1kf4rZXuKDsTXmZD+rM9/0CswAkhnIdJfFF6OXx7kfZV9+cLg6fC
	rLQIDOnlPX8QTA2T3jQkGG9DCn1JaqovxNNwMi7ZTS8y+x0YBiytoZajgrK/jHK8v2jssf93z4y
	ul5oHzcATRdgJJ6xzK6x1wMkwA/iXp5URTLZCHTMAAzwtff/n5FLzOZXZD7Y2J/iBO6Szv+eojg
	isKaEOspN8kTTEeIi0QoDV7EnZG2DYy+7cTwbgVJ/Vj/F7DiUi+hDsJeAeLCA8tXeDvc+te/Y+w
	cQG6DZ7NGktzpcsVlA7LJ6rO6bPh28sPH36LXd+/DpMAbMLnIH0Ef5e9c3Q0kN/qC2F5GPDj7DT
	AyJldyeqHCyK7Kq9b+sN8E5Ka8xY2ABxNWcCb0Q6L6p8BS/dJze+M=
X-Received: by 2002:ac8:5d94:0:b0:517:6642:e8e0 with SMTP id d75a77b69052e-5177868353fmr40570641cf.30.1780484533921;
        Wed, 03 Jun 2026 04:02:13 -0700 (PDT)
Received: from [192.168.37.1] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-51775c60dedsm20404121cf.13.2026.06.03.04.02.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 03 Jun 2026 04:02:12 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>,
 Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] knfsd: per-client fair scheduling to prevent single-client
 starvation
Date: Wed, 03 Jun 2026 07:02:11 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <20555E8B-0E49-4328-8B31-0F73C3D286FE@hammerspace.com>
In-Reply-To: <561e9ac6-348f-4d6d-b896-38dbe5ede3bc@app.fastmail.com>
References: <D33770A1-9098-4F1A-93EF-590E6C0B7638@hammerspace.com>
 <473e337b-fabc-4884-a6c4-0f04b6874d0b@app.fastmail.com>
 <3AB7EB6A-B207-4B91-A695-66C4704D0E31@hammerspace.com>
 <4c5dbb98-0209-4572-8eac-1578536bbd78@app.fastmail.com>
 <AED22AED-E97D-40E3-9839-BF8307EF8B65@hammerspace.com>
 <1a5c70d8-e7f4-4671-a29a-023be7c107fc@app.fastmail.com>
 <178044079821.2082204.6117918610145832039@noble.neil.brown.name>
 <561e9ac6-348f-4d6d-b896-38dbe5ede3bc@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

On 2 Jun 2026, at 23:44, Chuck Lever wrote:

> On Tue, Jun 2, 2026, at 3:53 PM, NeilBrown wrote:

>> Idle clients will get pushed back to 1 slot, active client will tend
>> towards a "fair" share based on how comparatively busy they are.
>>
>> This wouldn't help for v3 of course but I don't think we need these
>> advanced features for v3.
>
> Ben’s employer might disagree with that :-)

Yes - v3 is pretty important to us here.

Ben
