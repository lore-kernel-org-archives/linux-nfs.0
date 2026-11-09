Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=77.238.37.81
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794239521;
	b=eQEaDW28IxQzaiIsLnCzc4h6TyUAVn84RdjFoYsqv9tTAowo5IIXwYMlqGC+kW5igsvr
	 0kBCSLJMHbGudPKvJdGcpON+C6Y6t2t3PIpcqczSWKRXuqHx9oR9tCMKpt5FOUiKZ5I+C
	 Mq4ur1PpKxr5tffK31ZHnpghWaMYcaemX6uw7ho8rKLqDdMf/wBvJdiN6TDsJfrIXJ2A4
	 z3QqAdPIhtw444y99xIegZY7OkqAT1Z9g3d8CWS5QvlPCddpRah9mEH2yffsNN1yhBa17
	 HZAo7rfM+yuvh+GPipXM6r/jEPCWP0OrZuQT4lCdU22ZoaYhvokPIn1EGfDiXAfHh8w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794239521;
	h=DMARC-Filter:Received:DKIM-Signature:X-Halon-ID:Received:Received:
	 Date:From:To:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition:X-Originating-IP:X-ClientProxiedBy;
	bh=o6GgudDXCYl3fDfEQ1wQIjy1JvU5vBBqHW4cXH9t1i4=;
	b=lx4zc07Z/PnQyZnx6UK/idNeY+csLFwWsV2Ec6SWG5SPErWxBM5DHcACeJEXMy30x+yS
	 x+tSWapLKNuTSJx+/NHFVNuipGOJmjBYycqnd+x9preSPuFYnKAqoCBd7EEnWh9550KLM
	 nV3lyZD7QUEY8Tl/Dqiq/Wu0824V+3iZy31LiQ8yVcuzXzG84LnE2MCCsfe+uEorMp/iU
	 GMZmKLLogHpg3fYqGUQNsLVABiUUA25hWZErYCSyJ4sDcMES7w1ud/aKbcDIEHMlhb2q+
	 Mw1m1/oM/eooU6WyOeGexcjcfU4dr28vy/KlGmLLj/A1ez0dFmORL1h5PokUeF7RF8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=astro.su.se;
	spf=pass smtp.mailfrom=astro.su.se;
	dkim=pass header.d=astro.su.se header.i=@astro.su.se header.a=rsa-sha256 header.s=halonv1 header.b=mWHkFFlS;
	arc=none smtp.remote-ip=77.238.37.81
Received: from mail-prod-route12.it.su.se (mail-prod-route12.it.su.se [77.238.37.81])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEAA4606A31C
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 15:51:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BEAA4606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=astro.su.se
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=astro.su.se
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=astro.su.se header.i=@astro.su.se header.a=rsa-sha256 header.s=halonv1 header.b=mWHkFFlS
Received: from mailfilter-ng-1.sunet.se (mailfilter-ng-1.sunet.se [192.36.171.207])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail-prod-route12.it.su.se (Postfix) with ESMTPS id 4jNZ5z3T47z1cS
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 16:51:51 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=astro.su.se; s=halonv1;
	h=content-type:mime-version:message-id:subject:to:from:date:from;
	bh=o6GgudDXCYl3fDfEQ1wQIjy1JvU5vBBqHW4cXH9t1i4=;
	b=mWHkFFlSAhBiIbxd+AQAnALui/WKKoeLR7Avbt54SAYi9YV+OLDDM7rLK21AMs31aUXeviH15t3wb
	 euCEnPP5k49GHCvAo/pOhbLcNn7Y+NgTfvY/Xh472PWpuB6q/5EikGqnNzJOdrBhNNbjUOAfhHp6Om
	 CO2jZsP7JpdO8oC1alhLFDreVyYjxAV0TxIuHkHyrjeP/w8wXwNV3ZKLUhdFdfcp89VLm3OztzgyN3
	 skd3ShDJKfz1oLT+0x7wKSyvRIsFT6TXoW9MKKMTpoTNF03Ugxsr3e1Gsdum2OHAJX74zn/YlPTl6z
	 e7mGYONys9huUIpZRlOVkf0XY5+q1Eg==
X-Halon-ID: 7a6cfaf5-dc55-11f1-aa92-0050569a42e2
Received: from mail.su.se (ebox-prod-srv24.win.su.se [130.237.162.54])
	by mailfilter-ng-1.sunet.se (Halon) with ESMTPS
	id 7a6cfaf5-dc55-11f1-aa92-0050569a42e2;
	Mon, 09 Nov 2026 15:51:50 +0000 (UTC)
Received: from as-2866.astro.su.se (130.237.200.210) by
 ebox-prod-srv24.win.su.se (130.237.162.54) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.56; Mon, 9 Nov 2026 16:51:50 +0100
Date: Mon, 9 Nov 2026 16:51:41 +0100
From: <Sergio.Gelato@astro.su.se>
To: <linux-nfs@vger.kernel.org>
Subject: idmapd uses [Static] lookups for group names, contrary to the
 documentation
Message-ID: <avHsDTif7HkPWrKj@as-2866.astro.su.se>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
X-ClientProxiedBy: ebox-prod-srv28.win.su.se (130.237.162.248) To
 ebox-prod-srv24.win.su.se (130.237.162.54)

According to the idmapd.conf(5) man page, the [Static] section consists of principal to username mappings.

In reality, support/nfsidmap/static.c performs lookups both in static_getpwnam() (as documented) and in static_getgrnam() (undocumented as far as I can tell, and problematic since there is currently no way to distinguish between principal-to-username and principal-to-group mappings in the configuration file).

Seen in source code in version 3.1.1 of nfs-utils (and observed in
production using version 2.6.2). The symptom is spurious log messages
of the form

nfsidmap[PID]: static_getgrnam: local group 'USER' for 'PRINCIPAL' not found

where the [Static] section in /etc/idmapd.conf contains a mapping of the
form PRINCIPAL = USER but there is no local group named USER. This is
relatively benign, but what about the case where there is a group named
USER but it is not appopriate for PRINCIPAL?

My preference would be to remove the lookup from static_getgrnam().
Otherwise one may need new syntax in the configuration file, perhaps
PRINCIPAL = USER:GROUP
and additional parsing logic to go with it.
