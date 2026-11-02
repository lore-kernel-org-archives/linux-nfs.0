Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793656345;
	b=XIC/6gH2VbmHQH6l/f+HQQyNVGGPm4w7aAWog67V6ByiFb0gD6Hq1hjsCImjaaw2Xmbn
	 X8ikalprh8ko80Hj4sYww1h0ILhYoB6NYfMkY8x8XU8I4HTnVJax2uLugVoXXiW2lZDRl
	 VQ88BSlG4Sf8V3bkd76I+/f79qV9UxU6BzponS4dMg4cxQLVp1w3c4uJq89pVAHduWyzD
	 SlPx5YG94+HMUe7HpTaLP7J+ybCpwNhxxdjB6SR4TRa23tXlnhrBaQd7SroBSVZjFo0Xr
	 ybLM1I44ii0YPPaL1fy126Hzox6/HFuaVlw0oHh9aSMCT3icUpygNng6fbVnkO00aww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793656345;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=/OTSAl4H+udqd3LzYNWpVdV26uuuqb3KXJiXs8QLXlo=;
	b=SglAKzOsAYJPspsksphqOTkuBNHw36MImxJUkU2tEmASyNpMZKtfCxNK26eF5WFvEqZS
	 vkvRmd9/MAMl0nyLh9j2WENvjDNZrFD35rNe0XySArWMUQ8VDWTTA2jL2iEHPT8amxuJy
	 z/OMz7Pi12BoQzh1T7ROIEfGjwGBCyEAhr4hEjfXRVT/soyYOWISxntksJ4SuDB2MfEDW
	 RojR2DVPdV/+AE+wewlHkF251TwsGdz2j/cq/jpKGQQtXMCcpLemXglmTX+Ld/7tyGvnW
	 oChAWfo1tTYIPAcC1OaR3SmGQKhcku/P2yOVEHCaBkixb1G4K4Kl1L1DHktehFlFARw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GW0DZm4P;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85379606A334
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 21:52:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GW0DZm4P
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EE91F1F00A18;
	Mon,  2 Nov 2026 21:52:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793656345;
	bh=/OTSAl4H+udqd3LzYNWpVdV26uuuqb3KXJiXs8QLXlo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GW0DZm4PdTZ3mnMG73Q/F6plidT4pQZA6e3BNKjmpspKwUSxePx81lCFh0A7y4Dsp
	 3ektkLLHGBVunOF/Y15bRx8QyrIPjMhHMGq2ddtcoTzc5h7TV00n7VviiaZUjsmEjP
	 5w9tUQ063yBmsj60MeXXeTGAtb6KAvbwmMKHAwmHZaCZJs/NveAxL3XLZctfNo58u9
	 786aUkC9CsroHXPc7uJfKaDHnAQWAmw8GaGn2HicO69ygliQwDCpB4OASQJYLDRF2p
	 DRQjU9ko3g5AQEJfJ0oX98a3+/p2LJT6rFaIKEBX4zKhBG3DTXahsKFGDpQYEYsGp9
	 IuqL6Y1d6HXmQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS/localio: give the LOCALIO probe a short timeout of its own
Date: Mon,  2 Nov 2026 16:52:20 -0500
Message-ID: <20261102215220.16055-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102215220.16055-1-snitzer@kernel.org>
References: <20261102215220.16055-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The LOCALIO probe clones the NFS client with rpc_bind_new_program(),
which NULL-pings the new program before the probe sends UUID_IS_LOCAL.
Both calls use the mount's timeout.  With timeo=600 and the default
retrans, a server that does not answer the LOCALIO program holds each
probe for about 170 s.  The client then logs "nfslocalio: server ... not
responding, timed out".  On such a server, one mkdir took about 170 s
of a 202 s run and ended when the probe gave up.

Give the probe a soft timeout of its own, with no retries and no log
message.  The new nfs module parameter localio_timeout sets it in
seconds, 10 by default and at most 600.  Set it on a private clone of
the NFS client before rpc_bind_new_program(), so that the ping uses it
as well.  Clear cl_noretranstimeo, which NFSv4 mounts set, because with
it a sent call does not time out while the connection stays up.  With
localio_timeout set to 0, the probe uses the NFS client's timeouts, as
before.  The probe still shares the NFS client's transport and runs
beside its RPCs.  The NFS client's own timeouts do not change.

Tested through a proxy that drops every call to the LOCALIO program:
the probe gave up after 10.6 s and logged nothing.  With
localio_timeout=0 it took 182.9 s and logged the message above.  The
probe still succeeds against a server that supports LOCALIO: with no
proxy, a 64 MiB O_DIRECT write through LOCALIO sent no WRITE RPCs.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/localio.rst |  9 ++++
 fs/nfs/localio.c                          | 54 +++++++++++++++++++++--
 2 files changed, 60 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfs/localio.rst b/Documentation/filesystems/nfs/localio.rst
index e8f44332cc806..45c6981da0d89 100644
--- a/Documentation/filesystems/nfs/localio.rst
+++ b/Documentation/filesystems/nfs/localio.rst
@@ -316,6 +316,15 @@ It is checked on every I/O: setting it to N sends the next I/O of every
 client over the network, and setting it back to Y resumes LOCALIO.  A
 client that probed while it was N is probed again when it is set to Y.
 
+/sys/module/nfs/parameters/localio_timeout (uint)
+sets how many seconds the LOCALIO probe waits for each reply from the
+server, defaults to 10, at most 600.  A server that does not support
+LOCALIO may not answer the probe at all.  If no reply comes in time,
+the probe gives up without a log message.  The client then does not use
+LOCALIO.  The mount's timeouts do not apply to the probe.  Set to 0, the
+probe uses the mount's timeouts instead, as an NFS RPC would.  A change
+applies to the next probe.
+
 /sys/module/nfs/parameters/localio_O_DIRECT_semantics (bool)
 controls if O_DIRECT extends down to the underlying filesystem, defaults
 to N. Application IO must be logical blocksize aligned, otherwise
diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index 80a496d6fe0d6..06d0755b1f203 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -82,6 +82,22 @@ static const struct kernel_param_ops localio_enabled_ops = {
 };
 module_param_cb(localio_enabled, &localio_enabled_ops, &localio_enabled, 0644);
 
+/* Seconds the LOCALIO probe waits for each reply; 0: the NFS client's own */
+static unsigned int localio_timeout __read_mostly = 10;
+
+static int localio_timeout_set(const char *val, const struct kernel_param *kp)
+{
+	return param_set_uint_minmax(val, kp, 0, 600);
+}
+
+static const struct kernel_param_ops localio_timeout_ops = {
+	.set = localio_timeout_set,
+	.get = param_get_uint,
+};
+module_param_cb(localio_timeout, &localio_timeout_ops, &localio_timeout, 0644);
+MODULE_PARM_DESC(localio_timeout,
+		 "LOCALIO probe timeout in seconds (default 10), 0 to use the mount's default");
+
 static void nfs_local_do_read(struct nfs_local_kiocb *iocb,
 			      const struct rpc_call_ops *call_ops);
 static void nfs_local_do_write(struct nfs_local_kiocb *iocb,
@@ -156,13 +172,45 @@ const struct rpc_program nfslocalio_program = {
 
 /*
  * nfs_init_localioclient - Initialise an NFS localio client connection
+ *
+ * A server that does not support LOCALIO may not answer its RPCs at all.
+ * The probe shares the NFS client's transport and runs beside its RPCs.
+ * With localio_timeout set, it gets a quiet, soft timeout of that many
+ * seconds of its own, whatever timeouts the mount uses.  With 0, it uses
+ * the NFS client's timeouts, as an NFS RPC would.
  */
 static struct rpc_clnt *nfs_init_localioclient(struct nfs_client *clp)
 {
-	struct rpc_clnt *rpcclient_localio;
+	unsigned int timeout_secs = READ_ONCE(localio_timeout);
+	struct rpc_clnt *parent = clp->cl_rpcclient;
+	struct rpc_clnt *probe = NULL, *rpcclient_localio;
 
-	rpcclient_localio = rpc_bind_new_program(clp->cl_rpcclient,
-						 &nfslocalio_program, 1);
+	/*
+	 * rpc_bind_new_program() pings the new program with the timeout of
+	 * the client it clones, so set the probe's timeout on a private
+	 * clone first.  The clone's cl_timeout points at the transport's
+	 * timeout: give it its own copy rather than write through it.
+	 */
+	if (timeout_secs) {
+		probe = rpc_clone_client(parent);
+		if (IS_ERR(probe))
+			return probe;
+		probe->cl_timeout_default = (struct rpc_timeout) {
+			.to_initval	= timeout_secs * HZ,
+			.to_maxval	= timeout_secs * HZ,
+			.to_retries	= 0,
+		};
+		probe->cl_timeout = &probe->cl_timeout_default;
+		probe->cl_softrtry = 1;
+		probe->cl_noretranstimeo = 0;
+		probe->cl_chatty = 0;
+		parent = probe;
+	}
+
+	rpcclient_localio = rpc_bind_new_program(parent, &nfslocalio_program, 1);
+	/* The new client holds a reference to its parent, the probe clone */
+	if (probe)
+		rpc_shutdown_client(probe);
 
 	dprintk_rcu("%s: server (%s) %s NFS LOCALIO.\n",
 		__func__, rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
-- 
2.52.0

