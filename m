Received: from fout-b4-smtp.messagingengine.com (fout-b4-smtp.messagingengine.com [202.12.124.147])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E59BD52B1D1
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 13:29:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.147
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789651803; cv=none; b=WNjb6jZFDeJGMMxzM8969XRIwg3+CoKjuOqbzr5x62jIgak628HOTxMjbNzUuvjslwJ67FYj3wDVrvREtNuulx1Zq++k0BAy/t7n5QL+dhhFiLS5rnsefIOyz+5m0HkZDnwunnpNbnGXsYehcOIVrrqE3GFyml29hsTajb8NLZA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789651803; c=relaxed/simple;
	bh=UIEVmIk8bS01F28QfFpjZMC+AsE6+RySiVdJiNsTwBI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=DkJBXMsNzd3xUXwLQurpezFAxQqjTWD7sLU2d8NxbDIF4ldWRvdqSToWCj21dbQCPPsZNw1plKJt6TAVal2uKwJAhbLdV9QKcAad36MT2uJnehq+frz/QqWAfMDh65cARYJfiQHw/VnRewnyO3cb9QgeYSZbxdAhMwt+jf3GEM0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nowheycreamery.com; spf=pass smtp.mailfrom=nowheycreamery.com; dkim=pass (2048-bit key) header.d=nowheycreamery.com header.i=@nowheycreamery.com header.b=Ln4xpyOt; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=bp6uvkfA; arc=none smtp.client-ip=202.12.124.147
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nowheycreamery.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nowheycreamery.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nowheycreamery.com header.i=@nowheycreamery.com header.b="Ln4xpyOt";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="bp6uvkfA"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.stl.internal (Postfix) with ESMTP id 827A41D00141;
	Thu, 17 Sep 2026 09:29:55 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 17 Sep 2026 09:29:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	nowheycreamery.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:from:from:in-reply-to
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:subject:to:to; s=fm2; t=1789651795; x=1789738195; bh=lIhgaAgpy0
	uf8EfPLqQrRJiYnVd+5eiBRlvoSMabjDY=; b=Ln4xpyOtFcInAvLE9gIIpwVzKq
	9fIvP2YJAc5T08AP1wyWn2lk0F0xIOSBUXoe3Bc3ugVrNEw0I2hXPlvmFofzshoM
	IdVUjd06okkebNfcKXk/Ol+g0WUIgWHfWkiCoKYiAmP9RW3uO7UBvvxdbCOCTDZ9
	UXbH810viZfdHD929MfitJ/6vNLDTZtZLBpvXrjLsjEBXVW7JupXnlsmyR5IcTn0
	9FUY6y1NXULTdQ1tBiltKF4SFCeeR4CJfCn7jUeZ+eHqDsy8A0Gnk82XSkAiyZbS
	284CeNRdQfxBEXgBdq56pUB6o3Q+i5Y9cWKGCU2c30LNiN48iqqUXdzKnEHQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789651795; x=
	1789738195; bh=lIhgaAgpy0uf8EfPLqQrRJiYnVd+5eiBRlvoSMabjDY=; b=b
	p6uvkfAfFnmdwJ4koCQcOjTC+1hM44NXYYF6z0sABrcmP7215PjsByAPq4JmMPes
	cjPdoUWBrV1Y8EqHxPBRJW4vZu2YYyA11f6/QFZVEWlZqPqR88PyYHTy//S4n4Bi
	+tuBihcfM2TeXjyDBQDH9Y8X5+rqwmuRiqYt6zm+ela8DBEqyjF//I3avV90zEU9
	WuBYQnd37WGfU3SG0hiaBwWBwgEIpCwzmKSWVY+3Rdq8C0XBnoM/25SSqqilLmTp
	yvKPUjQkvZgF+kh2rWkBmgtZB32cSqhRr1PZr5A4Oue+5ra9Q+XWDNt7pcMGhYWd
	iPMiqx4V3jI+FiKwjBHJQ==
X-ME-Sender: <xms:U-ural8-_IXC0eVYJ9MASbkBH_-e8xDhbJpifziY1jLvIGmenek-vw>
    <xme:U-uraki8kmkyXFX-HKP2wyDErbZ2uRqp-pLR3nM_T7Ka9E8phbLIn9gB-9vuQdS_P
    ZPU5BX1oL4-rPdS7fyCruM1BOgkGc4wxlv6gOCi2KKXiUdxAkHvtwXJ>
X-ME-Proxy-Cause: dmFkZTGjzhKjOMO47Xb9hg0DAQG5ON87wSluripfuHO0DuVcCE7Ir8inQnkeX1EjPT6Xrm
    tyHsXnWS66IEfFgOTmqOkT684ER23pbCCOYZAI6W7CP0Cakr+PnLM8j4wIyNcti//c/Gl8
    PKF5asK/ujUqKckHHb+ihyEDXdmnhDY/1qRYa/rstFgJYxpSLZhcs2UG/sFFfIk6tFvFjp
    G2xig/X26CCJRnSLB7O1UOFPSoyQpECRf45v8Fyxtpxkuntr5vxbLKH5uQOkhSIxP4rbVb
    l9f5tSOHBqL5JrNAIjDdclKM5b/+9lAjMuDtWRB6Nya4zdquoMR9gvL0JF0BIfxMblwMQW
    dXXTfu/K9Eg9YJrI58YmgQ79zJY2I6t5TciG4IDfhxcG0zImfwqa+MfKSZKg+qmE8UDGPF
    mbV+xYBhGtA9LpTWB7eGynnAXI/l9XmNO8on/hlpLG711rfe6U0giV7cMQIp6MvPBAHTVL
    VceneR/dplxm1M8hcl+CSsROeDewO44Ct/qML2FYk+0rmR1Wp48rfSO4+AktuGU4elaPep
    E2GkgbYUBGKLHFdAGwPlUxf0UpGAsZYVbFM1mKkfEruZsDsdsUE3B/wNc9sWk1Qqzbors6
    Py0yJ9zwAaLrFtBtrYGnezuYO2seDEprVtYOaCct4TySTnysDZ77PXIDMS1A
X-ME-Proxy: <xmx:U-urasiOEab93UX3stLYICda88eIqgFA6QFhdSu8bI9ySDnPgnagag>
    <xmx:U-uramilwhGTVlnfCAg3VooNCcs1g-cYRnV0qg1yUd1KCZ9Y0oDTQQ>
    <xmx:U-urakKacVHUMcRD2Y5mOvlFRv2zS8lprQvSdrwHix8UIXROs-0IGw>
    <xmx:U-uratFTyjKjglQSmem-4NELQqp3emOW-2gCJp0sfT6eX2AwyUDAxw>
    <xmx:U-urauxFQ81M--SRxsNC_xi5SQtbBgWqOchiaClWV8zI6zZIAhRyH8Xp>
Feedback-ID: i67c64855:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 26AE5B6006E; Thu, 17 Sep 2026 09:29:55 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ASiE5xFyi4k7
Date: Thu, 17 Sep 2026 09:29:33 -0400
From: "Anna Schumaker" <anna@nowheycreamery.com>
To: "marc eshel" <eshel.marc@gmail.com>,
 "Anna Schumaker" <anna.schumaker@oracle.com>,
 "Olga Kornievskaia" <aglo@umich.edu>,
 "Trond Myklebust" <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <ed2753a1-bf56-42f2-b13f-0de2711496de@app.fastmail.com>
In-Reply-To: <ff747b30-2537-4ee0-b827-beb0b7c2b323@gmail.com>
References: <41ee5118-027b-4630-8f02-b3a67c61b328@gmail.com>
 <6880c031-3936-4ea1-86f2-5dc6050c9051@oracle.com>
 <ff747b30-2537-4ee0-b827-beb0b7c2b323@gmail.com>
Subject: Re: issues with Linux client pNFS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Marc,

On Wed, Sep 16, 2026, at 6:30 PM, marc eshel wrote:
> Hi,
>
> I was just trying pNFS recall any but it look like the NFS client 
> received but ignored the call, is that expected ?
>
> [287100.214040] NFS: RECALL_ANY callback request from 10.11.96.99
> [287100.214073] nfs4_callback_recallany: exit with status = 0

Trond just had a patch the other day to fix an issue with CB_RECALL_ANY.
Any chance you're able to test it to see if it fixes your issue?

https://lore.kernel.org/linux-nfs/115e4102b1bab159c25e8e903070b55cc4de77eb.1789148631.git.trond.myklebust@hammerspace.com/

Thanks,
Anna
>
> Thanks, Marc.
>
> On 9/16/24 1:33 PM, Anna Schumaker wrote:
>> Hi Marc,
>>
>> On 9/16/24 4:27 PM, marc eshel wrote:
>>> Hi,
>>>
>>> Who is the current maintainer of the Linux NFS client?
>> That would be me and Trond.
>>
>>> I have an issue with the way pNFS client is distributing the reads among the DSs and I can provide the traces if anyone cares.
>> What is the problem? And sure, send along the traces! I'll try to take a look as soon as I can.
>>
>> Anna
>>
>>> Thanks, Marc.
>>>
