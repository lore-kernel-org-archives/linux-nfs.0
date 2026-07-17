Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4572C281525
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280616; cv=none; b=G9WrFzL3oEWYnEj/gHkTbVcGWPOQBh+KDwEKzAUQPCYJVgoHk54qGzcfGJhgiUaW09tkk/9td+KbLerJBFfxjPVuiogIxpf/2SLvYsMGlcRzWfYq6tEPxlVesyJaR3FeBKEs43/ECMXADh4y8J/8kSTTbmZIgdu6DDJwKlTEvnA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280616; c=relaxed/simple;
	bh=7n4DP7DI5b4kFvYqYHiHZdrAwbM6GflBKx8uGq1m3aE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=eAvVHFWZtis1Eq2hpxw5Hc6RO6crq3VZE1qEuREveSCLhO6HlcF7K4kSUtNPQzQBR2t5aHnxG5fE6h7UG7QXsBcDbgoysK+HgGxy5Ix6cdeaW08ToXvJ01iQS8wULGqE31H3cfdNs1K8ZjWLCDeRGkMz1UBLGE4oL1DK0udL6RY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=NVNxNKcI; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=A66L1+TB; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="NVNxNKcI";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="A66L1+TB"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 4D61D1400075;
	Fri, 17 Jul 2026 05:30:13 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 17 Jul 2026 05:30:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm2; t=1784280613; x=1784367013; bh=LcrNSfrp1D
	X2SQuSJk3UAda3gw4qGGqMgr0bSMkIj0o=; b=NVNxNKcIespaC1l2UMTZLMV2FX
	d4vTk+cNZkYsTf35whJJFmogBM9YYaXtkBvZ0Uo1feBuaa/H/yovKtppqXu6hLe7
	Un1V83sxVX+DCNIcrOYroGw/Df2bxXXnaUynplweQdu85P2XhQwQYtRIuDWp+bYh
	UpnonkyHHH7CyjZQzlWVf7Wlr2sPPViS+K8Z7TNbwYNX18EnOzLyIPurYiEgZDgU
	3ZLgCxV8J8gagOMoCI+Gvlr8+an5KKJmeTotsy5X4dWaUMEFK9gXhtBxQcTw79Xx
	cfrF+r1fGE4Lh7YaLxiEo+BSMQpEQByZZ3Dw1mlO64rleVxQvqK/A52oz78A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; t=1784280613; x=1784367013; bh=LcrNSfrp1DX2SQuSJk3UAda3gw4q
	GGqMgr0bSMkIj0o=; b=A66L1+TBegnDJvoDozshMq63TDXToXGgpG2veya3I4ds
	54FjyEgE99OusLQd11jn4DX2sKtI75yhLP1l9zCwXavxITpuh1Y1jX/Kj7r5oGuY
	59ztplVzyLzyqKZHi0WYZ2VQaieEA9quDQkiGLRtCSF6tf8D4HddH+hIRUpu4cf0
	JWuLsenfAz3vUDrPvBSK5EVbGiqxEZlzbv+SoaTKfNxJ1ck/OygJGC1u9YPqayCs
	FwpiysjFfMiRyw2UMbe37yP6JMxQck5d8WC1ZKHeQJTltLUBEmYLg57a/D/WWx1S
	3vBUKDQ+YMIPL5REv1scrIPeofHmWWpZFxX6uoe7Ng==
X-ME-Sender: <xms:JfZZahApgtKetpRWx38zWVb2RECZltKRDOSa3eKkSD8w7KfS8R84Tw>
    <xme:JfZZajMdgUT6r8hBgxgch9CQVw3pmWqPvVxsoIwiFuomdoBu2NODkbSzCvhHYc7uc
    N12sVi7db-fqxufw7U9OWh2H80aCC3OmDeR4_hMB_11GSHa>
X-ME-Received: <xmr:JfZZamab_JjgktNMk0vCiY4607PioQK960LqnenUnrW6qWVOxBfYcvisXyb9q8jBn-FykbqA9tDzVuo6GksleVJ7Fu0d-Dg>
X-ME-Proxy-Cause: dmFkZTETdGQ2mJLkYd0uheRt7WGfgNJSg2UQkTZsfWwFLWNJUWbVuNl3R71rc3egm4JQSX
    +igD3/b98if5q43xdcjokkSXnYo7jPBAz95HYPsjM0JIqCKm+W2CULS1tpO9iBpXFR7n6T
    NleoOz2MPRO4EjHjPq7g9L4sla6dudOd62mkiVDdCHvPQeAoTNjczKrINhb+MKoxyGwsaL
    fa1zbv5Q/UFVgp+CO2tzZEPpzwPCDY3Rol9dJF4bKIJEEVW+0ASY64LjMLC3Hyv9KjsmvH
    TaIIiSyJbZB/UGKd3YZyjKOyOiKQ/zakIap8FY/+LeDR+l8jpQLGzwjhitell4KURYHteJ
    SOQhV7CZpikQU/dA0CQCo1gTTLtYSwyhZRVJJSBunMejlp4BRvsdEAlh6tHQoKQPGxYvnv
    YCvr3CktiIYYwQcKI4eCrBqnyV+pJl+PY719OjV+St/37HgOzdwa91jGm1aDE3YtiQaq3o
    7az+8gLwC6eMXm1gYFcimo3TBHU73CyyRe8OWXFGbPij+ubitwjXk8Xpw0V3WyjfffWBVa
    GxvZF0YziwdQNa81qvgRUNCL5CW/x8GI6iVO/KHZ+ICSgjJ5riWqtr/TrHtPCOB6S/xuC0
    xyMHmvnflVatyHCWtEATvUr4lwPgv9q/pKmUYvwBDtqSVTnvXPHVb8tqODVQ
X-ME-Proxy: <xmx:JfZZais-IbFJ2v9Y6AlozxOvz64xPs33PmpxZzO0quL71xKa7WpJQA>
    <xmx:JfZZaoPpG0n2TR7SmMkX8qDvqD7sJPaACG7YTng71l5Pjs7wcV3cBA>
    <xmx:JfZZap49oqKt1wKs9ACMJHywT1y9JmcR-bQOcRb7e6RB2A0fEhlcfw>
    <xmx:JfZZauSmIOIa9IkmhzQQEpvreGWkfcULMxeSBcHSqq7A5dTvs8FERw>
    <xmx:JfZZaijuwcfEH5VnFOnBO7prWeY0s5D-bJcbW8PWTZghU9RnyOXN43mT>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:10 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 00/18] nfsd: refactor nfs4_create_file()
Date: Fri, 17 Jul 2026 19:27:48 +1000
Message-ID: <20260717093001.1972119-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

For for another version so soon - I hadn't noticed Jeff's LLM results.
Most of the issue raised there were already addressed I think, but the
using  nfserr_noent instead of NFSERR_NOENT, and adding a condition on
the call to mnt_want_write() in the final patch were still needed.

Thanks,
NeilBrown


 [PATCH v5 01/18] nfsd: honour client-provided attributes for
 [PATCH v5 02/18] nfsd: move check_nfsd_access() call into
 [PATCH v5 03/18] nfsd: correctly handle CREATE of mounted-on files
 [PATCH v5 04/18] nfsd: replace fh_fill_both_attrs() with
 [PATCH v5 05/18] nfsd: move fh_want_write() after preamble in
 [PATCH v5 06/18] nfsd: move more nfs-specific code into preamble of
 [PATCH v5 07/18] nfsd: remove subtlety from nfsd4_create_file()
 [PATCH v5 08/18] nfsd: in nfsd4_create_file() let VFS report if file
 [PATCH v5 09/18] nfsd: nfsd4_create_file(): Move NFSD_MAY_CREATE
 [PATCH v5 10/18] nfsd: fh_want_write) failure need not be immediately
 [PATCH v5 11/18] nfsd: (almost) always open file in
 [PATCH v5 12/18] nfsd: reduce range of directory lock in
 [PATCH v5 13/18] nfsd: open-code nfsd4_vfs_create() into
 [PATCH v5 14/18] nfsd: move some code out of the
 [PATCH v5 15/18] nfsd: reduce want-write range in nfsd4_create_file()
 [PATCH v5 16/18] nfsd: move v0 checking out of nfsd_check_obj_isreg()
 [PATCH v5 17/18] nfsd: separate out VFS-specific code from
 [PATCH v5 18/18] nfsd: use do_lookup_open() for non-creating open
