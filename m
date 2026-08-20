Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27DE33AFCFF;
	Thu, 20 Aug 2026 06:55:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787208908; cv=none; b=Pi5J32N6s3q39Qqqu9jppGv2hqFdX2PZhT30aQpXz6c1T9EPAINMd1Td/fLbqezJEwpnazKQFstsdmz2sd0TZKsZG1CGlHdwH12zC27BmNxiiwvSKstd513RrM5FUnRdSE+1avA0ifLX0t28ZAR2Lt3dgGvJAdFfJCE1lWULZJw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787208908; c=relaxed/simple;
	bh=wEFxQa5SNPReRNjDvbiJj8OYcP1WF4n28NrwoohbF+k=;
	h=From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:Date; b=ljMLU4abeOBLqvhWT+YftAKIcRfELyvQIK4qciSiU0XFwEuccn22nPtVN+D9R2v9cRNsT1wTc/z/Jpq/xU5U8NVpxSUeuAsDm2b9CsYi0KO+l/kYxgvU5JEP85e6pzAD2tzn0WR4Nkc83CDPzHYEAS4I4bugMkpQb5oT/weeTP8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=URW1o/2R; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="URW1o/2R"
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 1D0EC1F000E9;
	Thu, 20 Aug 2026 06:55:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787208906;
	bh=gJY0VXS+RATQ0tFGGr3u0BU3d0wxy1hBz4D31aEOs2Y=;
	h=From:To:Cc:Subject:Date;
	b=URW1o/2RzMzQ9Wj98j5kwVQLlEorAviuHYq1HKKs1RkYge/0A6pxB7Ypas/V0Kx86
	 c2SW7s9pTg2bVgBbCgVpbU2/hyicbQIRq/QFCsk4ZL7MlUbwsfOnAYCMPfMOsdPD7o
	 DsndY+1E6Kq0fpkThCiuTl4gmaeNt//EjNzDyzNSIMAA84MWABwRKARC5HNKLgsohp
	 /FqU/9nzwzfuDleOdk8UERnNNUp5jMj/TenHbeJrhcXPYmRP7Qg5qz42MHNXl6gxrq
	 TuknOPnoZIQj8Qy2JB8ZpRlejxL/JuTI+Od4P/u1+kioXRKxyKFaL6Cx/6p6rwPEA7
	 p9+XXo3heXmrQ==
From: "syzbot" <syzbot@kernel.org>
To: syzkaller-bugs@googlegroups.com, Slawomir Stepien <sst@poczta.fm>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, <linux-nfs@vger.kernel.org>, "Lorenzo Bianconi" <lorenzo@kernel.org>
Cc: Dai.Ngo@oracle.com, linux-kernel@vger.kernel.org, neil@brown.name, okorniev@redhat.com, syzbot@lists.linux.dev, tom@talpey.com
Subject: [PATCH] nfsd: prevent hung task in nfsd_nl_listener_set_doit()
Message-ID: <4601ffd5-c662-4ab1-ab2f-50a67a0a990e@mail.kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Date: Thu, 20 Aug 2026 06:55:06 +0000 (UTC)

From: Slawomir Stepien <sst@poczta.fm>

In nfsd_nl_listener_set_doit(), the kernel iterates over all
NFSD_A_SERVER_SOCK_ADDR attributes provided in a netlink message to
configure NFS server listeners. There is currently no limit on the number
of attributes a user can send.

For each attribute, svc_xprt_create_from_sa() is called, which may
synchronously invoke request_module() to load the corresponding transport
module. If a user provides a large number of invalid transport names,
request_module() is called sequentially for each, taking a massive amount
of time. Since this entire process occurs while holding the global
nfsd_mutex, it blocks other tasks attempting to acquire the mutex and
triggers a hung task timeout:

  INFO: task blocked for more than 10 seconds.
  ...
  Call Trace:
   <TASK>
   __schedule+0x17e7/0x5630 kernel/sched/core.c:7234
   schedule+0x164/0x2b0 kernel/sched/core.c:7326
   schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
   __mutex_lock_common kernel/locking/mutex.c:726 [inline]
   __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
   nfsd_nl_version_get_doit+0x17c/0xd20 fs/nfsd/nfsctl.c:1889
   genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
   genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
   genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
  ...
  2 locks held by task/5864:
   #0: ffffffff90114168 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40
   net/netlink/genetlink.c:1217
   #1: ffffffff8eeb1a60 (nfsd_mutex){+.+.}-{4:4}, at:
   nfsd_nl_listener_set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964

Furthermore, the function does not break out of the loop if
svc_xprt_create_from_sa() fails, and it suffers from an O(N^2) complexity
issue because svc_find_listener() iterates over the serv->sv_permsocks list
for each attribute.

Address this by introducing a hard limit of 128 NFSD_A_SERVER_SOCK_ADDR
attributes per netlink message. The limit is enforced before acquiring the
nfsd_mutex to prevent lock contention. Additionally, modify the loop to
break immediately if listener creation fails, avoiding needless sequential
request_module() calls for invalid configurations.

Fixes: 16a471177496 ("NFSD: add listener-{set,get} netlink command")
Assisted-by: Gemini:gemini-3.6-flash Gemini:gemini-3.1-pro-preview syzbot
Reported-by: syzbot+41bc60511c2884783c27@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=41bc60511c2884783c27
Link: https://syzkaller.appspot.com/ai_job?id=30871f87-7a83-46b8-ab83-919894b0787b
Signed-off-by: Slawomir Stepien <sst@poczta.fm>

---
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index fa92e31d1..516c04c14 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1943,6 +1943,8 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+#define NFSD_MAX_LISTENERS 128
+
 /**
  * nfsd_nl_listener_set_doit - set the nfs running sockets
  * @skb: reply buffer
@@ -1955,12 +1957,19 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 	struct net *net = genl_info_net(info);
 	struct svc_xprt *xprt, *tmp;
 	const struct nlattr *attr;
+	unsigned int count = 0;
 	struct svc_serv *serv;
 	LIST_HEAD(permsocks);
 	struct nfsd_net *nn;
 	bool delete = false;
 	int err, rem;
 
+	nlmsg_for_each_attr_type(attr, NFSD_A_SERVER_SOCK_ADDR, info->nlhdr,
+				 GENL_HDRLEN, rem) {
+		if (++count > NFSD_MAX_LISTENERS)
+			return -EINVAL;
+	}
+
 	mutex_lock(&nfsd_mutex);
 
 	err = nfsd_create_serv(net);
@@ -2073,8 +2082,10 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
 		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
 					      current_cred());
 		/* always save the latest error */
-		if (ret < 0)
+		if (ret < 0) {
 			err = ret;
+			break;
+		}
 	}
 
 	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))


base-commit: 075b74841bd0065a3bda3440873c747938e69b68
-- 
See https://goo.gle/syzbot-ai-patches for information about AI-generated patches.
The person who has signed off on the patch is responsible for
addressing comments.
syzbot engineers can be reached at syzkaller@googlegroups.com.
