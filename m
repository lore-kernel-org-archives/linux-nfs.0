Received: from mail-wm2-f12.google.com (mail-wm2-f12.google.com [74.125.225.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E984742AFBC
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 08:54:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788771299; cv=none; b=bIeysEw6gdIhZIfPjcNyFuK3Yk/V+Aq3dbEkqKOYtneHa2Upy5zP8D9tejmQKPyqNMrEiz99dpm0Zpkc0KXJmjip8Lm1IqKqOIzOa2BwgRHaUMotxbf0llYvDzApdNq6ObyDwGFp/Ni9UGDoR01efU2lPVzBSr7dEx7cEKk0U4A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788771299; c=relaxed/simple;
	bh=FTDlNw6r0LF5YxoznXLvvaS2gAHptHznaJPZ4Vd/OqI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Ros7q86q7Bi9pwOuKpvtWF6cRuJ34V7w7NieVDVwvy4OD85d2JO8QeBmxZR9z50o3wXr25SQIWrshSwDIhYCqNw9wKQ0Y0Pz8D6EMMh5h5sHlGp8xjfdwgp8GCPms2XuhJwH5ME7UEBnePqABHRJGtfI2X0PzAElK6RKcpYdDBA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=iFWq0p4n; arc=none smtp.client-ip=74.125.225.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iFWq0p4n"
Received: by mail-wm2-f12.google.com with SMTP id 5b1f17b1804b1-49b4ba7fe26so1191265e9.2
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2026 01:54:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788771289; x=1789376089; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=EOH39uXHtiG5QXo0tn6kMtNcNI/rtNOE7+q7zDPj52w=;
        b=iFWq0p4nzwPgnFc7bGhyAtKi7K4wICKdofbQTNhwitqxwBI5Jf/OjMvxVFnrJVV3OI
         EUx3/8uJ/dTqtB8jgzc3AaYNFWyS+8uKgoH7U+p6YZUixf9wBTjEJV1BUJPRw4O/SLCP
         M/1RB7Vj/V8KRyNhb0HdIdBVE3c1+6ADlThk6khvfp/jF2nJ3pfR9TK50BEbkfaorx9V
         AzRJ5Tt4PUVqmWZ7UoD/B4xjSwwcZ+DKb2yX053j+45TF+kUghA+Ek+BZcRP0oCuU7NP
         HBspKApbC+37iPoZy76cVFtiQlP7rC2y8HqFWY0uExa5Fb3eFTFMVkugxupf0xBKpQ8L
         AUYw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788771289; x=1789376089;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EOH39uXHtiG5QXo0tn6kMtNcNI/rtNOE7+q7zDPj52w=;
        b=dJYWGRVZxN279tJbhLYBctn9x+LPnMHIBqKkk3440tIlCsSWdMrIxq7WF8PRe9cw81
         Y5961RF99Mkrpx0ErQVVROemGNRRZ+1DFfhoiZs0xaHpf0zsoDpR+qTRIwnDsU9kqRUg
         +uLHtXXGGlK5Ui+JriRg+PDC0G/7p6Eiicz2EIpFDHEjaqxD40cW2vNBxkXL7NE89I+D
         chctY4ptoekojU/97fgl20nNrCN3EkMnAkewqDrD/dXDv2aVqpsALazTNwZVc1TCuynd
         lKpfQNqJp701IF7IIple+/NbRxuaF8PMs9ElEO/t1HHZrr243Gpcm0cgmcmEgR43IxYK
         6rbA==
X-Forwarded-Encrypted: i=1; AKwUvBzGaTqOUFFeJmi6UeKMECz+a0jhK1Gx0RBN7pK8ueM4zVAU4xbs1NAKmwPiAn0T8cDGcZ0wMBycLTA=@vger.kernel.org
X-Gm-Message-State: AFuF++lArKyDQn6VBWyi4THuKdTjhicYljuG94Ektnr9xw5b2jD+7jM6
	rh7dLBd/eRuyJN1Xl9KjcdF/fdzVnIjVTZXLAyH/XiI8IDYlKXGBHbCt
X-Gm-Gg: AYBFou2N58cp8bbkgV1SVMoGI6ulVCef2QiDtPDmLFTUv9arkf3haDtsUnUogmpjT1A
	ivnB15jEfN2qDJlkPLXHvaDjUElXtkLvVR7IO+WoiASbaQ6ZiD3SC5umSqRRND1N17baMRC2Rlf
	jZ0TNT4BuOuHNRiZnIqsg9aUtxW6n3OwXIi8xnoClpm2wlk7BKkFySdgo9uIDeuu5GGUgm8B2VU
	t5qF4PzdN/MzmUk7qroogPx27tXhCzet8MSdRCx/b2yLru6QDQPTUZbR3woI6BFL7bdFMa3CAqr
	a6Y3uLw4BIv/CHYsUsIdVhTf8g/duIKaAzi7Xxj9zH8IdqLLeIaXKluH86CRI5Lv3LQSDnA6yDe
	ElT3lpM4N3WTWC/px6l213XpPxJLwDGL5Xa+TQa8Tiskwdusyxo8cgONLUYn4QMeo4WQFRStuiP
	0swKPBUKAhBIpI9+Hkn5JG8NWRH6i8r1zSBy0bDp9rO17KbVujIn9xhxEHwqSWKMDc2qSIbYKUb
	rgrqeHyYlo+LIUfowDiI/V1LZkw3au08ok+yf/azr2sJwPI2ln1wMw6C1tbXJxOe3glwrB4YOgy
X-Received: by 2002:a05:600c:34c5:b0:499:cef6:104c with SMTP id 5b1f17b1804b1-49cf823c012mr175956085e9.1.1788771288817;
        Mon, 07 Sep 2026 01:54:48 -0700 (PDT)
Received: from ast-epyc5.inf.ethz.ch (ast-epyc4.inf.ethz.ch. [129.132.161.179])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-49ce5952560sm353482585e9.3.2026.09.07.01.54.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 07 Sep 2026 01:54:48 -0700 (PDT)
From: Zijing Yin <yzjaurora@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: Zijing Yin <yzjaurora@gmail.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] SUNRPC: fix netns use-after-free in write_gssp()
Date: Mon,  7 Sep 2026 01:54:35 -0700
Message-ID: <20260907085435.644076-1-yzjaurora@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While fuzzing with a customized syzkaller, I hit a refcount warning in
xprt_alloc(), reached from a write to /proc/net/rpc/use-gss-proxy:

  refcount_t: addition on 0; use-after-free.
  WARNING: lib/refcount.c:25 at refcount_warn_saturate+0xf8/0x120
  CPU: 0 PID: 10404 Comm: syz.0.17 Not tainted 7.3.0-rc1-00096-gcfebfd3db73d
  Call Trace:
   <TASK>
   xprt_alloc+0x83f/0x9d0
   xs_setup_xprt+0xaf/0x3c0
   xs_setup_local+0x47/0x7f0
   xprt_create_transport+0x16c/0x730
   rpc_create+0x38e/0x7f0
   gssp_rpc_create+0xe2/0x180
   set_gssp_clnt+0xba/0x1b0
   write_gssp+0x200/0x310
   proc_reg_write+0x240/0x330
   vfs_write+0x2aa/0x1050
   ksys_write+0x12a/0x250
   do_syscall_64+0x117/0x750
   entry_SYSCALL_64_after_hwframe+0x77/0x7f
   </TASK>

create_use_gss_proxy_proc_entry() stores the struct net pointer as the
proc entry's private data without taking a reference on it, and an open
file descriptor does not pin the namespace either, as procfs only pins
the proc_dir_entry. write_gssp() reads that pointer back with
pde_data() and hands it to set_gssp_clnt(), which reaches xprt_init():

	xprt->xprt_net = get_net_track(net, &xprt->ns_tracker, GFP_KERNEL);

get_net_track() -> get_net() -> refcount_inc() is unconditional, so
rpc_create() assumes its caller holds a reference on args.net.
write_gssp() does not.

Dropping the last ns.count reference does not make the file go away.
__put_net() only queues cleanup_net() on a workqueue, and the
remove_proc_entry() that fences off further writes runs from the
rpcsec_gss pernet .exit method, that is, from inside cleanup_net(). A
write landing between those two points increments a refcount that is
already zero. cleanup_net() does not re-read ns.count, so the namespace
is freed anyway and the rpc_xprt -- along with the AF_LOCAL socket
opened for it -- is left pointing at freed memory. The resurrected
count is visible to the rest of that teardown too: with
CONFIG_IPV6_MROUTE the same cleanup_net() worker then trips
!mr_can_free_table() in ip6mr_free_table(), which tests check_net() on
the namespace it is freeing.

It reduces to opening /proc/net/rpc/use-gss-proxy inside a new network
namespace, calling setns() back to the original one to drop the last
reference, and then writing "1" to the still-open descriptor.

Take the reference in write_gssp() itself and refuse the write when the
namespace is already gone. This is what procfs does for every other
/proc/net file: get_proc_net() is maybe_get_net(PDE_NET(PDE(inode)))
and seq_open_net() returns -ENXIO when it fails. PDE_NET() cannot be
reused here because the parent directory /proc/net/rpc carries no
namespace pointer. Adding a .pre_exit to rpcsec_gss_net_ops so the
entry is removed earlier would only narrow the window, since pre_exit
also runs from cleanup_net().

Live namespaces are unaffected: a write still returns the error from
set_gssp_clnt(), a write of "2" still returns -EINVAL, and reads are
untouched.

Fixes: 030d794bf498 ("SUNRPC: Use gssproxy upcall for server RPCGSS authentication.")
Signed-off-by: Zijing Yin <yzjaurora@gmail.com>
---
Applies to nfsd-testing (8ba9d2d76000), v7.3-rc1, nfsd-next and nfsd-fixes;
svcauth_gss.c is identical in all of them. Tested with KASAN and
CONFIG_NET_NS_REFCNT_TRACKER: unpatched, the reproducer below warns on every
boot; patched, it returns -ENXIO over 12704 iterations with no splat and no
ref_tracker report.

Reproducer (cc -static; needs CONFIG_SUNRPC_GSS=y, run as root):

	#define _GNU_SOURCE
	#include <errno.h>
	#include <fcntl.h>
	#include <sched.h>
	#include <stdio.h>
	#include <string.h>
	#include <unistd.h>

	int main(void)
	{
		int host = open("/proc/self/ns/net", O_RDONLY);
		int fd;

		if (host < 0 || unshare(CLONE_NEWNET))
			return 1;
		fd = open("/proc/self/net/rpc/use-gss-proxy", O_WRONLY);
		if (fd < 0 || setns(host, CLONE_NEWNET))
			return 1;
		if (write(fd, "1", 1) < 0)
			printf("write: %s\n", strerror(errno));
		return 0;
	}

 net/sunrpc/auth_gss/svcauth_gss.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 967e9d53080d..8e0b6b17c81d 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1420,10 +1420,19 @@ static ssize_t write_gssp(struct file *file, const char __user *buf,
 		return res;
 	if (i != 1)
 		return -EINVAL;
+
+	/*
+	 * The proc entry does not hold a reference on @net, and neither
+	 * does an open file descriptor, so @net can already be dying.
+	 * rpc_create() below takes a reference unconditionally.
+	 */
+	if (!maybe_get_net(net))
+		return -ENXIO;
+
 	res = set_gssp_clnt(net);
-	if (res)
-		return res;
-	res = set_gss_proxy(net, 1);
+	if (!res)
+		res = set_gss_proxy(net, 1);
+	put_net(net);
 	if (res)
 		return res;
 	return count;

base-commit: 8ba9d2d760007b15f8b4e8a812c9c0dfd66a2763
-- 
2.43.0

