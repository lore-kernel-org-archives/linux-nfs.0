Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 65EB712AAF1
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 00:45:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790729103; cv=none; b=cocTu+pdawf9DWm32hwapjDg96d6TEl0wi/sYnLM8vErZFgMY72bZ/S0VDl36OtppvSRCbDixHMKtp/5qI0nu256PpTqI9gXKGO6xmYe3vpp8VCa1OTRJVIfz9HXjtAQ5FcV54S02yRC5mKu+O5CuD7siiTVHEsR4LybqUuNvPA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790729103; c=relaxed/simple;
	bh=NwxWRVm4HYapQfbP+Jho/CSH+0d2BkunfmOIaGUhS10=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Zx4BxVhR2hrVcWjnV6ih+T3fW+vK5+EuYfsoT987qkXqtdZl9h8gWtOUFU3Biv3Bsh2h2dOCpywaNFz9OZHUhBLIhCvmKMd0Fx0opJMPUFVwW0/jQRstF4K6UppuCMFqxNSbFo6ic72XKpE1RDYGSj8z6WD+QzGy6xZXRuzzquk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DNcAU9tq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DNcAU9tq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1D48D1F000FF;
	Wed, 30 Sep 2026 00:45:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790729102;
	bh=FUdrDobgJxRYNIGkHbDh40SXX35HSW7fk/v7V3c+vh8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=DNcAU9tqlp8TgVrM+IGDNhHHqGv8isxHyI0yWodG6K2WzIl2o8zhrMPCCm6o2iAAM
	 xhtQy/kJJtcX6kcey24Yw0QjcJw3kNVrGy7IK5iRa5oAhGavLRYBRCtDOpIVI8ASBf
	 ykQgPPzd3/otUm6V3boNwMJCwzFTIiFCoJPi3LWhLKGrfgAg+0k7YOBIxwMFWJ07v2
	 CzhCXea1xQ2RQWhEXlURfySrbwkc0IIEg18e18Ty6MWxT/df6QoRnJ8sT8bMrcfP8o
	 45SdCo/StRONwNNTDQbUQxna+5Yw5Tf0Ho0CQx+SpPCreAiUd3sTqY4WiR+E1FcrbO
	 o6KEHNpPUcBEw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 332FDF40066;
	Tue, 29 Sep 2026 20:45:01 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 29 Sep 2026 20:45:01 -0400
X-ME-Sender: <xms:jVu8arMzR8kiQ2zKXV8hpWGsmjfg9oDWRzWn-qwbSQc6sk8yPOyX6g>
    <xme:jVu8agypVmqtthc5N2fBrXqlDAhu4hEPZnYVSc-q9YrDNuNZgijmGucjXDhE6DSfv
    Tz4rK-dokV1_XJj4TuTIlI2ActP9qVnOuonrEJjsGskySJoeKiRrNk>
X-ME-Proxy-Cause: dmFkZTGMS79XnDhQWXzvHvd8SEYM9LRqtp5ym/MN0OUFpV7nvqpSwoy+2WQ96H3t3BmGQx
    j8dfxfajGJENUvyWKlFqjyB2UBCiOXCNPyroPGpAvvjaCDjV+Na3RDyK/5+eE68sdUAVyM
    COuGy2rcGVupI5UhdEXeIsDZ3poCelYIZnF6lF9IkmwmDBy53bARfRCkUFQ2/HNPtd75vP
    h9acqYI59iRY8K2PToudED7iMKyIkaAssAVzHsDxcWCSz6OVJ+Z33deZUKPRqDXfywExDw
    ECqeYBAb5CmupnjEsNsls0wTwx4qRbwzQPvK2nccX3oT2NIPrHZne7ox7QIgOtMynxEKF+
    I+AiZOF5KBkwW+plyZbaBfJTdmNYUg5lVDLztyEyjn88YOFhJycIyx/BPBgePqJfqXQvF3
    nAju2wRywdf5frALdgZ66pJ8GZLDZTU53LnflxRjkjAfuy4K2uBrD2a/mizppBHuGwvVKy
    PboVqg+zxmS7xzxQEn4Ag8a3RIIPGUB72bh7JyG2I8nw/J4XtxT31IwwRQSiLB/itfvgwj
    0jtcxO0NedDl6dBJDdpPRbXEG+K4EZ2z+MnwLUiVuGBPAwV1MASnYF8n3xcSYlW3Rh98NR
    aSvrENDk2owmBnBhgWgn6We99Ixw1os0pw8IauIgYj4aWizRZlS5sGOzUTEQ
X-ME-Proxy: <xmx:jVu8akiaBbasv4zJZNdoO4ftid7oPhWxYFGriMRQJIkY5duuEc2s3w>
    <xmx:jVu8anB-SKjkSSHVmyPV60ytCDjTzoKnpbHT3UtoOev028Q_uLhg6w>
    <xmx:jVu8aisE9Z9tjccyjyZ3SnoW9aZX25pcsDwVlgWkTM06CzR1BSfLMQ>
    <xmx:jVu8ajdmbT-j_Ad8azTFc20BuBp7GbpSckX_9jN8_7dCQr48qjn4Yg>
    <xmx:jVu8av8_4bo6JdFjkBEtvB-UdFHnO3_jqmsbXqZo4EWDXWejZxUe0W89>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E2079780070; Tue, 29 Sep 2026 20:45:00 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ANPB6m7Eugcc
Date: Tue, 29 Sep 2026 17:44:40 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Jinpyo Lee" <bint4b13@gmail.com>
Cc: linux-nfs@vger.kernel.org, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 bobtobabz@gmail.com
Message-Id: <438f1a46-ed0f-470c-ab1a-347941e07570@slotpi15m67>
In-Reply-To: <20260928083739.643010-1-bint4b13@gmail.com>
References: <20260928083739.643010-1-bint4b13@gmail.com>
Subject: Re: [PATCH v2] nfsd: drain pNFS fence work during state teardown
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I'm passing along a sashiko review finding here. It was confirmed
with Claude Fable 5.

----

commit ba79c2d330cd7f4c60c83de92ba0d54184b97c08
Author: Jinpyo Lee <bint4b13@gmail.com>

nfsd: drain pNFS fence work during state teardown

Stop the layout fence worker from being scheduled once teardown starts,
and synchronously cancel or drain it before the layout's client
association is released, so the worker cannot use a freed nfs4_client.

> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f487ef0916d9..3d5792b6e997 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c

> @@ -5870,6 +5871,7 @@ static void nfsd4_drop_revoked_stid(struct nfs4_stid *s)
>  		ls = layoutstateid(s);
>  		list_del_init(&ls->ls_perclnt);
>  		spin_unlock(&cl->cl_lock);
> +		nfsd4_stop_layout_fence(ls);
>  		nfs4_put_stid(s);
>  		break;

Which reference keeps ls alive across nfsd4_stop_layout_fence() here?
nfsd4_free_stateid() reaches this case through find_stateid_locked(),
which takes no reference of its own, and the only status it tests first
is SC_STATUS_CLOSED, which the layout case never sets. So two
FREE_STATEID operations for the same admin-revoked layout stateid can
both arrive here, and the nfs4_put_stid() below drops the same hash
reference in each. nfsd40_drop_revoked_stid() has the same shape.

Before this patch that race is a double put. With ls_fence_mutex in
front of the put, the second caller sleeps in mutex_lock() until the
first caller's nfs4_put_stid() frees the stateid, then wakes on the
freed ls_fence_mutex and takes the freed ls_lock in
nfsd4_stop_layout_fence(). Can that be reached from two slots of the
same session?

The SC_TYPE_DELEG case of revoke_one_stid() takes an extra reference to
guard against a concurrent FREE_STATEID, and the delegation recall path
sets SC_STATUS_CLOSED under cl_lock for the same reason. Would setting
SC_STATUS_CLOSED under cl_lock in this case, before the unlock, close
the window? Since the race predates this patch, that guard probably
wants its own patch ahead of this one, with its own Fixes: tag.

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
