Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 394B43AA504
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788514755; cv=none; b=msoc4F/T2SToKCbsoDm52TrzQJ4bKNP6GPohHFzYcLglgl77NssXXCapMD+p21/phKZzhuub55CEoDO6eAnjkUt2XVV0sJmpmHUj84mHUirmk5BS4saLHgXpIZWvf5xm/UFl45DC7C0opOJdBY105UwjUwuyLhlwVZwY1pIUzWc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788514755; c=relaxed/simple;
	bh=pPhYJGTRRB+9JxyeIKeE6dngBEpydUzaNTZGqjHZY7k=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=iXdx4WGsD/tVHrkzRNuknZH8cvIOvc8xfYc0SNXPevUVyVbP5hh9EF/RfhBmMgRrRWpauUHUdMz9EFMoSu7VS4s+xC4n1EGLNLfgBm+7dOBHE+2brl87Gh6/QelAcDTz71MtSPozmoCKYHZngvy5G0VmcrL/r97Ah0GSQkVplXQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ZxTfveT6; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ZxTfveT6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788514753;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=rEE1DoQht6igfvqbRAyQBJJ0biBJhkETAKfEhhHABc8=;
	b=ZxTfveT6NPGFlVfJ5l7IWxlMZlN+zoE1za7fB05FT9LkEV5pUJiLZNJEmp/ha1z7Xfdp0q
	m40B/q+Czl8Xm9MwknCt7iwjN6DzVHlPsGofJ7mGJAE/Tx5k96M9VYCiQLkIWFNUkf3/Up
	vfbrwfXnGgQABbCRzGeh7zfFA1Y8LOw=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-453-aZgOBj6rPLSU-Zqp6R_xPQ-1; Fri,
 04 Sep 2026 05:39:11 -0400
X-MC-Unique: aZgOBj6rPLSU-Zqp6R_xPQ-1
X-Mimecast-MFC-AGG-ID: aZgOBj6rPLSU-Zqp6R_xPQ_1788514751
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 05CC01888635
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:11 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8FDF81955F70;
	Fri,  4 Sep 2026 09:39:10 +0000 (UTC)
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs4-acl-tools PATCH 0/3] nfs4-acl-tools hardening fixes 
Date: Fri,  4 Sep 2026 05:39:06 -0400
Message-ID: <20260904093909.2881028-1-rbergant@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

- Escape special characters in printed filenames to prevent injection
- Fix bound checking around NFS4_MAX_PRINCIPALSIZE
- Use lsetxattr to avoid following symlinks during recursive walks

Roberto Bergantinos Corpas (3):
  nfs4_getfacl/nfs4_setfacl: escape newline+cr from filenames
  libnfs4acl: fix various bound checkings against NFS4_MAX_PRINCIPALSIZE
  nfs4_setacl: do not follow symlinks on
    do_apply_action/nfs4_setacl_byname

 include/libacl_nfs4.h             |  1 +
 libnfs4acl/acl_nfs4_set_who.c     |  2 +-
 libnfs4acl/acl_nfs4_xattr_load.c  |  2 +-
 libnfs4acl/nfs4_ace_from_string.c |  2 +-
 libnfs4acl/nfs4_print_acl.c       | 13 +++++++++++++
 libnfs4acl/nfs4_setacl.c          |  2 +-
 nfs4_getfacl/nfs4_getfacl.c       |  7 +++++--
 nfs4_setfacl/nfs4_setfacl.c       |  6 ++++--
 8 files changed, 27 insertions(+), 8 deletions(-)

-- 
2.55.0

