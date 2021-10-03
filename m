X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Google-Smtp-Source: ABdhPJw0OwdUR0aswuRLv1Q1Ffu3Fx7giOq8uNaij8wQ1iboQKZJnRHy+33PCDb8A6FQb+pzgzta
X-Received: by 2002:a50:c31a:: with SMTP id a26mr9903724edb.193.1633288966414;
 Sun, 03 Oct 2021 12:22:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288966; cv=none; d=google.com;
 s=arc-20160816;
 b=Kgt9mqe7zvPA88Iy+RsGgAW1Ot+gJhWXxAbq8SpGMX2k5+guD0UmKcEYwEnnA7xguR
 4o3U8yvoflU+ogls9xiFOtMl7XzxJlGOjPwyULAFGPel8lJXpbFGLE6t/Vay3qJo+1J4
 pnO0i2qE/xXSGLLPtgCgDLgfc7WRr/TImB0KkQT12pX7jbgVsj9q4cSo4KqkUTroiV25
 0Bf2OramEY6RcDwfFqV+gZ1raQOmnkTBN+syBao08ESyd73Vd+NzVP2i6x4FffxT69Rt
 D8LmgbM7HEMGtzzIIba/mCoRF6ZCF0rAy7KzilL3r8A5JhLDVkjfDMECT1wcOb5dv8El CvFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=message-id:date:subject:cc:to:from:delivered-to;
 bh=MoQ1Rvasn/IVV5doMfQl9KU+FXkLa6C7dslpV/KfW/w=;
 b=yDvgOGihlFCJ4Q/W3jiHmS5KOXMSDuIZhFytXe0R4CTgcjCj/6U7YO+8klbbmBYhlT
 QVcjCIE3FzUxwjLZmk8Gv/Kkps7rQULVQd3oH0oV/AqFRcV9OCpYN+ltCk6eV3BwxWBl
 YfzenS4l1h5qXumdK66HHm7LmeWsSX+0+VrdYX3p4cmq6Wtv9sHZgcUpZD9NIpbOl31j
 axNj3Z6Vn9JOt5lDTRu+0No35ror321xJE0vbGHwrSmh37MXXpm1VAnpbEiB2d6YRWq5
 mX2jAOKEsjo4H2agXQapvGkiXAO65MrYgzDaojcVqQ494jLhbASH0NBr60/OUXoOzIak WCoQ==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.81 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-2.mimecast.com.
 [207.211.31.81]) by mx.google.com with ESMTPS id
 g16si16621933ejm.150.2021.10.03.12.22.45 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:46 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 207.211.31.81 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.81 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-577-9XhNafjqMS2nYSC4drPpeg-1; Sun, 03 Oct 2021 15:22:44 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id 8ABE61084683 for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:43 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id 8699D5F4E9; Sun,  3 Oct 2021
 19:22:43 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id 8F7745F4E8; Sun,  3 Oct 2021
 19:22:40 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 0/7] Various NFS fscache cleanups
Date: Sun,  3 Oct 2021 15:22:31 -0400
Message-Id: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

This patchset is on top of David Howells fscache-iter-3 branch, which
he posted v2 recently
https://lore.kernel.org/all/163189104510.2509237.10805032055807259087.stgit@warthog.procyon.org.uk/

The first patch in this series should probably be merged into David Howells
3/8 patch of that series.  Otherwise, these patches are applied on top of
his series, and this series is mostly orthogonal to fscache-iter-3 branch.

The second and third patches are a few cleanups, and the last 4 remove
dfprintks in the NFS fscache code, and add in few new tracepoints.  I am
not sure about the new tracepoints, but I think we need at least a couple
tracepoints with the NFS fscache interface to tie in NFS tracepoints with
fscache and cachefiles ones.

These have been tested with xfstests against various NFS versions (NFS4.0,
NFS4.1, and NFS4.2) and servers (hammerspace, Netapp Ontap 9.x, RHEL8.4),
and all tracepoints enabled per the following:
trace-cmd start -e fscache:* -e nfs:* -e nfs4:* -e cachefiles:*

I plan to use this series at the BakeAThon this week for further testing
and refinement.

Dave Wysochanski (7):
  NFS: Fixup patch 3/8 of fscache-iter-3 v2
  NFS: Use nfs_i_fscache() consistently within NFS fscache code
  NFS: Cleanup usage of nfs_inode in fscache interface and handle i_size
    properly
  NFS: Convert NFS fscache enable/disable dfprintks to tracepoints
  NFS: Replace dfprintks in favor of tracepoints in fscache IO paths
  NFS: Remove remaining dfprintks related to fscache cookies
  NFS: Remove remaining usages of NFSDBG_FSCACHE

 fs/nfs/fscache-index.c      |  2 -
 fs/nfs/fscache.c            | 70 +++++++++-----------------------
 fs/nfs/fscache.h            |  8 ++--
 fs/nfs/nfstrace.h           | 99 +++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/nfs_fs.h |  2 +-
 5 files changed, 123 insertions(+), 58 deletions(-)

-- 
1.8.3.1

