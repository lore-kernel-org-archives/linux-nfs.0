Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EACD2AD0C
	for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2026 12:47:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785070043; cv=none; b=Th8k6CYmrGQNPQ1F1SbQzWpQ3v+jYk+tpCYx+L28k6sOicLiMGIn+wQW55WO+QX35wBkCnNNHHKNDCpAv9BlSnmTzKP/7S0GNEoaERX5Lh8xtJxtyxetvnVVnJAqKfyzAS0nx5jvA5N7nKXtNsWxu05nLQWttnLX9cllfXF7vWQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785070043; c=relaxed/simple;
	bh=ETwgpic4AxV4z6t6xS8Pv4sGx1TgnRkisPH97UQ4Zks=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=dcIvhDaCJmADdoQcVv6YJ2Lt3tupqVyySiEDiTIMLJNeDRB9CCbKcG+8dVpVD8+lGfnLCjT+m8+bEQlm2bLGAo14pcOmkBtYSNPwM2ZzAuh1y7eifsA93Zy/FuEueqhN3UrzNULW36w0vISw/OOo7eYWSVb6mKWdWdLp1O+/Dqw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=b5SSLJFu; arc=none smtp.client-ip=209.85.128.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="b5SSLJFu"
Received: by mail-wm1-f50.google.com with SMTP id 5b1f17b1804b1-495590dde14so19796065e9.0
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2026 05:47:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1785070040; x=1785674840; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=NGZDh/MbIRdQ1s+o464mf9UQFMNafwm2SIf/zrfLjF4=;
        b=b5SSLJFuhPXKdBQBfRqks67ChHVk7P7wtnALVU0HHcz2eJG/3exxIsnBimpwEJAQFi
         qHzab7mY3vD8dXkETcKLCVBFwVox53b5yODcXNzmH5b+8Cm5ud8K9wL1kwBW6Xv2VKlV
         4ghrrMmwLqtvrmSE+W/oa2ufC9I1DylYy7jrO5WGvaG9jX92RfAE1pYov+fDIG75vgGf
         mC3v/83jiYdUkTZ9Vn5uEMyvW3+er3UUVfzET9Yxwf7xsrTgZdOZ8NehmyXl3IheDeOz
         mABq0S/z5XJu3CaFtaPCS2tmqY761nEHvIOsORh6didJMhepvvg3FZwWce4AKYJ/KP6e
         gJFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785070040; x=1785674840;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NGZDh/MbIRdQ1s+o464mf9UQFMNafwm2SIf/zrfLjF4=;
        b=KwKHYSQnhNqFXWGPVX9OGvq00nlM5ClXbMyoIzwHIsJRbJWfb1EmAGlFDS6+lG5FzF
         xE7OC1j3yL1sQWijIvmQqK69h5u6oHln6TLKyJ4coLwdhIMnr0pNGMXKSZvjvPX4n8XK
         5WqLiNeOKt88ApTjNcxl58yN7DP2tHZvnLIWTG8hEJnpgnwYwdGzN5EfgjGNY1Z9PDcB
         flI88icUgfknFxoJKCGNnV7PVS57bLd4nrW/VHL7722DuBmM7wSyj3ewgUYWBBB6NJg4
         7XU4vFtTKpv2u/6qgfcFmuN3TejeXqxlGUgRrfKEYVeqSVafINV/wmvQP9KT1c9pOLuq
         P/aA==
X-Gm-Message-State: AOJu0Ywy3lJd7VOO6k+IhwSrq+KdZONzzDk6ZlRfNpdlphhQERTpiXTa
	hutKb2g9pcSJY7nUjaopX6uQFZCaZQpMFbfg49gShvk8hqpQDkub5XMFwfgpyiEg3w==
X-Gm-Gg: AR+sD13WxssZQZ23ZU98cyrDNFbjHnj4w2HoFXgKDR+QMf15Iq/62eW4d4XiXJ5sp3E
	PKwW/We66Nmy9NkgJZC5ZzOM+BgqtOUmuoDue5RB5zOi0IfouTsY30ZeIWEA8Sgky2C4/S/9egk
	2VIkqZwJfErxWWJ27JZyuMRnyMQ/Ixr72EGskVwFK7abXEVMmMlIKiINSi0RoIf+hjr/ida9xhm
	as9yy6bXm/ukl3hQnpSQ9LrM55czIICdEQuecQIypiJh2i6ZN+Gs48EZssd9HTHLxle+qv/s4/f
	LCEVrjFlUEU5XnO+eCkK5+SEopHN2JEdnpIScMfG1lA7Y5Tg0Vt0BeoxwjXD36nmxWnQXRxDZuI
	Ba0dq+Wt6ydTJVD+HrhWyl377txBncMXrQjhSQZItCwBITrlJSV7+Nl3bag==
X-Received: by 2002:a05:600c:1395:b0:495:6b8f:7e7a with SMTP id 5b1f17b1804b1-496b564afa3mr57538615e9.0.1785070039550;
        Sun, 26 Jul 2026 05:47:19 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::5])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-496b49a5f98sm143619745e9.12.2026.07.26.05.47.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 26 Jul 2026 05:47:19 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	nicholas.wolff@truenas.com,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH] nfsd: fix race between client_info_show() and free_client()
Date: Sun, 26 Jul 2026 17:46:58 +0500
Message-ID: <20260726124658.1715711-1-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

client_info_show() renders /proc/fs/nfsd/clients/<id>/info and walks
clp->cl_sessions under clp->cl_lock to print each session's slot
counts.  free_client() tears down the same list without taking
cl_lock, and is the only unlocked mutator of cl_sessions.  A reader
can observe a client mid-teardown because get_nfsdfs_clp() pins the
nfs4_client but not its sessions: free_client() frees every session
before calling nfsd_client_rmdir(), so an in-flight seq_file reader
can follow a list_del()'d node whose ->next now holds LIST_POISON1
and take a general protection fault:

  Oops: general protection fault, probably for non-canonical address
        0xdead00000000014c
  CPU: 1 UID: 0 PID: 132488 Comm: cat
  RIP: 0010:client_info_show+0x2bf/0x3d0
  RAX: dead000000000100
  Call Trace:
   seq_read_iter+0x12a/0x4b0
   seq_read+0xf1/0x130
   vfs_read+0xbf/0x350
   ksys_read+0x6f/0xf0
   do_syscall_64+0x8b/0xcb0
   entry_SYSCALL_64_after_hwframe+0x76/0x7e
  Kernel panic - not syncing: Fatal exception

Detach cl_sessions onto a local reaplist under cl_lock, then free the
sessions after dropping the lock.  Removing entries from cl_sessions
under cl_lock matches unhash_session(), and the detach-then-reap shape
matches how __destroy_client() reaps cl_delegations.  The sessions
cannot be freed while cl_lock is held, since free_session() calls
nfsd4_del_conns(), which re-acquires it.

Reported-by: Nicholas Wolff <nicholas.wolff@truenas.com>
Fixes: 601c8cb349c2 ("nfsd: add session slot count to /proc/fs/nfsd/clients/*/info")
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
Reproducer, on a throwaway NFSv4.1 server (panics within a couple of
minutes without this patch):

  sysctl -w kernel.panic_on_oops=1
  mkdir -p /export /mnt/loopback
  echo '/export 127.0.0.1(rw,no_root_squash,fsid=0)' >/etc/exports
  systemctl start nfs-server; exportfs -ra
  mount -t nfs -o vers=4.1 127.0.0.1:/ /mnt/loopback

  for i in $(seq $(nproc)); do
      ( while :; do cat /proc/fs/nfsd/clients/*/info >/dev/null 2>&1; done ) &
  done

  shopt -s nullglob
  while :; do
      ls /mnt/loopback >/dev/null 2>&1
      for c in /proc/fs/nfsd/clients/*/; do printf 'expire\n' >"${c}ctl"; done
  done

The "expire" write is what drives free_client(); a reader-only loop
does not reproduce this. panic_on_oops is needed because the fault
happens while the reader holds cl_lock.

 fs/nfsd/nfs4state.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d7731bb4959c..d93672e6fa26 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2791,10 +2791,16 @@ void nfsd4_put_client(struct nfs4_client *clp)
 static void
 free_client(struct nfs4_client *clp)
 {
-	while (!list_empty(&clp->cl_sessions)) {
+	LIST_HEAD(reaplist);
+
+	/* client_info_show() walks cl_sessions under cl_lock */
+	spin_lock(&clp->cl_lock);
+	list_splice_init(&clp->cl_sessions, &reaplist);
+	spin_unlock(&clp->cl_lock);
+	while (!list_empty(&reaplist)) {
 		struct nfsd4_session *ses;
-		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
-				se_perclnt);
+		ses = list_entry(reaplist.next, struct nfsd4_session,
+				 se_perclnt);
 		list_del(&ses->se_perclnt);
 		WARN_ON_ONCE(atomic_read(&ses->se_ref));
 		free_session(ses);

base-commit: 8d4fbec07074c98f4b16c7e38964227fdf4d5cd3
-- 
2.53.0

