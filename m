Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8ED6B3B389E;
	Fri, 28 Aug 2026 16:37:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935074; cv=none; b=oIdXUUwZR5BY40r/7UyGzvGQGb8TP56noXtl8lX2FxT0AycXzkW6aeYpol0Wo/xqSLQdfqFkzOwNz0hR8nOuhbFETz8pus/AVChtalptTR1aYMsEJapgFSFJAz3AaOMFW25Gh0qrIU3Nq8x8rEpB+AUrB0pihNOm6ZGZGNt8dWw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935074; c=relaxed/simple;
	bh=V+wvIGsJlzSDNv4WKj3Vpj9Bw7A+dysnBkXbj7sTYeg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Ll2F40t4+rBt9sSallnG/kBfTIJPcof9FUH/yDhy6qDvK44rBvKBBIxNXUmDpaH2nNGMIpprnvVKXR2OOwzFjjapqSNJqRNOF6luLNJfp8DhSWp9oWQTiLOzYZNSxzXim+haKuE57KRym9SSpNwHujM89RN5CwaAbG9dCPj+IAI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DVOOwJxE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DVOOwJxE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 08B061F000E9;
	Fri, 28 Aug 2026 16:37:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935073;
	bh=dtpz+uXivVuZd9+O4vrtoCG96NBwe0+gdme3nSBwjT8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DVOOwJxEwPyPFVNHqFo6WPJc7doWCYfTuPiVsoN07toqemsRdr5C+5bS7Nfke5W+D
	 nIgx1aqFPgcDc/Z7LlmoQzW3WzrHC5V4ErwgNb9jsoduqoEk5hErUwmZv1hksHJDga
	 m+BBzv/qxd3hrZT18203L2ng6aHi0uzejChAxdqsnuGhQyKoExpzKbVu9KRfieIh5T
	 AJGTqeWwiDurepdmk0tWZIvDXrLHshOaT96bZyGvCoNa6dvvZcCxxNxwu6Y+8yFKTr
	 g7FHEZPp9kzshSB23SN9H984vivLiylGTvgdfzwE4Gqtsg+Ng7cw9sTIrhXiE1nkVW
	 buY9lM3pB6Hyw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:35 -0400
Subject: [PATCH v3 05/14] NFSD: report listener creation failures through
 extack
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-5-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2186; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=V+wvIGsJlzSDNv4WKj3Vpj9Bw7A+dysnBkXbj7sTYeg=;
 b=kA0DAAoBAA5oQRlWghUByyZiAGqRuVXIkhKLjoVK2Xf8t97Nob429skz7qEVJf+VzuQ/ACxBc
 IkCMwQAAQoAHRYhBEvA17JEcbKhhOr10wAOaEEZVoIVBQJqkblVAAoJEAAOaEEZVoIVEKsP/3hp
 HMShPkUd7LRnvHya7w9OlIts1azmUNvymC/6Bo8UF4h6ku8lEOd5wVQotYujAUO7mpvWJT4QRum
 sskrv7sSRFY+AXtf+0wUpZI2+Y2eKUChpLQc/xTenweOpo7As6iZJsRqG2ZukebqptbpjDM2qPY
 Hgtv6095Lcy+bvkca4PStU/hTpk0/0Y7BcJD9jB6bcHo9JzkXoveT1xdQ8VHPgw0syrRKrUtt16
 nJw5M68NfifzuuFHSjOIgc1jZAnGNeGa//2jq4+atT64IIHeZEnvyPbQ+8Y3UyGlv3FS/yXZhdQ
 UvsM77j7Lw2DvRJlebx7WyX1QaLimZRsqzJdQC3G/kgXmFp4Ghn0P9pJNpAYeuaAC6a5rhQ5BRQ
 BZKxv3dj1xHN+Tdtnw2PStP3ut3yLdaRaGVnnwlq833y+lkcotGN1QKL7GiIdLmuhd8twZiJdGv
 hyKQOy4jptNMNsYG6yme7iMZ6XFNaquMc0Z7x/j2CSFARr/r1B1JsmimtrJqew4mlJ2/03/s8Cm
 Sx/J5au1C0gMlJjdOlGdrOSG9IBWNIaauhReOcWnOKcpO9Pbo4v22P6sKHxkMLKAl8rvu737Y/q
 /74jonzh0MGdfoL+HRZQIvmvtsB+2PIxOr8KN4KlQWOMdYW9XU2GWtWbmum+edm4GxlD7boQ3Ws
 Kj+Iz
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() returns the raw errno from
svc_xprt_create_from_sa() and sets no extack. A failed LISTENER_SET
therefore tells userland only "Address already in use", or whatever else
the transport returned. It never tells userland which entry failed.

Record the attribute and the transport name of the entry whose errno the
call returns, and report both after the loop. NL_SET_BAD_ATTR() names the
entry, which the message alone cannot do: a request can carry several
entries with the same transport name.

The rejections in nfsd_nl_validate_listeners() other than -E2BIG and the
unsupported transport name still carry no extack. This patch does not
change them.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d8135f38e69f..6cbdcee4b733 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2089,7 +2089,9 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
+	const struct nlattr *bad_attr = NULL;
 	struct svc_xprt *xprt, *tmp;
+	const char *bad_xprt = NULL;
 	const struct nlattr *attr;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
@@ -2208,8 +2210,22 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
 					      current_cred());
 		/* always save the latest error */
-		if (ret < 0)
+		if (ret < 0) {
+			bad_attr = attr;
+			bad_xprt = xcl_name;
 			err = ret;
+		}
+	}
+
+	/*
+	 * The ack carries the errno of the last entry that failed. Point at
+	 * that entry as well, since several entries can share a transport
+	 * name and the errno alone cannot tell them apart.
+	 */
+	if (err) {
+		NL_SET_BAD_ATTR(info->extack, bad_attr);
+		NL_SET_ERR_MSG_FMT(info->extack, "cannot create %s listener",
+				   bad_xprt);
 	}
 
 	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))

-- 
2.55.0

