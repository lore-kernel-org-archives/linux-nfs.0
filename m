Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795006300;
	b=Johrb/jdQ90NBptu4CWNgBiWkxRRoIoTMc9kZxaiiu/54ZovEAdZotwL50J73iCNYDcx
	 /RMgMU9OLRocai6uPQhaFJ4iBN1kN9lx6WaM2fEN+YwJGoseqZdxMC9vCySn/0ONYcEKh
	 HbNwxxJbGd10lFR0fp7IaCqYI8sVT4FCEXkQJfW+OhKQh4nbvSophEmPEWiENt63W/HeH
	 vl8OvvcGdJlOKyzOfn3IOWQCctfFm/XhhkqVkaICG5/cWqJiWVf640IrjoyzeeYOAlIM/
	 2AOD8HY3L6sJsdiKPrKbr1+FNgQysXTyrEz4pU2iXwt2qSuTm5kUqwcPHOgLseQZk6w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795006300;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=K8h00Jc2UP56tLj/bXfDtNuTO40xnOpS0AymS9u2Ay0=;
	b=0D1IIIbLr3NbwWMQSR5iWRST/27WlsjVPY7rPWuvlIHWi5NrMcQpV0OZlOCGtIbj60AS
	 5aq574VTBL8nBfj4qgEHB8jAe25j5O+ehF1fAtRFmOM4yV0CkwJKr/+RGVw/oRGN1aqbM
	 UV1BlxBp1gaiw2ZOkYKoIOHwl72qTX6gL/jNapJLvuEv4V194jk0S9YyDJtxmqobVuZae
	 nx9CAsjiPXWHznqgipXOQOywLkQ6AMwP7zfLgCJHMLjHsTZlg5IgIB+g689oEHwR27SxI
	 zVNETGVRmuhHr61dz2H65CzmXJXLGUxF6yE5tAjRuoUMVClhutMpBd/bETRFa4viqpQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=X6I3HzJ9;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E42BB606A31C
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 12:51:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E42BB606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=X6I3HzJ9
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795006298;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=K8h00Jc2UP56tLj/bXfDtNuTO40xnOpS0AymS9u2Ay0=;
	b=X6I3HzJ9cHcU3ER9a2NmgNhQCouWtqtb7Oi1eTnC2Wr7Oz6Os0QES+YdrXGRNpLBzdo8Ld
	/797xBrBpoljkfLNKB3AFSa+dGjZ/ZQIq0yUpAOhBFLYJ7IAIhcQzf9pMatBI+dw2iolNd
	pg7TTaFWkruB89T8/0ezhttDNezkFaM=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-577-0eGjKmBCPK6YXqYnlk3m8Q-1; Wed,
 18 Nov 2026 07:51:37 -0500
X-MC-Unique: 0eGjKmBCPK6YXqYnlk3m8Q-1
X-Mimecast-MFC-AGG-ID: 0eGjKmBCPK6YXqYnlk3m8Q_1795006296
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 59DDE180057F;
	Wed, 18 Nov 2026 12:51:36 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id A7C75180197D;
	Wed, 18 Nov 2026 12:51:35 +0000 (UTC)
From: Abhinandan Ekande <aekande@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: dhowells@redhat.com,
	linux-nfs@vger.kernel.org,
	aekande@redhat.com
Subject: [PATCH v3 0/3] NFS: Fix netfs read subrequest range, retry accounting and fallback handling
Date: Wed, 18 Nov 2026 07:51:32 -0500
Message-ID: <20261118125135.1991518-1-aekande@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

This version fixes an issue that Sashiko's review pointed out.

While addressing an issue where netfs repeatedly reads whole folios when
rsize is smaller than the folio size, two additional pre-existing bugs
were identified in the NFS netfs read path: subrequest retry byte
accounting and legacy read fallback handling.

This series fixes all three issues:
- Patch 1 fixes an accounting bug in nfs_netfs_put(): it assigns the
  current ->issue_read() call's byte count to sreq->transferred instead of
  adding to it, discarding progress from an earlier attempt such as a
  partial cache read, so the subrequest under-reports what it holds.
  Accumulate instead, with the existing min_t() clamp now bounding the
  cumulative total.
- Patch 2 ensures nfs_netfs_issue_read() requests only the subrequest's
  byte range rather than repeatedly submitting the whole folio.
- Patch 3 restricts the legacy nfs_do_read_folio() fallback in
  nfs_read_folio() to -ENOBUFS (when fscache is absent), avoiding a
  fallback read on an already unlocked folio when netfs_read_folio()
  fails with other errors.

Notes on v2 review comments from Sashiko[2]:
1. Fallback path in nfs_read_folio() when netfs_read_folio() fails:
   This pre-existing issue is addressed by patch 3, which restricts the
   nfs_do_read_folio() fallback to -ENOBUFS.
2. Unaligned range / past-EOF zero-fill in patch 2:
   - pNFS block/SCSI layout: Neither the sub-page offset BUG_ON() nor the
     EOF tail overwrite is observable today because pNFS block/SCSI
     layout with fscache enabled cannot complete any buffered reads.
     That alignment check can be addressed when block/SCSI layout is
     updated to support netfs/fscache.
   - Past-EOF zero-fill and concurrent i_size growth: netfs has no
     ordering between an inline NETFS_FILL_WITH_ZEROES subrequest and an
     async over-read past rreq->i_size; the pre-patch behavior was
     partial and rsize dependent. Once the client notices the i_size
     growth, nfs_update_inode() sets NFS_INO_INVALID_DATA, ensuring the
     next revalidation invalidates both the folio and fscache. Keeping
     nfs_netfs_issue_read() strictly within the subrequest's byte range
     avoids violating netfs's subrequest ownership.

Changes in v3:
- Added patch 3 to restrict the legacy read fallback in nfs_read_folio()
  to -ENOBUFS, following review feedback from Sashiko[2].
- Patch 1 and patch 2 are unchanged from v2.
- Link to v2: https://lore.kernel.org/all/20261030061138.237833-1-aekande@redhat.com/

Changes in v2:
- Added patch 1 to fix sreq->transferred accumulation on completion,
  following review feedback from Sashiko[1].
- Patch 2 is unchanged from v1.

[1] https://sashiko.dev/#/patchset/20261027053444.32012-1-aekande%40redhat.com
[2] https://sashiko.dev/#/patchset/20261030061138.237833-1-aekande%40redhat.com

Abhinandan Ekande (3):
  NFS: Accumulate transferred bytes on netfs read completion
  NFS: honour the netfs subrequest range when issuing reads
  NFS: only fall back to the legacy read path when fscache is absent

 fs/nfs/fscache.c  | 21 +++++++++++++----
 fs/nfs/fscache.h  |  1 +
 fs/nfs/internal.h |  4 ++++
 fs/nfs/read.c     | 58 ++++++++++++++++++++++++++++++-----------------
 4 files changed, 59 insertions(+), 25 deletions(-)

-- 
2.55.0

