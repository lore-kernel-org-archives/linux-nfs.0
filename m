Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A7E348164E
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 12:51:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788353482; cv=none; b=bWcxITqT0eewpKMGr8d1A5ma4wmKKMzLUxjCshvMuQeH5OD2OOn+If6N1202ieEgig9ZRvpmlQD0LFd7nwLNhoqeEBsIw1+ad/MEP5I5UJqz+yOZeNyTi4Oz2pkcFP2SKLzewajg3uXNGKkvpLfsiRKVzDFoUKHbpSboRnhBUf8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788353482; c=relaxed/simple;
	bh=W4D7/W2k+BSdwJB8CAQRLqP+yRKUwspIb60rY3Piwq4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fFAHCK7zBfj2quJMbFEGdOOB0Bzq4QxKY8RhS58IX+mhVhWwatNjKrzgN/nVcDNL5w3j/5HpdBU/RqR8Bkvbag5ix3dyGRzYBQHceoYQjoZDp1bEP/lAsM3IHNRJZvwAnEVk9/5ervozhJtkx2Z4mgBkCgs45w3HwoIcnH5YDPo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ZLv4MdG7; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ZLv4MdG7"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788353479;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=3oN8zgeumJ1UNLlIK4k6dgXD1250gt/Lp6ENGOeDJvg=;
	b=ZLv4MdG7oz64snDWFez79l7QOyFQSCNTN56Gq0SMIXk6PpRY7GCR9ydEpt7fBCxzTMQFru
	GrtnuieTkY+QDCAIoXADE2jbbj18CdG0RT3w6VtdQqjwDXAU5HrwSLPg+dotEzP7WlKfYz
	Oy7s7CffEJL5+qw+PBna8UxuobCwRdQ=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-680-NaH4OXWeNWGM2c64l3jraA-1; Wed,
 02 Sept 2026 08:51:14 -0400
X-MC-Unique: NaH4OXWeNWGM2c64l3jraA-1
X-Mimecast-MFC-AGG-ID: NaH4OXWeNWGM2c64l3jraA_1788353472
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id F26261933E82;
	Wed,  2 Sep 2026 12:51:11 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id B5F927E5;
	Wed,  2 Sep 2026 12:51:07 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Jeffrey Altman <jaltman@auristor.com>,
	Paulo Alcantara <pc@manguebit.org>,
	linux-afs@lists.infradead.org,
	openafs-devel@openafs.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 0/2] vfs, afs, bash: Fix miscomparison of foreign user IDs in the VFS
Date: Wed,  2 Sep 2026 13:50:49 +0100
Message-ID: <20260902125054.3380685-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Hi Al, Christian,

Here's a pair of fixes that deal with some places the VFS mishandles
foreign user ID checks.  By "foreign" I mean that the user IDs from the
filesystem do not belong in the same number space as the system's user IDs.
Network filesystems are prime examples of this, but it may also impact
things like USB drives or cdroms.

Take AFS as example: Whilst each file does have a numeric user ID, the file
may be accessed from a world-accessible public-facing server from some
other organisation with its own idea of what that user ID refers to.  IDs
from AFS may also collide with the system's own set of IDs and may also be
unrepresentable as a 32-bit UID (in the case of AuriStor servers).

Further, kAFS uses a key containing an authentication token to specify the
subject doing an RPC operation to the server - and, as such, this needs to
be used instead of current_fsuid() in determining whether the current user
has ownership rights over a file.

Additionally, filesystems (CIFS being a notable example) may also have user
identifiers that aren't simple integers.

Now the problem in the VFS is that there are a number of places where it
assumes it can directly compare i_uid (possibly id-mapped) to either than
on another inode or a UID drawn from elsewhere (e.g. current_uid()) - but
this doesn't work right.

This causes the write-to-sticky check to work incorrectly for AFS (though
this is currently masked by a workaround in bash that has now been removed
as of bash-5.3) whereby open(O_CREAT) of such a file will fail when it
shouldn't.

Two patches are provided:

 (1) Add a pair of inode operations, one to compare the ownership of a pair
     of inodes and the other to see if the current process has ownership
     rights over an inode with an IOP flag to control access to them.

     Usage of this is then extended out into the VFS, replacing comparisons
     between i_uid and i_uid and between i_uid and current_fsuid().  The
     default, it the inode ops are unimplemented, is to do those direct i_uid
     comparisons.

 (2) Fixes the bash workaround issue with regard to AFS, overriding the
     checks as to whether two inodes have the same owner and the check as
     to whether the current user owns an inode to work within the AFS
     model.

kAFS uses the result of a status-fetch with a suitable key to determine
file ownership (if the ADMINISTER bit is set) and just compares the 64-bit
owner IDs to determine if two inodes have the same ownership.

Note that chown may also need modifying in some way - but the system call as
it stands can't necessarily supply the information required (for instance, an
AuriStor YFS ID is 64 bits, but chown can only handle a 32-bit integer; CIFS
might use a GUID).

The patches can be found here:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=afs-sticky-2

Thanks,
David

Changes
=======
ver #4)
- Rebased on v7.3-rc1.

ver #3)
- Fixed afs patch to provide ops for afs symlinks too.

ver #2)
- Rebased on v7.2-rc4.
- Added an IOP_ flag for a faster check of whether the new inode ops are
  supported.

David Howells (2):
  vfs: Allow filesystems with foreign owner IDs to override UID checks
  afs, bash: Fix open(O_CREAT) on an extant AFS file in a sticky dir

 Documentation/filesystems/vfs.rst |  21 ++++
 fs/afs/dir.c                      |   2 +
 fs/afs/file.c                     |   2 +
 fs/afs/inode.c                    |   1 +
 fs/afs/internal.h                 |   3 +
 fs/afs/security.c                 |  46 +++++++++
 fs/afs/symlink.c                  |   2 +
 fs/attr.c                         |  58 ++++++-----
 fs/coredump.c                     |   2 +-
 fs/inode.c                        |  11 +-
 fs/internal.h                     |   1 +
 fs/locks.c                        |   7 +-
 fs/namei.c                        | 161 ++++++++++++++++++++++++------
 fs/remap_range.c                  |  20 ++--
 include/linux/fs.h                |   7 +-
 15 files changed, 273 insertions(+), 71 deletions(-)

