Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794857716;
	b=Lwj4PYVe/k2v5b77XFVkAfFsu1bhIeSp9JBHN5J4apSh1dAOvU9slsLtNVJVA9XjIx52
	 gDosOXBMbdoKrHY5Dn9DUEXCAfSdJ8/Bf6PxCIQZqVw+EDe7z6qMfx6XpxAVOQ9c48+SH
	 vxlLJCl6MjiyPDoEZEEhdZN599QuSP/sFoAb0LJzEtnmFuSvbQ/c04IQEtFHmGXJXyLog
	 sJIrG7T8j7n9Vd/I29+Ak5Cptu8uPQtVl2BKsw25+Rs7fBNnVtX6VLmLoBj2Qd9aDf0V9
	 1qUInxrJAHJwI8nNuysbAtxsk6VUG1LjQWAcePNx4TSpb1kYf9zVowjBKUcZE/jyfVQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794857716;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ex8sQsHIpPx0Nkd4LC2Tkk5aOBl+I7Jg5Gyc5xqzvWs=;
	b=azZtPNKN5uJJ6TFXd8U3Mhpkrx7o+kEdlR7FWE1G3JNB4/RkEdW2Egf1mz1FUMuHLrgH
	 mbliYebVgeGna04wBk1KNTmLplwKpZ5K/OMf5/O6UYeX0rNfurM9otQq4VXPJ9LtF1rTH
	 pd71CyjsK06N7Yvp7eKBZGD97Q/r/Cwpl+YcHtq4WEzTZALwAf7puQVTA9A8yB2dA2hP2
	 PNVH4exGpqSf7rF7Gcqml8UFcdbdCgm968QsPpe274o9/qWrnghRLPLR2Q+RBkpGmM8Oi
	 8XVX0C1rIXKQWzfhOXepIjf+h7XbBadaDln72whBI2VuSLj/eIbtC5Sc02twg6/6Bkw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TRJuwhmb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84366606A330;
	Mon, 16 Nov 2026 19:35:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TRJuwhmb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 95F761F000C4;
	Mon, 16 Nov 2026 19:35:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794857716;
	bh=ex8sQsHIpPx0Nkd4LC2Tkk5aOBl+I7Jg5Gyc5xqzvWs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=TRJuwhmbE2QVM975XTsOiQxVBpLb73RPDqfAHb2UNZ+rtGZoPsy/gOtYG4sjdu2/O
	 9yJMlr6+KBttJpx32oAzkJnKRIpBhJyLxbnN9615uI3rTiMyU9Q4KR1bTS7jUVoJyL
	 GqDAYOcglcyqx5m1EgFZRZT63MZAazHX0ETifAfr29S8/RNPk6Xppxc6b41O+d7xJM
	 I9T0v+SCO4hAGy4R2S7dPCDUnPD8cYN61+GHpVUIpYWbmPOgvlXAMrexgp3XK32uRq
	 30NuFWshSFAb3LL75GQl4fRn6CiYJivf3EJ+BKq8KMDsgYFki8xbPgm3qPd0nL5/l2
	 umxJF4DVXWtNQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id F21DCF4008E;
	Mon, 16 Nov 2026 14:35:14 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 16 Nov 2026 14:35:14 -0500
X-ME-Sender: <xms:8lr7aqy2mio05VSyCMv9d5JzFlNbS5Z5HCwyJkxR3th3MGMJifRuyg>
    <xme:8lr7ahEjHY5ZsaUt9-pDaEc3evfBzWl4tRgCsvzIgQ75fcRGAH2tc8gwt5RDbxGBu
    XBF9_dK0TN7cY7FG6s96_FzsTA-GIZQW1KacC2bsNaPAt6qoUv7Q-Q>
X-ME-Proxy-Cause: dmFkZTEDf1fF5fEjzXWosWKUidFpweRbW27lXH2eETu4hEuPB6N7vCEWuRexsuIK2XCxz6
    1SJhRsOZ1wJzJ2XNS4wbK3MXOeiY+ZRjeQqtOZEU8I6FcVejjAACXS4aREsw+YLhui8r8w
    75GysTZxGkHNZGJpo0hROO5mNVfHHVNm2H3JKd+MaWv0O7+znYjnPX6/D5p/YxniGAdIsD
    P4L2mMThJcQm1hcEQb4dV/qARgqXDHDpbaQBjxkegRpWeV9k8Yd00aUmtQMp3SsFXMgqLD
    Kkc+h/0j/216mCHf+RLvVDxHEoMI+kmiS7hNfVMIxjLamNIo6P9E9RkT8eb+xTFdZjE2C1
    yWLVyuaWFClhd7btoVxPHuG/z1EuWrZnBK73SOPwUKRtv4De2gp7oatGCNgMgP3Key1skl
    JNTwibMVjhNHut1owP6CDpbADG+dVALqfic5ZGTM7/vYIyl1t37ohmFVwNEi+2UDbKeSO3
    qKg9rVhdra6qM3js+FSpYQcHoIcC8mgY4PsikFojyKrzAfnNOvZAeAPhARJDzjBILJlaAd
    L/hrt+HUBqqNnAR+GlBXHGtB9S0YQMIVksbnqih0tUVzkCisAQ6e6bhZc/3wGR1oGYdyJi
    hEe+oEN4fEd620Oe7CVEyLS5Wr3uoHMrIzK66FXQKlxKZir81QnmN/SywMJw
X-ME-Proxy: <xmx:8lr7amuj-eeKiSi8PDxR64uhUmwW8-SUuJ67vxRGywCSyULcJvToyw>
    <xmx:8lr7aq7aJ5q_eZpUxXF2jq7u5kH9P1v48QoScht4oPPpIp3GkevHdA>
    <xmx:8lr7ai11A4ItBqtor-sHc3eigNSVTNxmjXX69khbYc3cXfsJQ5o2bA>
    <xmx:8lr7aljF5bVi_RCIBQOZPaKB942nl3sGz9qQeWC_VY0f3wtJhM0foQ>
    <xmx:8lr7aqqGJYCazqYZ-135JAkaCP1tqnUlPapmasY2uPW7DK-EbxLDB0Yb>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id D88E9B6006E; Mon, 16 Nov 2026 14:35:14 -0500 (EST)
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
X-ThreadId: AkKQlABzAp6g
Date: Mon, 16 Nov 2026 14:34:54 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Andrew Pam" <andrew@sericyb.com.au>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Rafael J. Wysocki" <rafael@kernel.org>, "Mike Snitzer" <snitzer@kernel.org>,
 linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <51a2b5d3-4322-42ed-a2ee-e17c125865fa@app.fastmail.com>
In-Reply-To: <20261116131428.1024230-4-andrew@sericyb.com.au>
References: <20261116131428.1024230-1-andrew@sericyb.com.au>
 <20261116131428.1024230-4-andrew@sericyb.com.au>
Subject: Re: [PATCH v2 3/3] SUNRPC: reconnect client transports after resuming from
 hibernation
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Andrew,

On Mon, Nov 16, 2026, at 8:14 AM, Andrew Pam wrote:
> With rpciod and xprtiod frozen across hibernation, no RPC is sent after
> the snapshot. TCP can still acknowledge data the server sends then,
> though: typically a reply that was in flight when the snapshot was
> taken. The restored image has not seen that data, and the server, which
> saw it acknowledged, will not send it again. The client then waits
> indefinitely for replies that never arrive.
>
> Captured in a QEMU test (below): on the one cycle of six that hung, the
> client's TCP acknowledgement went backwards by 200 bytes after the
> restore, and the requests outstanding (WRITE, COMMIT, GETATTR) stayed
> queued on xprt_pending with no further progress.
>
> After resuming, disconnect every client transport. Requests in flight
> are retransmitted on the new connection, and the server answers any it
> has already executed from its reply cache. Because nothing was sent
> after the snapshot, NFSv4.1 session slot sequence ids still agree on
> both sides.
>
> The disconnect is done from a PM notifier at PM_POST_HIBERNATION, which
> runs in the restored kernel once everything has thawed. It is also sent
> when hibernation fails, where the reconnect is unnecessary but harmless.
> xprt_put() may sleep, so references to the transports are taken under
> the client list lock and RCU into an array, and released afterwards. The
> array is sized by a counting pass first, so it is allocated with
> GFP_KERNEL rather than under the locks, and the walk is repeated if
> transports were added in between: one left out would stay stalled.
>
> Tested in the QEMU setup described in the first patch of this series,
> with 20 hibernations in test_resume mode back to back while NFS writes
> (8 MB, fsync) and reads ran continuously. Without the series the client
> hung on the first cycle; with only the first two patches, on the sixth.
> With this patch all 20 cycles completed and I/O progressed on every
> one. The capture shows the client's acknowledgement going backwards on
> two of the old connections, and the client reconnecting and carrying on
> both times. The single-hibernation test is unchanged apart from one
> extra connection per resume: nothing reached the server during the
> image write, and the client resumed without errors.
>
> Drafted with an AI coding assistant (Claude), which also ran the tests.
>
> Signed-off-by: Andrew Pam <andrew@sericyb.com.au>
> ---
>  net/sunrpc/clnt.c        | 112 +++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/sunrpc.h      |   2 +
>  net/sunrpc/sunrpc_syms.c |   7 +++
>  3 files changed, 121 insertions(+)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 2f076b4bfd54..f9c31c49dc0b 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -32,6 +32,8 @@
>  #include <linux/in.h>
>  #include <linux/in6.h>
>  #include <linux/un.h>
> +#include <linux/suspend.h>
> +#include <net/net_namespace.h>
> 
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/addr.h>
> @@ -881,6 +883,116 @@ int rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
>  }
>  EXPORT_SYMBOL_GPL(rpc_clnt_iterate_for_each_xprt);
> 
> +/*
> + * After hibernation takes its snapshot, the kernel keeps running with the
> + * network up while it writes the image. rpciod and xprtiod are frozen by
> + * then, so no RPC is sent, but TCP still acknowledges anything the server
> + * sends, such as a reply that was in flight when the snapshot was taken.
> + * The restored image has not seen that data, and the server will not send
> + * it again, so the connection cannot make progress.
> + *
> + * Once the system has resumed, disconnect every client transport. Requests
> + * in flight are retransmitted on a new connection, and the server answers
> + * any it has already executed from its reply cache. Because nothing was
> + * sent after the snapshot, NFSv4.1 session slot sequence ids still agree.
> + */
> +/*
> + * Take a reference to each client transport in every network namespace and
> + * store it in @xprts, up to @max of them. Returns the number of transports
> + * found, which exceeds @max if the array was too small. Called with
> + * net_rwsem held for reading.
> + */

What's with the weird double comment here? I like the second one better.

> +static unsigned int rpc_pm_get_xprts(struct rpc_xprt **xprts,
> +				     unsigned int max)
> +{
> +	unsigned int n = 0;
> +	struct net *net;
> +
> +	for_each_net(net) {
> +		struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
> +		struct rpc_clnt *clnt;
> +
> +		spin_lock(&sn->rpc_client_lock);
> +		rcu_read_lock();
> +		list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
> +			struct rpc_xprt_switch *xps;
> +			struct rpc_xprt *xprt;
> +
> +			xps = rcu_dereference(clnt->cl_xpi.xpi_xpswitch);
> +			if (!xps)
> +				continue;
> +			list_for_each_entry_rcu(xprt, &xps->xps_xprt_list,
> +						xprt_switch) {
> +				if (n < max) {
> +					xprts[n] = xprt_get(xprt);
> +					if (!xprts[n])
> +						continue;
> +				}
> +				n++;
> +			}
> +		}
> +		rcu_read_unlock();
> +		spin_unlock(&sn->rpc_client_lock);
> +	}
> +	return n;
> +}
> +
> +static int rpc_pm_notify(struct notifier_block *nb, unsigned long action,
> +			 void *data)
> +{
> +	struct rpc_xprt **xprts = NULL;
> +	unsigned int i, n, max = 0;
> +
> +	if (action != PM_POST_HIBERNATION)
> +		return NOTIFY_DONE;
> +
> +	/*
> +	 * The references are taken under spinlocks, but xprt_put() may sleep,
> +	 * so collect them in an array and disconnect after the locks are
> +	 * dropped. Count first so that the array can be allocated without
> +	 * GFP_ATOMIC, and recount if transports were added in the meantime:
> +	 * a transport left out would keep the stalled connection.
> +	 */

Is there a way to do this without the double loop? The rpc_xprt_switch has a
"xps_nxprts" field that should hold the number of xprts in the switch. Using
that might be more straightforward than looping twice and counting.

Thanks,
Anna

> +	for (;;) {
> +		down_read(&net_rwsem);
> +		n = rpc_pm_get_xprts(xprts, max);
> +		up_read(&net_rwsem);
> +		if (n <= max)
> +			break;
> +
> +		for (i = 0; i < max; i++)
> +			xprt_put(xprts[i]);
> +		kfree(xprts);
> +		max = n + 8;
> +		xprts = kmalloc_objs(*xprts, max);
> +		if (!xprts) {
> +			pr_warn("RPC: no memory to reset transports after resume\n");
> +			return NOTIFY_DONE;
> +		}
> +	}
> +
> +	for (i = 0; i < n; i++) {
> +		xprt_force_disconnect(xprts[i]);
> +		xprt_put(xprts[i]);
> +	}
> +	kfree(xprts);
> +	return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block rpc_pm_nb = {
> +	.notifier_call = rpc_pm_notify,
> +};
> +
> +int rpc_pm_notifier_register(void)
> +{
> +	return register_pm_notifier(&rpc_pm_nb);
> +}
> +
> +void rpc_pm_notifier_unregister(void)
> +{
> +	unregister_pm_notifier(&rpc_pm_nb);
> +}
> +
>  /*
>   * Kill all tasks for the given client.
>   * XXX: kill their descendants as well?
> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
> index 11b9e5cead8e..1833b167616c 100644
> --- a/net/sunrpc/sunrpc.h
> +++ b/net/sunrpc/sunrpc.h
> @@ -43,6 +43,8 @@ struct rpc_task;
>  struct rpc_xprt;
>  int rpc_clients_notifier_register(void);
>  void rpc_clients_notifier_unregister(void);
> +int rpc_pm_notifier_register(void);
> +void rpc_pm_notifier_unregister(void);
>  void auth_domain_cleanup(void);
>  void svc_sock_update_bufs(struct svc_serv *serv);
>  enum svc_auth_status svc_authenticate(struct svc_rqst *rqstp);
> diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> index 1a3884a0376a..d32786f51ae5 100644
> --- a/net/sunrpc/sunrpc_syms.c
> +++ b/net/sunrpc/sunrpc_syms.c
> @@ -116,6 +116,10 @@ init_sunrpc(void)
>  	if (err)
>  		goto out6;
> 
> +	err = rpc_pm_notifier_register();
> +	if (err)
> +		goto out7;
> +
>  	sunrpc_debugfs_init();
>  #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
>  	rpc_register_sysctl();
> @@ -124,6 +128,8 @@ init_sunrpc(void)
>  	init_socket_xprt();	/* clnt sock transport */
>  	return 0;
> 
> +out7:
> +	genl_unregister_family(&sunrpc_nl_family);
>  out6:
>  	rpc_sysfs_exit();
>  out5:
> @@ -141,6 +147,7 @@ init_sunrpc(void)
>  static void __exit
>  cleanup_sunrpc(void)
>  {
> +	rpc_pm_notifier_unregister();
>  	genl_unregister_family(&sunrpc_nl_family);
>  	rpc_sysfs_exit();
>  	rpc_cleanup_clids();
> -- 
> 2.53.0
