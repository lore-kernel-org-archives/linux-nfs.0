Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45A724E06D4;
	Wed, 23 Sep 2026 16:14:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790180090; cv=none; b=HWaOJ19u+9Ilr637HGu7TeqHkTSS+tx9cPEAqHy0CLIXfaPc6K69onCRpQr41sUPbqHRbGK5bGlkD8VLh7o+P6CiCwiaXjaX8E3Wr1SZHmp8t4QAsd/OslzQO0bgQMAbwRYQS7rIbvLjNK2JUufNI5sxJP+NxjlCTV+X/noxBmo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790180090; c=relaxed/simple;
	bh=KKlF+cMfhTu1jnO9IR6uctLBr7i2ixQHoIFRC2g/z4s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=OOYNaFkxuNFttFWcJUeAxBUo+zRtZLLseLn5sgMBaVBX458f3gPlWtSWEMlik4W9LT60deKBPRC0+SQLlXE/kFwWj98xSkielaADS3fPNeo3S+ifzG7xuifb6+G3FaAG99bA5RkV7pogPTmAPtG3U+5Znps3MVCLthGk8mNZ92E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AU+uBszu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AU+uBszu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5525D1F00899;
	Wed, 23 Sep 2026 16:14:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790180089;
	bh=SZT12UzBx+FqQj7frSYwNw/KZpZf7ii5T5hx4pO2pjw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=AU+uBszu/wY06iKRcCfQtTbAvPM4/UdTAn8TyK9K3Fly6O9kTHw2zHydrJ67Am71a
	 E45tbXSK0R8YqWVX5VnUndDtmfgtR1Z2MCW0NRW8HecD84ZInhWSKpnj1XsYAWjPP2
	 chrHrGpvLET+dg5ix/uPavPVX0EPO9xQYPT95pl3pd2cRW4A+RggX1WR9un3DIjKFG
	 YojQUhg6aaOmjuiUjkMYvniLHqbbuwvm0GRYU0YztyqYNDsN+YJg+GDtEYuyLQRU4o
	 wivx5o1mPS1fSkSlsF85gKoTmGJCzvsLGnS+w9D/6UrslDZbWgl5RGROlTJq1nHXqA
	 hBL4RmRaT/2kw==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 23 Sep 2026 12:14:21 -0400
Subject: [PATCH 1/2] nfsd: remove the nfsdcltrack usermodehelper tracking
 backend
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260923-nfsd-legacy-v1-1-8490c0c12ea5@kernel.org>
References: <20260923-nfsd-legacy-v1-0-8490c0c12ea5@kernel.org>
In-Reply-To: <20260923-nfsd-legacy-v1-0-8490c0c12ea5@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=10479; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=KKlF+cMfhTu1jnO9IR6uctLBr7i2ixQHoIFRC2g/z4s=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs/r2KZpTpT6YIKdINWJa6qYCr8NvJJCsp1ONi
 cIC6DBMOUaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarP69gAKCRAADmhBGVaC
 FUmtEACiokObwKc5nY/n5ToeSLFfm0K2x2p2vwUVCFrkbKm8/eJeF64kKWyvs3j69+UCKBrV2+1
 UtHAhM2PtJt14I6D12o8VO1eStO67lS5DBfrAhIOdufi1Bt1wmSApDbXgjTtkY37Z18Vm0gOc+r
 /WnOSOpLNEuYsS0YNHSkORkm6qvz6T1nrvFGjJm0QV8QXLtDVIYAwS2L9iyPy04Mzsp79tYvosF
 MwabeUjMTi6fwiFxzFkz7/B7nnAyb/smxcNt9L/wcg9dQaKjvRr6z5D3w97UReiYb9H4LsuO+PC
 9F5F0Otx/9VMCIAk5A9fPFVUskSDrYa6PsG9aXXgUkQ/EEpRlOcMQjPWgGt5WEcT4p2siNmgQFl
 xF4sA82ZQi+FFHdVtL0hyk/AJ77NiPi5EliUzw9Pk6K1BtTpaUCRiYhEYCAbJvCP3HXGa4hNXGq
 nZIDtRqsf7TYkH0RUQEqDCk07RGFhxNL/k5g9iPC1e+ZmIoSbKpk02Y0JhYudqwZWavtTh0YRjB
 J6uuMqIsjp/x2UfN0QEGOY9pqzqUazNvBIYqUGrcW4KOuYGAu12kLV0S4OLtcw9WoPvAlooC0ji
 TppjF+Hhh1SzxEoKLKuHLTBlZWWBhN8abUo7HQGbG9I3JSTCsn414g1tWZR9Z7YZtt3UeriIVSE
 NSFc06VG+d2ILTA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The usermodehelper upcall to /sbin/nfsdcltrack was deprecated with the
rest of the legacy client tracking methods. It never worked in
containers and nfsdcld has superseded it. Remove the backend and the
cltrack_prog and cltrack_legacy_disable module parameters.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4recover.c | 347 +-------------------------------------------------
 1 file changed, 1 insertion(+), 346 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 5e7788e3fb79..ecf8ced8074a 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1611,358 +1611,13 @@ static const struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops_v2 = {
 };
 
 #ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-/* upcall via usermodehelper */
-static char cltrack_prog[PATH_MAX] = "/sbin/nfsdcltrack";
-module_param_string(cltrack_prog, cltrack_prog, sizeof(cltrack_prog),
-			S_IRUGO|S_IWUSR);
-MODULE_PARM_DESC(cltrack_prog, "Path to the nfsdcltrack upcall program");
-
-static bool cltrack_legacy_disable;
-module_param(cltrack_legacy_disable, bool, S_IRUGO|S_IWUSR);
-MODULE_PARM_DESC(cltrack_legacy_disable,
-		"Disable legacy recoverydir conversion. Default: false");
-
-#define LEGACY_TOPDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_TOPDIR="
-#define LEGACY_RECDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_RECDIR="
-#define HAS_SESSION_ENV_PREFIX "NFSDCLTRACK_CLIENT_HAS_SESSION="
-#define GRACE_START_ENV_PREFIX "NFSDCLTRACK_GRACE_START="
-
-static char *
-nfsd4_cltrack_legacy_topdir(void)
-{
-	int copied;
-	size_t len;
-	char *result;
-
-	if (cltrack_legacy_disable)
-		return NULL;
-
-	len = strlen(LEGACY_TOPDIR_ENV_PREFIX) +
-		strlen(nfs4_recoverydir()) + 1;
-
-	result = kmalloc(len, GFP_KERNEL);
-	if (!result)
-		return result;
-
-	copied = snprintf(result, len, LEGACY_TOPDIR_ENV_PREFIX "%s",
-				nfs4_recoverydir());
-	if (copied >= len) {
-		/* just return nothing if output was truncated */
-		kfree(result);
-		return NULL;
-	}
-
-	return result;
-}
-
-static char *
-nfsd4_cltrack_legacy_recdir(const struct xdr_netobj *name)
-{
-	int copied;
-	size_t len;
-	char *result;
-
-	if (cltrack_legacy_disable)
-		return NULL;
-
-	/* +1 is for '/' between "topdir" and "recdir" */
-	len = strlen(LEGACY_RECDIR_ENV_PREFIX) +
-		strlen(nfs4_recoverydir()) + 1 + HEXDIR_LEN;
-
-	result = kmalloc(len, GFP_KERNEL);
-	if (!result)
-		return result;
-
-	copied = snprintf(result, len, LEGACY_RECDIR_ENV_PREFIX "%s/",
-				nfs4_recoverydir());
-	if (copied > (len - HEXDIR_LEN)) {
-		/* just return nothing if output will be truncated */
-		kfree(result);
-		return NULL;
-	}
-
-	nfs4_make_rec_clidname(result + copied, name);
-
-	return result;
-}
-
-static char *
-nfsd4_cltrack_client_has_session(struct nfs4_client *clp)
-{
-	int copied;
-	size_t len;
-	char *result;
-
-	/* prefix + Y/N character + terminating NULL */
-	len = strlen(HAS_SESSION_ENV_PREFIX) + 1 + 1;
-
-	result = kmalloc(len, GFP_KERNEL);
-	if (!result)
-		return result;
-
-	copied = snprintf(result, len, HAS_SESSION_ENV_PREFIX "%c",
-				clp->cl_minorversion ? 'Y' : 'N');
-	if (copied >= len) {
-		/* just return nothing if output was truncated */
-		kfree(result);
-		return NULL;
-	}
-
-	return result;
-}
-
-static char *
-nfsd4_cltrack_grace_start(time64_t grace_start)
-{
-	int copied;
-	size_t len;
-	char *result;
-
-	/* prefix + max width of int64_t string + terminating NULL */
-	len = strlen(GRACE_START_ENV_PREFIX) + 22 + 1;
-
-	result = kmalloc(len, GFP_KERNEL);
-	if (!result)
-		return result;
-
-	copied = snprintf(result, len, GRACE_START_ENV_PREFIX "%lld",
-				grace_start);
-	if (copied >= len) {
-		/* just return nothing if output was truncated */
-		kfree(result);
-		return NULL;
-	}
-
-	return result;
-}
-
-static int
-nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *env0, char *env1)
-{
-	char *envp[3];
-	char *argv[4];
-	int ret;
-
-	if (unlikely(!cltrack_prog[0])) {
-		dprintk("%s: cltrack_prog is disabled\n", __func__);
-		return -EACCES;
-	}
-
-	dprintk("%s: cmd: %s\n", __func__, cmd);
-	dprintk("%s: arg: %s\n", __func__, arg ? arg : "(null)");
-	dprintk("%s: env0: %s\n", __func__, env0 ? env0 : "(null)");
-	dprintk("%s: env1: %s\n", __func__, env1 ? env1 : "(null)");
-
-	envp[0] = env0;
-	envp[1] = env1;
-	envp[2] = NULL;
-
-	argv[0] = (char *)cltrack_prog;
-	argv[1] = cmd;
-	argv[2] = arg;
-	argv[3] = NULL;
-
-	ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
-	/*
-	 * Disable the upcall mechanism if we're getting an ENOENT or EACCES
-	 * error. The admin can re-enable it on the fly by using sysfs
-	 * once the problem has been fixed.
-	 */
-	if (ret == -ENOENT || ret == -EACCES) {
-		dprintk("NFSD: %s was not found or isn't executable (%d). "
-			"Setting cltrack_prog to blank string!",
-			cltrack_prog, ret);
-		cltrack_prog[0] = '\0';
-	}
-	dprintk("%s: %s return value: %d\n", __func__, cltrack_prog, ret);
-
-	return ret;
-}
-
-static char *
-bin_to_hex_dup(const unsigned char *src, int srclen)
-{
-	char *buf;
-
-	/* +1 for terminating NULL */
-	buf = kzalloc((srclen * 2) + 1, GFP_KERNEL);
-	if (!buf)
-		return buf;
-
-	bin2hex(buf, src, srclen);
-	return buf;
-}
-
-static int
-nfsd4_umh_cltrack_init(struct net *net)
-{
-	int ret;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	char *grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
-
-	/* XXX: The usermode helper s not working in container yet. */
-	if (net != &init_net) {
-		pr_warn("NFSD: attempt to initialize umh client tracking in a container ignored.\n");
-		kfree(grace_start);
-		return -EINVAL;
-	}
-
-	ret = nfsd4_umh_cltrack_upcall("init", NULL, grace_start, NULL);
-	kfree(grace_start);
-	if (!ret)
-		pr_info("NFSD: Using UMH upcall client tracking operations.\n");
-	return ret;
-}
-
-static void
-nfsd4_cltrack_upcall_lock(struct nfs4_client *clp)
-{
-	wait_on_bit_lock(&clp->cl_flags, NFSD4_CLIENT_UPCALL_LOCK,
-			 TASK_UNINTERRUPTIBLE);
-}
-
-static void
-nfsd4_cltrack_upcall_unlock(struct nfs4_client *clp)
-{
-	clear_and_wake_up_bit(NFSD4_CLIENT_UPCALL_LOCK, &clp->cl_flags);
-}
-
-static void
-nfsd4_umh_cltrack_create(struct nfs4_client *clp)
-{
-	char *hexid, *has_session, *grace_start;
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	/*
-	 * With v4.0 clients, there's little difference in outcome between a
-	 * create and check operation, and we can end up calling into this
-	 * function multiple times per client (once for each openowner). So,
-	 * for v4.0 clients skip upcalling once the client has been recorded
-	 * on stable storage.
-	 *
-	 * For v4.1+ clients, the outcome of the two operations is different,
-	 * so we must ensure that we upcall for the create operation. v4.1+
-	 * clients call this on RECLAIM_COMPLETE though, so we should only end
-	 * up doing a single create upcall per client.
-	 */
-	if (clp->cl_minorversion == 0 &&
-	    test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
-		return;
-
-	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
-	if (!hexid) {
-		dprintk("%s: can't allocate memory for upcall!\n", __func__);
-		return;
-	}
-
-	has_session = nfsd4_cltrack_client_has_session(clp);
-	grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
-
-	nfsd4_cltrack_upcall_lock(clp);
-	if (!nfsd4_umh_cltrack_upcall("create", hexid, has_session, grace_start))
-		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
-	nfsd4_cltrack_upcall_unlock(clp);
-
-	kfree(has_session);
-	kfree(grace_start);
-	kfree(hexid);
-}
-
-static void
-nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
-{
-	char *hexid;
-
-	if (!test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
-		return;
-
-	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
-	if (!hexid) {
-		dprintk("%s: can't allocate memory for upcall!\n", __func__);
-		return;
-	}
-
-	nfsd4_cltrack_upcall_lock(clp);
-	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags) &&
-	    nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL) == 0)
-		clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
-	nfsd4_cltrack_upcall_unlock(clp);
-
-	kfree(hexid);
-}
-
-static int
-nfsd4_umh_cltrack_check(struct nfs4_client *clp)
-{
-	int ret;
-	char *hexid, *has_session, *legacy;
-
-	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
-		return 0;
-
-	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
-	if (!hexid) {
-		dprintk("%s: can't allocate memory for upcall!\n", __func__);
-		return -ENOMEM;
-	}
-
-	has_session = nfsd4_cltrack_client_has_session(clp);
-	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
-
-	nfsd4_cltrack_upcall_lock(clp);
-	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags)) {
-		ret = 0;
-	} else {
-		ret = nfsd4_umh_cltrack_upcall("check", hexid, has_session, legacy);
-		if (ret == 0)
-			set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
-	}
-	nfsd4_cltrack_upcall_unlock(clp);
-	kfree(has_session);
-	kfree(legacy);
-	kfree(hexid);
-
-	return ret;
-}
-
-static void
-nfsd4_umh_cltrack_grace_done(struct nfsd_net *nn)
-{
-	char *legacy;
-	char timestr[22]; /* FIXME: better way to determine max size? */
-
-	sprintf(timestr, "%lld", nn->boot_time);
-	legacy = nfsd4_cltrack_legacy_topdir();
-	nfsd4_umh_cltrack_upcall("gracedone", timestr, legacy, NULL);
-	kfree(legacy);
-}
-
-static const struct nfsd4_client_tracking_ops nfsd4_umh_tracking_ops = {
-	.init		= nfsd4_umh_cltrack_init,
-	.exit		= NULL,
-	.create		= nfsd4_umh_cltrack_create,
-	.remove		= nfsd4_umh_cltrack_remove,
-	.check		= nfsd4_umh_cltrack_check,
-	.grace_done	= nfsd4_umh_cltrack_grace_done,
-	.version	= 1,
-	.msglen		= 0,
-};
-
 static inline int check_for_legacy_methods(int status, struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct path path;
 
 	/*
-	 * Next, try the UMH upcall.
-	 */
-	nn->client_tracking_ops = &nfsd4_umh_tracking_ops;
-	status = nn->client_tracking_ops->init(net);
-	if (!status)
-		return status;
-
-	/*
-	 * Finally, See if the recoverydir exists and is a directory.
+	 * See if the recoverydir exists and is a directory.
 	 * If it is, then use the legacy ops.
 	 */
 	nn->client_tracking_ops = &nfsd4_legacy_tracking_ops;

-- 
2.55.0

