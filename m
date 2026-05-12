Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AA74399CE4
	for <linux-nfs@vger.kernel.org>; Tue, 12 May 2026 13:50:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778593824; cv=none; b=cc5BvKH4+Q8hVhKhPBluMy2oKsnZNcv0Oea4xGuDPVACaS9tf4YsA5ASnX5xKeabw33mPb5FQMqCfCLqVEEru11G00mtK8q2X1IoJgdHcshNCXuJkf1VdqRRC1QPSnXLlcGQtSizapLk6LKXj/l6J0LRRVG4YK/3HXzprgIRZhw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778593824; c=relaxed/simple;
	bh=EHQHXKHIqBCGklg2Q7oW2A4zipGb7r+0GrDL/d9F1f4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=TSA3L4H9THFj4R2sm5Cteb6dBFJz0Lj3x1zqsja6qy1cyliGA6XntwHk2NLtTdD5tE0NFFRww+OUM1oJNtTeF0fzNC22UkZ6+gm0BBdZyRw+Ed3lpQhzvF80+UurOZ19aGEb9M82dmrk2qhSN/andnOHZKU1Id7ac5NDk440rps=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gPIN0h6/; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gPIN0h6/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96ABAC4AF09;
	Tue, 12 May 2026 13:50:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1778593824;
	bh=EHQHXKHIqBCGklg2Q7oW2A4zipGb7r+0GrDL/d9F1f4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=gPIN0h6/8v6mhrbu3FuNrbJ82iStsgXt38BEEjdPZxlo5E9RZOVM8p8Jatkr/csRb
	 fyQff67rPDZO8fQhRPXOZXD0yAErBntO2YOKH4v0WJcm+7zZVoFkRnXhcLvMETk6eh
	 kqjsdNnUqdQncDjt/jZQFaj+BNJHUokbTP+gTK2DUSXJaL2RQ7eBKzIdPyVrYMzKyX
	 gmS8wAaSVPnO6yBsbKJzpa2LelQIiE3WJWxH1sBoIc6TFb9rq1xmDyBn7EMvCpvaBb
	 yDxU0mitFKlI5/YoOAFcDR56nOlb4nyWCvT/xehb9XwP+gpWtKvTg3gbO1ikvVNxor
	 1Oqx0x3ZuH2Ww==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id CB4A0F40082;
	Tue, 12 May 2026 09:50:22 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 12 May 2026 09:50:22 -0400
X-ME-Sender: <xms:HjADanCMCtk-6nEKES50OOVhODrchuYEOwCvv9SD1w2j0pvHpVlRyA>
    <xme:HjADaoU_eVZJX1yPAbMaSpC-okvPlMRfgy_ZymA1g8VLo7O0wPDkl4_IaHz0uL7uk
    vLnHBYpuNdmBvTbd9groFTYoggulTxTEsrX5MSK-IbPqnqRn7ydNQq1>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdduvdduleeiucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpeefgeehvdekhfegheduffeuvedttdffudelgfehhfejgfegtddtvddtudetfeffieen
    ucffohhmrghinhepkhgvrhhnvghlrdhorhhgpdhkohdrihhsnecuvehluhhsthgvrhfuih
    iivgeptdenucfrrghrrghmpehmrghilhhfrhhomheptghhuhgtkhhlvghvvghrodhmvghs
    mhhtphgruhhthhhpvghrshhonhgrlhhithihqdduieefgeelleelheelqdefvdelkeegge
    dvfedqtggvlheppehkvghrnhgvlhdrohhrghesfhgrshhtmhgrihhlrdgtohhmpdhnsggp
    rhgtphhtthhopedufedpmhhouggvpehsmhhtphhouhhtpdhrtghpthhtohepnhgvihhlse
    gsrhhofihnrdhnrghmvgdprhgtphhtthhopegthhgvnhhgiihhihhhrghoudeshhhurgif
    vghirdgtohhmpdhrtghpthhtoheplhhilhhinhhgfhgvnhhgfeeshhhurgifvghirdgtoh
    hmpdhrtghpthhtohephigrnhhgvghrkhhunheshhhurgifvghirdgtohhmpdhrtghpthht
    ohephihirdiihhgrnhhgsehhuhgrfigvihdrtghomhdprhgtphhtthhopeihrghnghgvrh
    hkuhhnsehhuhgrfigvihgtlhhouhgurdgtohhmpdhrtghpthhtohepjhhlrgihthhonhes
    khgvrhhnvghlrdhorhhgpdhrtghpthhtohepmhhishgrnhhjuhhmsehlihhnuhigrdhisg
    hmrdgtohhmpdhrtghpthhtohepuggrihdrnhhgohesohhrrggtlhgvrdgtohhm
X-ME-Proxy: <xmx:HjADan2JAoQW3LkKfHxIQTE76kuzguAaW18WEDsbfl4VZFTqJZGwSw>
    <xmx:HjADaiwkga8UFtFVWUEunpTREOLZM-wpJbc-czJ_1RMYYlkRtF--Qg>
    <xmx:HjADarzR-br9pzmWyhC_VcT2bdkiDK0I-KYqTpIkEs6pdmI2ZBX2wQ>
    <xmx:HjADam8o4w0yU-kqFfzbu23VxsnY7rPvwEESxN7ItD7gyXzP4gpWwQ>
    <xmx:HjADat8-10-wO6feg5ReJ0bMFIlqTrlEG6tkVK6npLBv69RvkIhUqjd0>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A6350780076; Tue, 12 May 2026 09:50:22 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Am3b19H1jwY7
Date: Tue, 12 May 2026 09:48:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: yangerkun <yangerkun@huawei.com>, "Chuck Lever" <chuck.lever@oracle.com>,
 "Misbah Anjum N" <misanjum@linux.ibm.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, yi.zhang@huawei.com,
 "Zhihao Cheng" <chengzhihao1@huawei.com>,
 "Li Lingfeng" <lilingfeng3@huawei.com>, yangerkun@huaweicloud.com
Message-Id: <0ce8ae76-da17-4b25-b1f8-6fa955654a57@app.fastmail.com>
In-Reply-To: <20260512023322.2828939-1-yangerkun@huawei.com>
References: <20260512023322.2828939-1-yangerkun@huawei.com>
Subject: Re: [PATCH] Revert "NFSD: Defer sub-object cleanup in export put callbacks"
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Mon, May 11, 2026, at 10:33 PM, Yang Erkun wrote:
> This reverts commit 48db892356d6cb80f6942885545de4a6dd8d2a29.
>
> Commit 48db892356d6 ("NFSD: Defer sub-object cleanup in export put
> callbacks") describes an issue where calling svc_export_put, path_put,
> and auth_domain_put directly can cause use-after-free (UAF) errors when
> accessing ex_path or ex_client->name. However, after discussion in [1],
> it is clear that commit e7fcf179b82d ("NFSD: Hold net reference for the
> lifetime of /proc/fs/nfs/exports fd") actually resolves this problem.
>
> Additionally, commit 48db892356d6 ("NFSD: Defer sub-object cleanup in
> export put callbacks") introduces a regression that was already fixed by
> commit 69d803c40ede ("nfsd: Revert "nfsd: release svc_expkey/svc_export
> with rcu_work""). Therefore, reverting commit 48db892356d6 ("NFSD: Defer
> sub-object cleanup in export put callbacks") is necessary to fix this
> regression.
>
> Link: 
> https://lore.kernel.org/all/10019b42-4589-4f9f-8d5b-d8197db1ce3c@huawei.com/ 
> [1]
> Fixes: 48db892356d6 ("NFSD: Defer sub-object cleanup in export put 
> callbacks")
> Signed-off-by: Yang Erkun <yangerkun@huawei.com>
> ---
>  fs/nfsd/export.c | 63 +++++++-----------------------------------------
>  fs/nfsd/export.h |  7 ++----
>  fs/nfsd/nfsctl.c |  8 +-----
>  3 files changed, 12 insertions(+), 66 deletions(-)
>
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 665153f1720e..0baa58d1dbfc 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -36,30 +36,19 @@
>   * second map contains a reference to the entry in the first map.
>   */
> 
> -static struct workqueue_struct *nfsd_export_wq;
> -

Hi Erkun -

This patch doesn't apply to the nfsd-testing branch. What's more,
the patch series already in flight removes nfsd_export_wq:

https://lore.kernel.org/linux-nfs/98268bb4-2e97-4728-96a6-37b2a4a3ae5d@app.fastmail.com/T/#t

That patch series replaces the nfsd_export_wq with a WQ that
is managed in sunrpc.ko. Is that incorrect?


-- 
Chuck Lever
