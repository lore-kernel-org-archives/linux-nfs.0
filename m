Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794512552;
	b=iLafVt+Qn3MCZHfbF3sOJpbXe0S3uMsHNQstHSiJN5RMiLAehz/MrYTYfjcdU0TcvH6W
	 Mu3EEUJaX2YR/FkNEzbjacHe3oynp/l8cEuIXLUen6CE37XzLEaOki1XcQRUDTIHndAyU
	 xgqsqd8YtmT/puP49IEoTQ32pWsWzb0B/mVBrfrLWzooqjB3J46ZtNlwUQV9LA7zdrMza
	 PD8e5UVacAH/L67zaKhwyDgfr8tycruyx100a2quhSNor9+xgYaUDme+XAAYnHvJtnlrk
	 Wx+pFRDcErLlBDK4abccnr3PZ1R+gYXQFMcqs28TdFXs9GfflA7RYc3Va15j4nmxDYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794512552;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=Pzg7f9PjcHz0NlTyy8vyVHRUOWmZqz0fFnlf9AuGlWU=;
	b=VUdDJfFKkwdQry48s2A6CNmEg/duBvWsre2jeJ3RxHm2zMfdT99ZJ98ZnhhTQKB9EgvA
	 D7+Y34guFkSrXcwQSBx2MNWl9LaEZP37pAhXrIWXNTC906puQS0K433Wu48y/Ay+waSdi
	 wNx4eD9AFyknScbKo1T1G2OWiC6tgJUSFccn9+W1myiG2mxJ9tb9NGIdoRPIJQaEwzxaL
	 gELmJ02ABfuhjvnCn8wQ8jJmvA4dof3g0tLqlrnycW7cCuvyXO+UV1cYS+uysM9ApXaH2
	 Q7rhcvHl0PXbJtRL8tpTKQejcLg4ILgukQtjtRprmtibgH0EUNC6vPehHeYvOrWGvng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=DJbBqBlo;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78415606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 19:42:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 78415606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=DJbBqBlo
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794512550;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=Pzg7f9PjcHz0NlTyy8vyVHRUOWmZqz0fFnlf9AuGlWU=;
	b=DJbBqBlo+G/kauWS6tnBtJd53/LUAkmBhwMmTg5R5XbrKAz6d2jqal+Am/i6Pi9bpl8adU
	1dSORiSiRVlb2QyA1upDcCY7AL7FbCQcKaVjHFYCJlJXBAP+YIN5pOKRZ3hGcx+sKz92GZ
	MrlSUrIYVeN9u8MZdqVYbMOz02b8qxQ=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-478-RLq1LvZGNOqHjb3clpLgMw-1; Thu,
 12 Nov 2026 14:42:26 -0500
X-MC-Unique: RLq1LvZGNOqHjb3clpLgMw-1
X-Mimecast-MFC-AGG-ID: RLq1LvZGNOqHjb3clpLgMw_1794512546
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E2C0519560A2;
	Thu, 12 Nov 2026 19:42:25 +0000 (UTC)
Received: from okorniev-mac.redhat.corp (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 3FAF718004FC;
	Thu, 12 Nov 2026 19:42:25 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] pNFS: fix tasks hung forever on NFS_LAYOUT_DRAIN
Date: Thu, 12 Nov 2026 14:42:22 -0500
Message-ID: <20261112194224.34455-1-okorniev@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Tasks hang indefinitely in pnfs_update_layout() waiting on
NFS_LAYOUT_DRAIN, with the layout header left in

    plh_flags       = 0x640   = HASHED | INVALID_STID | DRAIN
    plh_outstanding = 0

NFS_LAYOUT_DRAIN is cleared in exactly one place, nfs_layoutget_end(),
and only when the last outstanding LAYOUTGET completes. With
plh_outstanding already at zero there is no LAYOUTGET left that could
run it, so the bit stays set and the waiter is never woken.

This was seen in the field on a filelayout mount against a NetApp
server, on a kernel that already carries the two previous fixes for the
same end state (38e55db5c06c and 5248d8474e59), so there is a third
path into it.

Three actors are involved, all of them writes to the same file, but at
three different stages of the write path.

The starting state is a layout that an earlier DS error or
CB_LAYOUTRECALL has already invalidated: the segments are gone,
plh_flags has INVALID_STID and DRAIN, and plh_outstanding is 0. DRAIN
being set here is harmless on its own, since the next LAYOUTGET will
clear it.

  - B is a write that needs a layout before it can place its pages. It
    finds no segment and the stateid invalid, so it claims
    FIRST_LAYOUTGET, calls nfs_layoutget_begin() - taking
    plh_outstanding from 0 to 1 - and sends a LAYOUTGET.

  - A, the victim, is a second write, flushing a page out of
    write_cache_pages() and asking pnfs_update_layout() which data
    server to send it to. It sees DRAIN set and plh_outstanding != 0,
    concludes that B's LAYOUTGET is being forgotten and that it should
    wait for the drain, drops i_lock and heads for wait_on_bit(). It is
    still holding the page lock taken by write_cache_pages().

  - B's LAYOUTGET reply arrives. pnfs_layout_process() accepts it -
    DRAIN would normally make it forget the reply, but a first
    layoutget is exempt - and pnfs_set_layout_stateid() clears
    INVALID_STID. Returning up the stack, nfs_layoutget_end() drops
    plh_outstanding to 0, clears DRAIN and FIRST_LAYOUTGET, and wakes.
    Nobody is on the wait queue yet: A has not reached its test_bit().

  - C is a third write, already past the layout lookup and out on the
    wire. Its WRITE to a data server comes back with an error that
    means the layout is no longer usable - ESTALE, EBADHANDLE,
    NFS4ERR_PNFS_NO_LAYOUT and friends - and
    filelayout_async_handle_error() calls pnfs_destroy_layout(), which
    sets INVALID_STID and DRAIN again, now with plh_outstanding == 0.
    (C need not be a separate task; it can be B itself, later, writing
    with the layout it just fetched.)

  - A finally evaluates the bit in wait_on_bit(), sees DRAIN set, and
    sleeps forever.

Patch 1 is the fix. Patch 2 is independent of it and only adds
tracing: the DRAIN branch of pnfs_update_layout() currently emits no
tracepoint at all, and the pnfs_update_layout event reports neither
plh_flags nor plh_outstanding, which are precisely the two values that
decide whether a task enters that wait and when it leaves. Working out
why a task is parked there means reading them out of a crash dump.


Olga Kornievskaia (2):
  pNFS: don't set NFS_LAYOUT_DRAIN when there is nothing to drain
  pNFS: trace the NFS_LAYOUT_DRAIN wait in pnfs_update_layout()

 fs/nfs/callback_proc.c |  2 +-
 fs/nfs/nfs4trace.h     | 42 +++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.c          | 36 +++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h          |  1 +
 include/linux/nfs4.h   |  1 +
 5 files changed, 79 insertions(+), 3 deletions(-)

-- 
2.55.0

