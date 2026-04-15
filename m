Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C279935E92B
	for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2026 14:01:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776261670; cv=none; b=HV7sPQn5Ycxf0DqE3kXwhEdIiWSH0yzwfLHnNEHYu1qZy/EvccSffDzSeYQHGtS2KERonvu/uLlV0UfKG7da5CafFSijF1Y37J59i0/eXz0jMQZoUUoauHQ66FTIlKXie0gyqc0AVvD5Dj7tIt8fvkhIRDAVdHoVC3LpfMeSeKA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776261670; c=relaxed/simple;
	bh=KAfzQuapzFgy+8DBw1sffLbl39LDTDwcoFEqmUcuqbE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=LDRFG2loRXBeOYOe8LO4aWbxB+2F+mOlcqfyz9lbBy4PbBhv533d6582qhv+aEuXLDkf9osdBtC6SrVMS8Q9lZwgUnfi4iO/BI7O+TXWnvY6qjn0wY3wLPGAa7PHrkRJ8imh6ykPSSFSuK+L31/JizCK8o/veAUoeqrNzDRsAuc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=fHC7OKBW; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="fHC7OKBW"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1776261667;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=KP2uYNCXcppn7nF3Y59Ll2YQLye8a+Yfan6tJlchaIg=;
	b=fHC7OKBW6/svNbT+HNQvurGWfW3Cr5Fbl/bMt7fBZDF4nXDaVS0cJPophh8QIrVyLff0bU
	WDKuB/lEnPSFhDnsho0z7M+XJ50Ujn3qONb7zlaCiN3eV89wjvJVo2XOuq6itSu7l62xCG
	+KERvaWvs8zOw46/1ECxTUNg3ZY4zYU=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-467-a260Ont_PcOvYTDDNxW2EQ-1; Wed,
 15 Apr 2026 10:01:04 -0400
X-MC-Unique: a260Ont_PcOvYTDDNxW2EQ-1
X-Mimecast-MFC-AGG-ID: a260Ont_PcOvYTDDNxW2EQ_1776261663
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0B1A3180064A;
	Wed, 15 Apr 2026 14:01:03 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.80.125])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 0533C180047F;
	Wed, 15 Apr 2026 14:01:01 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/1] NFSv4: retry GETATTR if GET_DIR_DELEGATION failed
Date: Wed, 15 Apr 2026 10:01:00 -0400
Message-ID: <20260415140100.52455-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Currently, getting a directory delegation is opportinistic and gets
added to an existing GETATTR that's trying to retrieve some needed
attributes. However, GET_DIRDELEGATION can fail and that currently
causes a GETATTR to fail and an error is propagated to the user.

Instead, the original GETATTR should be retried without requesting
a directory delegation. Also, now chosing to clear asking for
the direct delegation for this specific inode.

Fixes: 156b09482933 ("NFS: Request a directory delegation on ACCESS, CREATE, and UNLINK")
Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>

-- v2:
BSD server can return NFS4ERR_NOFILEHANDLE when requesting directory
delegations on "/" that isn't exported.
---
 fs/nfs/nfs4proc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 91bcf67bd743..83c596a8cc20 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4469,6 +4469,14 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		case -ENOTSUPP:
 		case -EOPNOTSUPP:
 			server->caps &= ~NFS_CAP_DIR_DELEG;
+			break;
+		case -NFS4ERR_NOFILEHANDLE:
+		case -NFS4ERR_INVAL:
+		case -NFS4ERR_IO:
+		case -NFS4ERR_DIRDELEG_UNAVAIL:
+		case -NFS4ERR_NOTDIR:
+			clear_bit(NFS_INO_REQ_DIR_DELEG, &(NFS_I(inode)->flags));
+			status = -EAGAIN;
 		}
 	}
 
@@ -4490,6 +4498,7 @@ int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		default:
 			err = nfs4_handle_exception(server, err, &exception);
 			break;
+		case -EAGAIN:
 		case -ENOTSUPP:
 		case -EOPNOTSUPP:
 			exception.retry = true;
-- 
2.52.0

