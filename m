Received: from mail-oi2-f23.google.com (mail-oi2-f23.google.com [74.125.231.215])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C63D4A2071
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 15:29:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.215
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790263749; cv=none; b=LVlVDTAMQh3cgqprZb62KCy+73LGxmwmcVc7V03G95DnXhZK1Q1v9bM9zt6J7Uve9lZmB2VT+J/ECErbt/2kQUmCDqr6g1t9Q2G1Oof3WFeh76ctcukrP3KlaAvq5g6Mt4mbRfEjvi9h8S7DSmWwBOukS7p6VvtjPsE0ve7JDcY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790263749; c=relaxed/simple;
	bh=g9qiQWldyG0+tK8rJK7faLIRiz26FLpcb2anQBJMNEE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=VUhsNj9KkMvgkmmNPfWg1hS/3ldHVhpbjd9UC8+fwHIEVrW6FfriJcdVwq2i/6Dhw1GVe8PHApjV1ZisEdOVEfFxzvb8li5tErkMKcuKWa6p4u0gMopM/tPgD69tZF3Cx9clUlx0vGp6r8F329FnCOxOA6bQsNWHTtS/3zTXgXU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=cezowOjN; arc=none smtp.client-ip=74.125.231.215
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="cezowOjN"
Received: by mail-oi2-f23.google.com with SMTP id 46e09a7af769-7f4f0d37dccso1149242a34.3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 08:29:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790263746; x=1790868546; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=9Me2SPFP+GtbPs+Ayv2tvdaY49/7N3thsmPV2XF79PU=;
        b=cezowOjNPgOc+ri1HXKKVn/JWIRaQHXZ/AUnIU3DV6M9rgjZZlakIciY/1e7c0FwSb
         Zen/nBEhkxoXdczW2ZsHRPHfJpyXhcbgC21k0ZCoRiRJXM3MFQongmPvOBnYz+l8dbb/
         W9pieWOoO9YXdSmc9oSkDZFarF/cYnB1tJ8MT9eL7RBVE0EZ0hXYlhgZm6Ijx79D4Qba
         +6U28Q5trvHGmmo7dchwe4dPOKYVbcGR5RcYkXxjVJeOGMw7ffyaF0NZ6Zj3N5dEwWpn
         kdSjHazlZd9a3I+5EdiIJGz9SU0PA9/W2JqtMsITrID7PVOByn4fOB1SwWUXOxHkvIOG
         7L3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790263746; x=1790868546;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=9Me2SPFP+GtbPs+Ayv2tvdaY49/7N3thsmPV2XF79PU=;
        b=wHFYDmbhaqQE3E0Wi5ZXmcmg20W1xnAzmkURtpHdOMuC1uu6DDucRmoNp/+mI/8mXZ
         VXh9Afyi9hTnbvz0eKyzcRFQjJGC4/1tS6+Z4lrwpLuKRGi4R9l8UK/hn1qR2PNHCWfB
         c10PmPuqmCVYpxNYkCSeB0Hqgucs83hZnOXbUcLvzmkJZbk6JGwkFAwf5zQqpgZbrTqm
         lolhdFPnlQsh0qZ306Qn0G/qJ/rdo8+0JTNVHjijDMJGnZjrUXvzbrgsVQ5RkrGRUJvo
         joihCbbnHu26fL3gxeawyIRX4pKbT0iE4jqRbYwM3jeITky5RI7sLqt4J/1kxQOyNkhb
         iEww==
X-Gm-Message-State: AFuF++mhMgwsClfCv6SzbsvSN5mbpdgfQ8/R2J0lAhTa3+tciSVCZ+jY
	2wDJ2t1KHF4YNpq8rhVOLXrkgz/R/ih4l70hOXQS6qckW+t17Qyaq4wiSv5wojIBWsk7hsYzOZD
	hv77h
X-Gm-Gg: AYBFou2lKPa+7qr7MhlCnAfVkKlJ0UVMVyYena6HFOHZeJFoXp1151Hgb8b9S+iie5e
	+qDQUNdkEph1nzsVTzbifWB2tZnCJbX9koY7m50Ye2aavVo3MXQ0inNZxiZClOzfsOu0/XwQ7Ni
	ItXUbMMnJyzkLxeNbBQCxarDjG/KiqnsEn4XCsJLxo3Dhubjw1kPnd/7u72Dmv3v72OOhui8P+b
	UVY8a4ps7tYr0j71VQAjUj8V7z3DbUM7lqY7gRsGinFZQXM1HCtTbGS83YyOisLNjOT9kUXigFX
	6Us5PbpU243fTcnEOaA2pFLTEyW/6PLPVg7BTejmGraciSvgds00AgA1v73rWR8E2B7jGSahIrX
	fNCc9/3OHNpldPDaJ38yzN9czD71PykM8c7AHq+HIDNmwDbrvb68CI8TYSSZcTZwGcsBGlhM3Of
	n75RDMfPaisldnZNJAXGnwdSHBMEwpJyB6yidSSVEMl0Ma20Hn4arwWAWnx1CgFKmUnp2sUJQC5
	61kEVAp4Gzw67o8FYGzMBFzkjT/ryOCpA==
X-Received: by 2002:a05:6830:61c9:b0:7fa:ac4f:793 with SMTP id 46e09a7af769-81783e87cb6mr3110423a34.31.1790263745940;
        Thu, 24 Sep 2026 08:29:05 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-81603ad2b19sm6551506a34.4.2026.09.24.08.29.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 24 Sep 2026 08:29:05 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] mountd/exportd: exit signal handling fixups
Date: Thu, 24 Sep 2026 11:29:00 -0400
Message-ID: <cover.1790263469.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

mountd and exportd exit from inside their SIGTERM handler: killer()
unregisters with rpcbind, frees, logs and calls exit(), none of which is
async-signal-safe.  It mostly gets away with it because mountd spends
nearly all its time in select().

Setting rootdir in the [exports] section of nfs.conf makes it much
easier to hit.  nfsd_path_init() then starts a workqueue thread to do
path lookups in the chroot, and it does that after killer() is
installed.  pthread_create() allocates the new thread's TLS with
calloc(), so a SIGTERM there - say, from a reboot while mountd is still
coming up - runs killer() on top of a half-finished malloc.  We hit this
in a reboot test:

  malloc(): unsorted double linked list corrupted
  ...
  calloc
  clnt_vc_create
  local_rpcb
  rpcb_unset
  nfs_svc_unregister
  unregister_services
  killer
  <signal handler called>
  _int_malloc
  calloc
  allocate_dtv
  _dl_allocate_tls
  pthread_create
  main

Once that thread exists malloc takes the arena lock, so the same
re-entry later can deadlock instead of aborting.  Out of 400 SIGTERMs
sent during startup with rootdir set, one mountd hung on a futex, which
I think is that, though I didn't catch a stack.

These patches take HUP, INT and TERM through a signalfd in the cache
loop, so the shutdown work runs in normal context.  The parent of forked
workers keeps a handler, but all it does is kill(0, SIGTERM).  The last
patch holds signals while mountd registers with rpcbind rather than
ignoring them; a SIGTERM there used to just get dropped.

Tested in a private net namespace with its own rpcbind: foreground and
-t 4, HUP, TERM, an ha-callout, and 400 SIGTERMs at random points in
startup with rootdir set.  No aborts or hangs, and nothing dropped.

Benjamin Coddington (4):
  support/export: take SIGINT/SIGTERM/SIGHUP via signalfd
  mountd: stop exiting from a signal handler
  exportd: stop exiting from a signal handler
  mountd: hold SIGTERM during rpcbind registration instead of ignoring
    it

 support/export/cache.c       | 122 ++++++++++++++++++++++++++++++++++-
 support/export/export.h      |   2 +
 support/include/ha-callout.h |   5 +-
 utils/exportd/exportd.c      |  30 +++------
 utils/mountd/mountd.c        |  32 +++------
 utils/mountd/svc_run.c       |   2 +
 6 files changed, 147 insertions(+), 46 deletions(-)

-- 
2.53.0

