Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 240D73382C9
	for <linux-nfs@vger.kernel.org>; Mon,  8 Jun 2026 13:14:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780924448; cv=none; b=fdtqAoDK1DaWYlcMn5f0P7nghRXrdkYXOYTmWrJZdbBLamCbBcxQcGzH7NKUSK5kGRRHxc5iyKkClDMTzpZr1KPR/9GbNrA/IOQoV60wZ1JOWKCYJCc+xxgWmtIQnxjhaQFclTW6ieCdU66Ye2CL2q6eHYDmpGgGUjwuODhDd+M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780924448; c=relaxed/simple;
	bh=9mR7UwlzWDps0LiBud4oncynHZhTvcOtvaZm1GQGNnQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=aPQKwXFdFJeGaKuHA31S2iKvPfmA4PfDJaf333KCVjWke3o7llnifaxQB1IdbHvQRl0e7MeQviudkaC+aBk/Ul57TlwE6NlXy6l4FWGaZz+vLuZ/9PHTiHSpb8/q+mVaXCfMcAVscXFcaQdi6yhC7uKPJ7/rAG5BaMmfYcJzafI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Hh66D3Se; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Hh66D3Se"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1780924446;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=zooWuExXP1EnT2yNqdXCzwaT3WFFS1pYMkomk7+hLDA=;
	b=Hh66D3SeaDnNX4lZkbEukINZ1EPeHd9DMJgXNEEqQd2JXTJ07lPlDtTKcD0LhN1bKQi6ki
	PmUzsRN2Hn/i5qZUJq2rrsx5nyRQJcRTWCN89df+OMaB1UJeoXHD0Dr45PgVl+LLOqpxqE
	HZO8EId6gvE5rhfKKMeq3EtKfgEU7ks=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-102-X1IHWoVmP8GPKxDfWudg7w-1; Mon,
 08 Jun 2026 09:14:04 -0400
X-MC-Unique: X1IHWoVmP8GPKxDfWudg7w-1
X-Mimecast-MFC-AGG-ID: X1IHWoVmP8GPKxDfWudg7w_1780924443
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7AE391955DE2;
	Mon,  8 Jun 2026 13:14:03 +0000 (UTC)
Received: from aion.redhat.com (unknown [10.22.80.22])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 41993D6E;
	Mon,  8 Jun 2026 13:14:03 +0000 (UTC)
Received: from aion.redhat.com (localhost [IPv6:::1])
	by aion.redhat.com (Postfix) with ESMTP id 5FF1E91832A;
	Mon, 08 Jun 2026 09:14:02 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: chuck.lever@oracle.com,
	jlayton@kernel.org
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: fix up error returned by write_threads()
Date: Mon,  8 Jun 2026 09:14:02 -0400
Message-ID: <20260608131402.95625-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Previously, writing 0 to /proc/fs/nfsd/threads would return 0 if the NFS
server wasn't running.  After commit 14282cc3cfa2, -EIO is returned.
Existing scripts don't expect this behavior.

Add a check to bypass the call to nfsd_svc() when newthreads is 0 and
the NFS server is already stopped.

Fixes: 14282cc3cfa2 ("NFSD: don't start nfsd if sv_permsocks is empty")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfsctl.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 04e3954d54bd..ed1a06b4edcd 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -419,6 +419,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 	char *mesg = buf;
 	int rv;
 	struct net *net = netns(file);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (size > 0) {
 		int newthreads;
@@ -429,7 +430,10 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 			return -EINVAL;
 		trace_nfsd_ctl_threads(net, newthreads);
 		mutex_lock(&nfsd_mutex);
-		rv = nfsd_svc(1, &newthreads, net, file->f_cred, NULL);
+		if (newthreads > 0 || nn->nfsd_serv != NULL)
+			rv = nfsd_svc(1, &newthreads, net, file->f_cred, NULL);
+		else
+			rv = 0;
 		mutex_unlock(&nfsd_mutex);
 		if (rv < 0)
 			return rv;
-- 
2.54.0

