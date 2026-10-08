Received: from eu-smtp-delivery-195.mimecast.com (eu-smtp-delivery-195.mimecast.com [185.58.85.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B3F33A5431
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 19:20:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.58.85.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791487219; cv=none; b=UZqDcr3k9TD9etMt5kdeap1/d2OhjhNKX8RJ67Dn4qxVghtfHf513agDkQUthfWcgcnPWA6I1mRP99ksXbP1hT0guK/CF+IAsz/n9n7zYsemdnTwe9pFYbmjPNsvDqABO7qPxw/KjuQSy3AvbBAskAYdFtmECsVDit7eYXnWXuc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791487219; c=relaxed/simple;
	bh=j2UpXbP7ZSSlaC0yGlcNnPXgbmuGbWtp3+1IkMV3LtU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=o/7U7yzsxgzD5EybHV6PpTshQxBlYMoaclFrzirrlBEljI9WH4a1ZQn+XOQBKDLcKp2tnoullSj4ThZk6pDTSJbJfDHGIgOxDfb3V0Cvc+eBImoFIAEAEn8IFoW9t9t+giW1mGpaFn6e2bvFPdTm6oe8w75JQbui4Zwf5qLQxuI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com; spf=pass smtp.mailfrom=gsacapital.com; dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b=Gv3eUphZ; arc=none smtp.client-ip=185.58.85.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b="Gv3eUphZ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gsacapital.com;
	s=mimecast20170115; t=1791487215;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=j2UpXbP7ZSSlaC0yGlcNnPXgbmuGbWtp3+1IkMV3LtU=;
	b=Gv3eUphZiOpeVpuFcCx/BUHgyk0/nptd4FNVs1lwg8uqcBiaxq8UDCcziR4PSdEvLh8Vfa
	Ech+qywbwgVqSjPUibmGV+Nozwod8eS2sF3V+HIoluz57Szfqogg+QXzqdrf90woqn1rIW
	pmINhgA+ScnTLJ3P1ibwx/+yBxhorS4=
Received: from mailrelay.gsacapital.com (185.137.2.10 [185.137.2.10]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id uk-mta-330-ZiCEMHW6MiiKyrfwvWKzTw-1; Thu,
 08 Oct 2026 20:19:03 +0100
X-MC-Unique: ZiCEMHW6MiiKyrfwvWKzTw-1
X-Mimecast-MFC-AGG-ID: ZiCEMHW6MiiKyrfwvWKzTw_1791487143
From: Rushil Patel <rushil.patel@gsacapital.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Valentino Aguiar <valentino.aguiar@gsacapital.com>,
	rushil.patel@gsacapital.com
Subject: Re: [RFC PATCH] NFSv4.1: don't stall installing an OPEN stateid after a failed CLOSE
Date: Thu,  8 Oct 2026 20:19:03 +0100
Message-ID: <20261008191903.1770486-1-rushil.patel@gsacapital.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <3E653493-0BDC-487C-92ED-9647E5D8CDE0@hammerspace.com>
References: <20261008160253.1702053-1-rushil.patel@gsacapital.com> <3E653493-0BDC-487C-92ED-9647E5D8CDE0@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: _LyPOMuhJYS-CA0PlBu90MboHUf-nOTFD7jmTiv_DNo_1791487143
X-Mimecast-Originator: gsacapital.com
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

Hi Ben,

> I think the server is broken here, and the client's wait is doing what
> it's supposed to do.

Agreed on the server being broken. We've since isolated this to ONTAP's
Concurrent Open Close path. Disabling COC removes the reproducer, and
re-enabling it restores the stalls with the client, kernel, mount and
workload unchanged. We also have both replies captured on the same
session, with matching filehandle and full stateid identity. We're taking
that to NetApp.

> The client already handles the compliant case: OLD_STATEID goes through
> nfs4_refresh_open_old_stateid(), waits for the OPEN's update, and then
> close_prepare sees the new opener and doesn't send anything. There's
> no 5 second stall.

Understood. I'm not arguing that the compliant case is mishandled, or
that the ordering guard should be removed.

The question I was trying to get at is whether we can handle this
particular server failure more gracefully. The locked client snapshots
show the failed CLOSE clearing OPEN while retaining A:n, then the
successful A:n+1 reply entering the update path with OPEN still clear.
It waits approximately five seconds inside the application's open().
Repeated instances stall the concurrent openers, so this is fairly
costly even though each captured wait is bounded.

With the cached state unchanged, the timeout path can install that same
successor. I appreciate that this doesn't establish general equivalence
when recovery, revocation or another update intervenes. The current
proposal's error scope and recovery-marker lifetime need justification,
and I'd be happy to narrow or change the approach.

Would you consider handling BAD_STATEID specifically in the full-CLOSE
error path, rather than adding an exception to the shared sequencing
predicate? Or is there a recovery dependency that makes the five-second
wait necessary even in this retained-cache/successful-successor case?

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

