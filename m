Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793743636;
	b=UNEhfS8zJKlrbcC26/BVA/z752LCVR6A1AMfmGrIHvUfksKBHAoLi8Q0pxwyMU1+Tvkp
	 cbZ7lieiubmgFA5Ji99qyY/nVzVTgdR9SbgGwMopwEOw0Vlq+ECOSbHSIDJx8+hfOlAde
	 ECUmmp90GAh/xjuUD1RaxL4STDdxs3njSmincCYZuRm/aR0Op3ylHgj4udjFFIsfWgjHx
	 l+4BAjapyeuCYCs6Smt9cMAkvm2kNPYWAr5uiH/WBYNDP6nwhfieZ97Mv2ql5Ks3NQx7/
	 jX8J5NJxXcDD2HD4W8uNXLlavHTzzbM9ZXafl9A2ZWQGsKS55+l/AQgmeBRRFhXx8Kg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793743636;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=968YowjBTk1iDJtq/i3DizyX/CDpSVhgwegFypfxBIk=;
	b=cS0xQszTsxh9hu4MlyZtgB+/+VVVku0fj54hkMHh58rCJ3ftOfS/ptPTzAMae2mlrni7
	 B4uJKmmglT6+yKgD447okHY95y4EP57MSA3RPYwjlRKpw8iMAksPrTHQ1bRPD8neGUxym
	 f9tLZ0H9+F1GrZxPN+PK+dYi4LW+2RV2SDdWRCVFKY623W+Lv/4nJ0IOV41OzCAuwud1G
	 gQj5f7V6Mahh22IWdp8AxgS0dDQYgSDCgp2ZUZRFBGIqaqBlw1Pny82FO3FYyh7n1Rhq9
	 7t8Q1A1L9NMKeaFUbl3pL2FCJ/nX+uJbthaD8k6LmdwwzsoeIZWAqhzM6rutmEysKww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AKD+23yk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6BCA606A329;
	Tue,  3 Nov 2026 22:07:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AKD+23yk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BA1071F0093A;
	Tue,  3 Nov 2026 22:07:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793743635;
	bh=968YowjBTk1iDJtq/i3DizyX/CDpSVhgwegFypfxBIk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=AKD+23ykJFDjUVSBW2uYSyiaWzmrR2nRA/HK2rro8M+UFbxj+n0WumcOsTC7WIuV5
	 JCPevoTLlE+3gKm+NUitl/+yVChuwUK7enAZN9QEWnxUZ9dk3I7Iz9hz7U72LnlMZT
	 UZuwbjjemxXsR2OGV9a+veMuIId9ULRGXHbWCoZzsoUItqyIQjyPZBt8RZrekkOqGY
	 LELErqFMeFmbjebmvWSs/jIjkJbmc6RD7+A2/EmIim8wBpMVK19xrbM0M1KG0YHrD7
	 /KqQfJzF0b2viNbBezkhBQZ7UHpBDj6NdyKNjzjhj28af6aeHCvDIICgyYg+rDOjhY
	 3xF/VAIpwBP6w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 13564F40066;
	Tue,  3 Nov 2026 17:07:14 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 03 Nov 2026 17:07:14 -0500
X-ME-Sender: <xms:ElvqasdYlED5KnO3zgNSjtTaETOYOK-YRPeG8mDf32ooHrHG_wAPVA>
    <xme:ElvqapBq7wtHDoXg5Vq2cGJAYzHSRY-LmIGjoD5YZPS0jPUZ_9HIH-cfzlpdqCNjM
    ZNtjh2Udn-L6M_hSzXMHWVla-KFGwNVhg9YVnSADeNOcrXSOmLixBgm>
X-ME-Proxy-Cause: dmFkZTGkItqFyL5NRcDZHle1ib9///lTnwAbRuWI6qhGwwnIYZuPk+sLYZrLRkrMjTm5fA
    rLBFhTJ7ujYTI1pRhTtDO1HmHMWhfXQPjNJwOJKkjfQ1v3pxBtq8CyxdPUTBiyvvlMg7EO
    /V87+BOLDxYNcz+BdcyvUlpH8WLrt9DIZHOxFSAUjD8aftu2lMkUX95JaquOc2jhOea0E1
    EeRb8OpaQVPo9cWXHX+X7MEadD7JyqPMWlfl/RlBWeh+qi+IL3r/CVs1yrHW3qHvTcMOjG
    0YyQH1CHiIykJQS4EMi4LLae50ZfH0bYBsR9woNtrohR8HekgZhAhBfAc+lCYTcPOqQGm0
    7n+XOWYNMJqzg6/fos/8jflb7AvtYBnIZSi4+TQ0i2hOYsUe0vBChcg0OSOGLQhoRR8NwS
    w95wKQmWsrTXF5T62xAkXSJlWANVuPF+ey3ZQQ16bj0ljE5/jSPGGxZHSaM3qmxCJ0QB7h
    p0bToaCd8IqUK4dXckr+E79L4kljKKzIiDaIkvGWGy7RuY3cIgjAjSFTcLPK60Cyjr3Ozw
    sBhHL/7zNzW4F9xozcBsaq7EutksmbEdsvAYkfGWMClk7BHYmkHB6Gqx7hpwm662qdbQ7h
    JdsuiazCZVFZJ3pJf7FvBMm0byVQupa9rPbcsRhHuqCtBiDzVW5hkDfhgZKQ
X-ME-Proxy: <xmx:Elvqajuw2PXcbQwrgWrWqHmHthKttXHxg4uaVKey_YxItx6U2zMTCg>
    <xmx:Elvqag2L3Dyb_yHY_2RE54fRMSPDMH-sYitzB128wUozrUV-rzcJXQ>
    <xmx:ElvqarNzjMe5f83V1YpUxoPPquHUTB_JWpo8QYpSk55z73EYQ0I6Jg>
    <xmx:ElvqagUq-ZB22huESTV6QzW2OUQZb3wC5BA7_KdeBpUNozTHPdIaJA>
    <xmx:ElvqagYCOlUjnVcca0fHkWUkUHL1sOUXJqYlz6ZkNDtrOk8UIfF0KWjL>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E812D782738; Tue,  3 Nov 2026 17:07:13 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AyyOFI-zorWw
Date: Tue, 03 Nov 2026 17:06:53 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, stable@vger.kernel.org, yuehaibing@huawei.com,
 zhangchangzhong@huawei.com, weiyongjun1@huawei.com
Message-Id: <15655075-99d7-417c-a0ac-0ab842da23c4@slotpi15m67>
In-Reply-To: <20261103032758.1302493-3-lixiasong1@huawei.com>
References: <20261103032758.1302493-1-lixiasong1@huawei.com>
 <20261103032758.1302493-3-lixiasong1@huawei.com>
Subject: Re: [PATCH v2 2/3] rpcrdma: Pin notifications during removal callbacks
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 03 Nov 2026 11:27:57 +0800, Li Xiasong wrote:
> rpcrdma_remove_one() can race with unregister and invoke a notification
> callback after its owner is freed. XArray RCU does not pin stored objects.
>
> Pin notification owners under rpcrdma_device_mutex and serialize
> unregister with the same lock. Also pin client RPC transports. Skip
> owners in final release with kref_get_unless_zero().

> +	xa_for_each(&rd->rd_xa, index, rn) {
> +		struct rpcrdma_notification_ref ref = {};
> +		bool notify;
> +
> +		notify = rn->rn_get(rn, &ref);
> +		if (!ref.rr_owner && !ref.rr_xprt)
> +			continue;
> +		done = notify ? rn->rn_done : NULL;
> +		put = rn->rn_put;
> +		mutex_unlock(&rpcrdma_device_mutex);
> +		if (done)
> +			done(rn);
> +		put(&ref);
> +		mutex_lock(&rpcrdma_device_mutex);
> +	}

I wonder whether the owner pin is needed once unregister takes
the mutex. Both owners free their object only after
rpcrdma_rn_unregister() returns, so a callback invoked with the
mutex held cannot see a freed owner. Neither rn_done sleeps or
takes the mutex: svc_rdma_xprt_done() sets XPT_CLOSE and
enqueues, and after patch 3 rpcrdma_ep_removal_done() does a
cmpxchg and a wake, or xprt_force_disconnect() under
transport_lock. Invoking rn_done under the mutex would remove
rn_get, rn_put, kref_get_unless_zero() on the owner, the
rr_owner half of struct rpcrdma_notification_ref, and the
unlock/relock around each callback. The contract would then be
that rn_done must not sleep and must not call
rpcrdma_rn_unregister().

The transport pin is a different matter. xprt_force_disconnect()
on a transport that is inside xprt_destroy() queues task_cleanup
as autoclose while xprt_destroy() re-initializes that work for
xprt_destroy_cb(), so rpcrdma_ep_removal_done() does need to know
whether the transport is in its final put, and the matching
xprt_put() has to happen outside the mutex. Neither requirement
involves svcrdma, which leaves rr_xprt NULL, and the header now forward-
declares struct rpc_xprt for one user. Could the transport pin
live in verbs.c, with the generic API carrying only rn_done?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
