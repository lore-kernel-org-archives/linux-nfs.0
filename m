Received: from mail-ej2-f12.google.com (mail-ej2-f12.google.com [74.125.228.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E1F603F329E
	for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 11:43:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.140
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789818229; cv=pass; b=inXwEYHvXyPAr6B6aIRUDkU8qwqLeOUwSLOOkUjemQc103PUy1nGGmC0kVmsJAnpFMEPnc62CvicWU3ruw5QlrPgQ6aayVfpgCiuf+XQW6GB08ZteRXGVv2bJd5wxnMXbyfVkAoIBgdf6KPluMOJyPyXeAo4sFIcKHZswmnKfvs=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789818229; c=relaxed/simple;
	bh=EzTs7PJQF5HsvNigfKwCL5CmMcq0Ggx1EHRO4qh5jhY=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=PGe1lFYi99p8aoVyyuiiVoMw1NaGIV/7IILwG42JyHc8Gzqk+Pr89VFfcFfTew4HnW2/JmdfGE80kOwMAoqRuMFFCQwj9l3SJniY/9CpoR9ALDUzlbdRP+jLNmyeTdfKdWzAGzsv8F+1DCKoVkJkgay6SZo3gGjeCxPDFjfNQcQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TKN30/vM; arc=pass smtp.client-ip=74.125.228.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TKN30/vM"
Received: by mail-ej2-f12.google.com with SMTP id a640c23a62f3a-c254f55eff0so233876166b.0
        for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 04:43:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789818226; cv=none;
        d=google.com; s=arc-20260327;
        b=NbfUI1C/OjBepKEO6G58biKD5+sRJiGZg/qufFiA/1/+tFHF9VFNTQvfIfPIXr5Yr8
         F8sbyjjmDIbFhyr0ly18iB153VMHmXzmQhQ9wWkgoginpZCpSybhs1iVfZY9hiVlFpoI
         rsLkm1Qia5NhadmWj8c2SSYi5aqwfMdUViTsFs3/U7bUX1+M9sg28BOET2oT8e8j8um5
         AAJwi/ni9qCKb4Db46Rcps6qvGglyrvQad50lFKxZcsGWcC482NGtvGAweqPCymzy8fs
         KAYsd3QlbnZ1EzgZaW4BuRzD5z0yU1ZxUAUTomx6uxsI34L/m24HETFJpp9WWfuep568
         vmWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=EzTs7PJQF5HsvNigfKwCL5CmMcq0Ggx1EHRO4qh5jhY=;
        fh=A5XrQb8nrWFDht6aaFFkeJKx7DwlCTzUgCbXEliKk3E=;
        b=kj24qkS2EjiVe0F7qJPKM9GXrmANCeLdmuFQwIuEp0g/PSWTU7SeRx/08kmPiNsZbz
         +a4Btt4mG0Ao4+nWwOgOx8D9PJMp18L27Ykkj0O8DmJ0/LvTeywg0BZScTACCrx9bqqI
         1u/tYS/Wb8AvIaC9ecM8VWm2GfmQZicDe9dnTAezrVDocsmdel1XK9tA4x5nk9H5JitH
         HLQujF44uf07LfRqxBMbb6TAv1+kbPQzTLRBZp5w+lIFa5chZKshHwPDK593O/7eLucR
         1h0UheXOT/aOF2o8OzEeGKML6N9SFweAMvPV8v1WBaPCqihkf8M/zpZ2q/0zPURVlBjV
         cJ2g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789818226; x=1790423026; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EzTs7PJQF5HsvNigfKwCL5CmMcq0Ggx1EHRO4qh5jhY=;
        b=TKN30/vM5seeKuOdY4Za2MsHrv1HW2vNm/GYPJwfl5sFmZmgl6fzTeqmgO+U7ym/TF
         0Z6/kmRD+pAgUKBwWCtj+7owxaW/bmjCe1BbQquAYBuaH2mKup2Id4TGul6XDmlgR/Or
         3kNFHwLoT2ga5ta015BEipekH4nw5H4LJ9YwGaWXxrJYs00uYlljQtNp/IR1nJtYseha
         ycMTJYfO4/PFmsZoUH/cVKAhIUFCnvQBf5DkMdmvfZ3gIVOusJn7jx0LyYihHxCkdU27
         vc+jT7637fvI8Fj3N956nuYMRE/dBn5psPfACfGa9CHlGlg0NrD6MM69rFny0Szm1kQQ
         gYiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789818226; x=1790423026;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EzTs7PJQF5HsvNigfKwCL5CmMcq0Ggx1EHRO4qh5jhY=;
        b=IqpnfvsZ+LN68q/VLJy4c0JHKNpkoofamM2woxcznIMv00/6TQQISVbK6g4TIYPKvK
         dBtOiezYK/gGHls/zDmZy/cOmi0A1zPkaIKsS4BhzjsqwXnPmboGjfpKoUxrkSKkA8wf
         Ptbv8yEw90O3GMURc+MnSto3zk9wjhZUonYGPEjF9FszzobkPjq09440W4zp3NY/HMXC
         /nJw//zkD6mACHzjhDLWnuiOOEhewGH8w7EnvB8SaHLhpHVaNjbBoIQVfpilOxGEGVfd
         nqGV7OXpE6WZ949wzrSxPXgmQnPxHXTYkhkxitB12gY4XPh761I8FSjIJkIK4tkn3/Gv
         xjUg==
X-Forwarded-Encrypted: i=1; AKwUvByxPmk5fcSZ8HNaIFicnblvpS4BYtvMwOsqHnDaUQ2cDfXFUTEZ5MV6e16CC6vZbOFV+SWkax1LY5I=@vger.kernel.org
X-Gm-Message-State: AFuF++lDg9bpzK/gGQzsFX/+SiE02aXc8N6yTywGChgZ+E7lnLU2Bo07
	IakRbnjmwc6wKt8BCTS8gJh8PJeMDZ1IKb4UHXDvUzUaUi9hxi0dQjtWB/O0zkiFi5Hr9P8krGL
	tySHVMV8WiU9ooNZLWcOBuKDiiPiNoKBQMwtR8nk=
X-Gm-Gg: AYBFou0PVFzglFuEQZUlOeqYhwTIqzuY16u7vlWrAZH/IgBhl/ZqqCxZCc6Tlc1PaBl
	KQijtdJYQ54fnEjIpjs0XmWdmLE6w16+juSn4a1YeMbUjZPArLhV3JtEYaOJKlksBko7O8sGTPk
	1nf7r0rDuMhW+lYSMaBZk0YdH7Rdu+bLwgSf1bT2Wmo9HZvzKDFObZucb8vL4IWTuXsFWXOISWq
	RBCYSGTDmhrOAc+y9fLEK6ihmqR1jZDQS43/GDvQPcmMEl7HoYhyFE+tKY/MOyCLtpw79RlaYD0
	a4Sho75YRzm3TPBm84vVT+r4US+XWHGDZB6MWL8nSWDomOuwfYAbMRg=
X-Received: by 2002:a17:907:9286:b0:c1c:4e36:eec6 with SMTP id
 a640c23a62f3a-c2a1569d640mr499788566b.18.1789818226057; Sat, 19 Sep 2026
 04:43:46 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
 <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com>
In-Reply-To: <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com>
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Sat, 19 Sep 2026 13:43:08 +0200
X-Gm-Features: AcwNN1VYfpmeIwPd3EYisRA3nCs_DiwMOBLwB8FhPp8FYdJdLPTnY-0cBj1zgO8
Message-ID: <CAPJSo4XZcAvXE6gP1vXFSfGZnjiQ8BwgeqO02obd_nWc-boR_Q@mail.gmail.com>
Subject: Re: [Ms-nfs41-client-devel] Need NFSv4.1 "WANT_DELEGATION" op ...
To: "ms-nfs41-client-devel@lists.sourceforge.net" <ms-nfs41-client-devel@lists.sourceforge.net>, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Thu, 17 Sept 2026 at 15:50, Chuck Lever via Ms-nfs41-client-devel
<ms-nfs41-client-devel@lists.sourceforge.net> wrote:
> The RFC treats the absence of WANT_DELEGATION as a normal case
> with a fallback. Section 10.2.1 notes that "since the server is
> not required to support this operation," a client reclaiming a
> delegation with no associated open can instead use a dummy OPEN
> with CLAIM_PREVIOUS and then CLOSE it (rfc8881.txt:9596).

I had to refer to a colleague for this one. The answer:
"... CLAIM_PREVIOUS is only valid during reclaim. Outside the server's
grace/recovery period, a compliant server must reject it. ..."

I think that is why WANT_DELEGATION was added to RFC 5661

Lionel
