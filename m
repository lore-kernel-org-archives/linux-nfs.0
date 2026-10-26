Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.219.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793059034;
	b=VYQASiMHHWx4PD4XlI+1GZHRJii6BN9DIbAHYOlrXtg1fqI545mzmIz79xBRifVOlK7z
	 fFFeiA8aNdks4pXvAgPRolNp9ofgIHB55f6pWKv5ymB/IBY8UbV4sMKIQOFetvz6Hg7W+
	 WJVK9DBSMu83lkPP8Uyhxkka3kwcA/TNqoEj7EowThR+tKOshMqHsUC01eyFu5bDUxQBG
	 4AsyXUsKgm6tJWKfAcNz882sNBDJP2EjUzuF/FXqLlLDih5h0EjZqEO2dWTOuKo7xdA9q
	 BKpbMzxxC1OgPB2/icScpNfEcXSrUIAJldDaZQp2Ni4NjeCwCZrrqb+Clf1q6Omfgug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793059034;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=qDIKx2Op6aSLUbez/797DuVnzQCw0y2by19BWYigguE=;
	b=Y7WxZXSmijjLrN7tCaiReWiKsjXk5Qrcr2QwqyunUbeIRNcyKq5qFPZ/xCBe4NPEsxe4
	 inyBqPYTs4/J0SooVUzT87ps0m3G5xD8x+WB/XlgRhaQo4fCfsXH2VVbJY3b9e/uQGqVA
	 jEMGZBgYqDqIrCMNsIMFWrrI2KZPLO7yf+iP7AJ4dnPREixuvWwJWzXLUpDuJGDb9Huwt
	 C5m9PbBJYvW3Nu1NB9KSgQsveNTdu2BeooN17KvJMf6qz40fGqjMpdGd4iBeN2/+GZYH8
	 Kt6bk/e+daiswaWwir9Y71QYrCd9IsGO9LhZ5JKUtBzmTjKAqJlilbbYDqyXoryNRqA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=Iak8vfcQ;
	arc=none smtp.remote-ip=209.85.219.47
Received: from mail-qv1-f47.google.com (mail-qv1-f47.google.com [209.85.219.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17DC6606A31D
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 23:57:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 17DC6606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=Iak8vfcQ
Received: by mail-qv1-f47.google.com with SMTP id 6a1803df08f44-91b89c6caffso28645766d6.2
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 16:57:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793059033; x=1793663833; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=qDIKx2Op6aSLUbez/797DuVnzQCw0y2by19BWYigguE=;
        b=Iak8vfcQjHrDPwgQ6ujDpPm2w85Fejjtj5b68bZf8Kj1152YR6lk8u/qfNFnfWa6aT
         r+KT97wPb8ErZD8+MYStSX8iWx4LCW6/GOfeSYoMfmKwaHjQGn2ZsFkzrRT6eQJITsxM
         I2wFhWIjq1sDrASOUfFNtqJ2ygtqju0UOC/O1xL9jSehAaSGhF/ZYlPIJHAJ0Qy7OFtO
         CNIM0kcfjWR1bozkvCAuFFVZbphBqYsgt6PtXAKune2U1c4VYL9b33DTFsYCgQWlHbpF
         ytPxeNguoQVhpDQa4DuXvUfLHku/wL2Q3yWLpz+44dbreFarrSkFZV58Ulj2jbKPaPkS
         TYBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793059033; x=1793663833;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=qDIKx2Op6aSLUbez/797DuVnzQCw0y2by19BWYigguE=;
        b=Y81LCZHeT4fzOLc3Qbo8HO07d4J06eHfYrim12jNvURkjdeen9sjTW0HsIY5Tyrw6r
         JAMb0FzlRgDU9ZrUapPJz3YvOqUSFbZqoJqV+cQmMS/72wb4VTx8gZMse3nliLYLqPtg
         RLwNUPJgO3N8jhagTBuJzYqDOqPsaO188FNif6Yvz2IrC+xXfmduBKP9hx25nfYmCbjh
         E4FfMsX05pwrDR5MULlkj42WteFU5QKtd/9gFHaKUbADD5spR0E2v1oZzvuAzXoPrA5I
         YLY7NqvXpqv4gnAlB77IW0086Ol4/oDmnhbfiRklcMglAXvSAbY1+GX7m/vQQWQTb0hs
         +/Cw==
X-Forwarded-Encrypted: i=1; AKwUvBz9JJRz/1ST8wqxSuKz/v+hmPArd74mU0+3tCaWCF0qqXOJG1ywpqJuj2719UWgogakpTmL9zgqorU=@vger.kernel.org
X-Gm-Message-State: AFq9FYI5QmtJOwrlsOTD5SzBjTe+yZAXPsLuTmcYThzxuQud07dSP4Yj
	JbYek0nHAq0dq2arnhapopZk0Mzu5iWIvU/UEPWeFDTekrp41UY67GaX
X-Gm-Gg: AYBFou00H2LryxcREtl132VqyPIZuKj7aN9bQhJ9W2afZDTZsLko4aKCZwlQby2/+BY
	Z4ZwJh4OueYK/8WiX61ozSvZN8HmcGigXg+tCL4cg/IVQ+eDNZDM1Z32whXtyNoQC73+gN90lo6
	DaJ66/nfe1Yzw+ocA6oadEVtBBbvW3CL2XgeTfWBVbHCGrPLB+lHTJ5+KFrLuSSTw5qeex5A6k6
	79rbd9LsYKNhnMMooxoiJ+O9hdwN4MEHKp7Xk0ypJJtwj9J1NWkkXVuazN6xVvCKvoX8S1BUpXs
	GoEsXhMyCO4u7VrIcsS2t4W7S7JNBC13XEIpHEqiD7V8FSCOMqXDDrEdGBONpXC+6k0klTErwRQ
	IXmSjDOlJIVB3nhfEyQmUc7VOjSIO/XRDZrCHCquNAn5L9xy5wTkrQyGJgZQQCACZXuDlc2ARGS
	CpMgdqLd4ziX5IEuNE5A5LOOWNNCeMr2FAcrVD1ZF4lheEGSFQIVmE21OrYcmeKGshPrIZXqxbS
	D5SMuTesGsE1LfGfwag5R7izZ3tBYW3Qubg++UY2rZ8KhpdX9nQNg/i0a1J7geFvt3oIr2lL4np
	iew5BmON2/qQl1Zkgl2PMqjcDD2LS3E=
X-Received: by 2002:a05:620a:8702:20b0:940:f224:5a63 with SMTP id af79cd13be357-940f2245db0mr872745185a.64.1793059032925;
        Mon, 26 Oct 2026 16:57:12 -0700 (PDT)
Received: from i4-l-hqh5357-03.ad.psu.edu ([130.203.139.71])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-940f0787f33sm823849485a.25.2026.10.26.16.57.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 16:57:11 -0700 (PDT)
From: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Shuangpeng Bai <shuangpeng.kernel@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH] nfsd: shut down running servers in nfsd_net_exit()
Date: Mon, 26 Oct 2026 19:56:26 -0400
Message-ID: <20261026235626.649844-1-shuangpeng.kernel@gmail.com>
X-Mailer: git-send-email 2.43.0
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

Since commit 924f4fb003ba ("NFSD: convert write_threads to netlink
command") the server can be started over netlink without mounting the
nfsd filesystem. But that mount was the only thing pinning the module
while threads run (commit f49169c97fce ("NFSD: Remove
svc_serv_ops::svo_module") removed the per-thread reference), and
nfsd_umount() is the only caller of nfsd_shutdown_threads().

So when the server has been started via netlink, a plain "rmmod nfsd"
succeeds while the threads are still running. exit_nfsd() then frees
struct nfsd_net in unregister_pernet_subsys(), destroys the DRC slab
and finally unmaps the module text underneath the running threads:

  BUG: KASAN: slab-use-after-free in nfsd_file_net_dispose (fs/nfsd/filecache.c:483) nfsd
  Read of size 8 at addr ffff888109fe92d0 by task nfsd/300
  Call Trace:
   nfsd_file_net_dispose (fs/nfsd/filecache.c:483) nfsd
   nfsd (fs/nfsd/nfssvc.c:957) nfsd
   kthread (kernel/kthread.c:436)
   ret_from_fork (arch/x86/kernel/process.c:158)
  Freed by task 311:
   kfree (mm/slub.c:6802)
   ops_undo_list (net/core/net_namespace.c:257)
   unregister_pernet_operations (net/core/net_namespace.c:1412)
   unregister_pernet_subsys (net/core/net_namespace.c:1459)
   cleanup_module nfsd
   __se_sys_delete_module (kernel/module/main.c:804)

followed by a general protection fault in nfsd_cache_lookup() as soon
as a thread allocates from the destroyed drc_slab.

Shut down a server that is still running for a net namespace in
nfsd_net_exit(), which is invoked for every net namespace when the
module is unloaded. nfsd_shutdown_threads() is a no-op when no server
exists, so nothing changes for the common case. As the laundromat
work is queued on laundry_wq until the server is shut down, destroy
that workqueue after unregister_pernet_subsys().

To reproduce: start the server with nfsdctl (or any other netlink
client) without mounting the nfsd filesystem, then run "rmmod nfsd".

Fixes: 924f4fb003ba ("NFSD: convert write_threads to netlink command")
Cc: stable@vger.kernel.org # v6.10+
Signed-off-by: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
---
Tested on top of 7.3-rc7 with KASAN and with PROVE_LOCKING: with the
server started over netlink and an NFSv3 request in flight, "rmmod nfsd"
now waits for the request to complete and unloads cleanly; starting and
stopping the server via netlink and via the nfsd filesystem still works.

An alternative would be to take a module reference while a server
exists so that rmmod fails with EBUSY, as it does while the nfsd
filesystem is mounted. Stopping the server in nfsd_net_exit() seemed
simpler and mirrors what nfsd_umount() does, but I am happy to rework
it if the other behaviour is preferred.
 fs/nfsd/nfsctl.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f32311f2d7cf..0a9679114b58 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -3113,6 +3113,7 @@ static __net_exit void nfsd_net_exit(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
+	nfsd_shutdown_threads(net);
 	kfree_sensitive(nn->fh_key);
 	nfsd_net_cb_shutdown(nn);
 	nfsd_proc_stat_shutdown(net);
@@ -3200,9 +3201,9 @@ static void __exit exit_nfsd(void)
 	remove_proc_entry("fs/nfs", NULL);
 	genl_unregister_family(&nfsd_nl_family);
 	unregister_filesystem(&nfsd_fs_type);
-	nfsd4_destroy_laundry_wq();
 	unregister_cld_notifier();
 	unregister_pernet_subsys(&nfsd_net_ops);
+	nfsd4_destroy_laundry_wq();
 	nfsd_drc_slab_free();
 	nfsd_lockd_shutdown();
 	nfsd4_exit_pnfs();
-- 
2.43.0

