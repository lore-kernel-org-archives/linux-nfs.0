Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814564;
	b=fxVj7h3nhmHX4m5MySBg7+oEulai9O0TTA5GKE8qB/1d3X/EPl3SK8KJLek/GYuiSw5D
	 RQOKzsranEihu+/6+qT+D213ZONlKejWqcSi2iRj5Z2Zs10caXLK4A8bq0ToGigMXhcJx
	 WNKAD89mpH0uULCed0t8TWYwknJJomlYZ37r0rqw/TzEeqy+ErIR8hmDogqKvrx+z3+nV
	 HSELengHnpdFMO+SeUis802BC8zpb4s7Eksq/0oueVJWbdHeIrt2MQAceRLeh9SnqlyAD
	 tWv5QztGQRd4GwxBZPwYD4mVmXLt6gTbvAPHzKZ1inAk7GMsZrGiiu+iXp3FOd3mUag==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814564;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=CrNFqpvPwyR7e41jJyNAphYrCo4pmtHEPkKiU2zoov8=;
	b=tY2koSSWlfRyOgdI5Iq+B5QljV7PoHKxpPTCvTZZ2j6dh7XxFPS5Mrn/Str5PefFxZa4
	 qNoE6yRQ4OWGlLs3okOqsomFWEHz09irQCP74gvaLwFaxJa4YCTUJS6f2DD++XCvjrCbx
	 uaP+dxzHYbUb7Th1sNQdfI0pstEJUvjvyPfjO6MRs9d66VfzuOKpPYE2vIfP4b48mkJxd
	 X2pJdkPowBpCGo9BUbKdnBOrrLj8Ebg+Wlo61CAbmCy8MLlZQ4R8VA8rG0+ngFAx8UD5d
	 6OKjS03FCOFvM4gNEd+O2MMnAmu7aTj+fsS23OnHgosRwgkhi51lRR/hr7GD0ABHTHA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R2YfLnxj;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1511860A6F66;
	Wed,  4 Nov 2026 17:49:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R2YfLnxj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3F9C1F000C1;
	Wed,  4 Nov 2026 17:49:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814563;
	bh=CrNFqpvPwyR7e41jJyNAphYrCo4pmtHEPkKiU2zoov8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=R2YfLnxjdA65s1qPxKTfubG+5NCrCw6r1mD2ObJyVTVTqIXaOJKLWLxLLGHWvvie7
	 SpXVTF5Lc+U//czSYiGBRTsmXlDwGobiiH7z8N/zwUXdde1fhbcbrsBQ/XRGDRdCBD
	 jeam7Z0pXsF48J7wqoSePaUxod2iND63lrwVSOrtIZ9sn8ptJL+qPyD7pYYTAmwTuW
	 ouRTGlzJA9tLoqf/phhPLlbwP4KKISypeXf5cgon/BlXoHFYB0FliF9ZdodFqV+bcC
	 nxReoeH8pGCVrOK83Uvm3GN5uF77kjaQjD3lZFbof6sVP/XrCgKVcHF6Ro4U5CilNR
	 /7bp0zaEEvsbA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 12:49:05 -0500
Subject: [PATCH 1/5] SUNRPC: Reject add_xprt on a backchannel xprt_switch
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261104-liange-v1-1-f097e10cea1b@kernel.org>
References: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
In-Reply-To: <20261104-liange-v1-0-f097e10cea1b@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Wentao Liang <vulab@iscas.ac.cn>, linux-nfs@vger.kernel.org, 
 linux-rdma@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1614; i=cel@kernel.org;
 h=from:subject:message-id; bh=E2iiR5OLFEnMPe6bzYXs9q2OGvjjL5gkhhIcdhsO2iM=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGrrcCChdgMSs7XkF94b/KwVJXTu8M4NGUt6UX21WgTIFq6zt
 YkCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJq63AgAAoJEDNqszNvZn+XUdMQAKcR
 4Dn34EYTrqucW/q02UAjYtjaFvGgzO8vFXzu2MT9q/D/Fxp2asqqkLz4UoHhQQGpeJDMlkWyJAT
 rOFETeZcNtxBxrVScDaTWK5mmj9C8S/EkfSb4plM1EcQpXGvUBOkgtL7HHXhDHP2yqhx6T5oJcH
 ShIVB0+SacUZRzW/3OWZz9DdEGtiUSvgfE9hSsgNSLx84zFxk7LcuR3KDuXWLerSaPgO0QSBDII
 Px3QAdlSsQVVm2agymQFm6s8wMwezEz8MK8u5N2acSEdE89QGHyGAIIv9EqG9ECOffLvSBRz5AL
 gij9sHVTi3LfHgJQpjUkacUR4UDN+ezPbrTrT+j6Z3EsvdwIoHuCIWM46LwzdfejDJBwR05NvYD
 VLFjIQ36iaqdKt4j9AcNlOk7COCli3zyKEO49fbafjmMw+WOpGnttONZVDIw7TjnFgeQ9P2B1vR
 m89H6tNe1otRWPBdzp/WJZbtaKjPMAoP/ecedxkpDu//2NTFDjw7HXr8bpYOgAHiSpRBnuwF6A4
 RFei2ID9LIWUyWcutA15STXA3CxLUGPHmqBEkFkvBjf9wI47qkOBM0zks8BIoHecK+s2xT81fJU
 V9+8nlLZSpOYfuSp1Md6EOaoC1BfqNX6vQ3m3uHhOds3hMllobgYqDqCWwfBEI5Yztz3nIrJw3K
 +774Q
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The add_xprt sysfs file clones the main transport of an xprt_switch,
including its bc_xprt. On the xprt_switch of an NFSv4.1 callback
client, the clone runs a backchannel setup routine against the main
transport's svc_xprt. xs_setup_bc_tcp() overwrites xpt_bc_xprt
without releasing the reference the original rpc_xprt held there, so
the original rpc_xprt leaks along with its netns and module
references. On an RDMA callback client the same write oopses
instead, because the RDMA backchannel transport leaves xprt_class
NULL.

A backchannel transport rides on its svc_xprt and has no connection
of its own to clone. Return -EOPNOTSUPP when the main transport has
a bc_xprt, before reading its xprt_class, as
rpc_sysfs_xprt_dstaddr_store() does for transports other than TCP
and RDMA.

Fixes: df210d9b0951 ("sunrpc: Add a sysfs file for adding a new xprt")
Cc: stable@vger.kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/sysfs.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/sysfs.c b/net/sunrpc/sysfs.c
index e638b92b7ad1..90a73ce261d8 100644
--- a/net/sunrpc/sysfs.c
+++ b/net/sunrpc/sysfs.c
@@ -337,6 +337,12 @@ static ssize_t rpc_sysfs_xprt_switch_add_xprt_store(struct kobject *kobj,
 	if (!xprt)
 		goto out;
 
+	/* Backchannel setup would rebind the svc_xprt's xpt_bc_xprt. */
+	if (xprt->bc_xprt) {
+		count = -EOPNOTSUPP;
+		goto out_put_xprt;
+	}
+
 	xprt_create_args.ident = xprt->xprt_class->ident;
 	xprt_create_args.net = xprt->xprt_net;
 	xprt_create_args.dstaddr = (struct sockaddr *)&xprt->addr;

-- 
2.54.0

