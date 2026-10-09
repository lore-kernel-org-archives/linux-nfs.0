Received: from eu-smtp-delivery-195.mimecast.com (eu-smtp-delivery-195.mimecast.com [185.58.86.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 945453B0AE8
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 12:24:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.58.86.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791548692; cv=none; b=tVgtzxOTWRuTg3DpyJQQBIVEjB9cxUBlQclKU+nupvAaZX5j3bb2PG9DlUyjJjSFYaXPbZb2leJxjDBhVPG5tv5tTPlPrgOplguE0cSECWV/qyKRQFjchmlQyCgo1I2MJGoXjPPAvMRQ+YrR9oqeHAvLUOMvqhKC2k9Je67MlE4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791548692; c=relaxed/simple;
	bh=ORcXI+VqyjR0H2YjNg9Ny0gA/aftptjZxUvGicN04fM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Gp95CA2ZClslSzz/2TgMNJQQBZIB30B0pe5guPwxKqeikCYrBs4R7wWLSUhMIHKucEo2YDsTxNmm0ZAzRbBNd1IM57O4edvFuIkIda+9phYlEdnQcldB739ODSuT1xZo0gjfKheLEpW8uxnjiWHvSoVI6b7iZnADvaowx4bnz5k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com; spf=pass smtp.mailfrom=gsacapital.com; dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b=d2AWteqj; arc=none smtp.client-ip=185.58.86.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b="d2AWteqj"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gsacapital.com;
	s=mimecast20170115; t=1791548682;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ORcXI+VqyjR0H2YjNg9Ny0gA/aftptjZxUvGicN04fM=;
	b=d2AWteqjPsNmJyj9GT1LAFn0z2RsyNUqXEKyolthyMmu/iKhZaVQhKk1qflEfs81BgO5kJ
	WLj6QRt9vBIWGfsNXcJT3G0oJ5UKpe5DQ19GNccddc6gx+ELwZgsdIUC6qu5+2IzMJcZuc
	66Bj22g7XW0wiNlsT7Y4zxhfQFi1KUY=
Received: from mailrelay.gsacapital.com (185.137.2.10 [185.137.2.10]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id uk-mta-109-WwqAU612PKWoHdX26OvIQQ-1; Fri,
 9 Oct 2026 12:24:40 +0000
X-MC-Unique: WwqAU612PKWoHdX26OvIQQ-1
X-Mimecast-MFC-AGG-ID: WwqAU612PKWoHdX26OvIQQ_1791548680
From: Rushil Patel <rushil.patel@gsacapital.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Trond Myklebust <trondmy@kernel.org>,
	Valentino Aguiar <valentino.aguiar@gsacapital.com>,
	rushil.patel@gsacapital.com
Subject: Re: [RFC PATCH] NFSv4.1: don't stall installing an OPEN stateid after a failed CLOSE
Date: Fri,  9 Oct 2026 13:24:39 +0100
Message-ID: <20261009122439.2037722-1-rushil.patel@gsacapital.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <71a8991f-3c52-4483-be26-e4083cb8c628@app.fastmail.com>
References: <20261008160253.1702053-1-rushil.patel@gsacapital.com> <3E653493-0BDC-487C-92ED-9647E5D8CDE0@hammerspace.com> <20261008191903.1770486-1-rushil.patel@gsacapital.com> <327DB787-70B2-45A4-B5FD-7F49531B317B@hammerspace.com> <71a8991f-3c52-4483-be26-e4083cb8c628@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: JxM3KIMNac-Qv4Dm7453c1hxmFEoTMbNSLtxLlLpaCE_1791548680
X-Mimecast-Originator: gsacapital.com
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

Hi Anna,

> I think working with Netapp to fix this issue with their server is probab=
ly
> the better path than trying to wallpaper over it with the client.

Makes sense, thanks to you and Ben for taking a look and for the guidance!
We'll pursue the server-side fix with NetApp.

Thanks,
Rushil

For details of how GSA uses your personal information, please see our Priva=
cy Notice here: https://www.gsacapital.com/privacy-notice=20

This email and any files transmitted with it contain confidential and propr=
ietary information and is solely for the use of the intended recipient.
If you are not the intended recipient please return the email to the sender=
 and delete it from your computer and you must not use, disclose, distribut=
e, copy, print or rely on this email or its contents.
This communication is for informational purposes only.
It is not intended as an offer or solicitation for the purchase or sale of =
any financial instrument or as an official confirmation of any transaction.
Any comments or statements made herein do not necessarily reflect those of =
GSA Capital.
GSA Capital Partners LLP is authorised and regulated by the Financial Condu=
ct Authority and is registered in England and Wales at Stratton House, 5 St=
ratton Street, London W1J 8LA, number OC309261.
GSA Capital Services Limited is registered in England and Wales at the same=
 address, number 5320529.

