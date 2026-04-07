Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6DFAC25D527;
	Tue,  7 Apr 2026 13:22:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775568142; cv=none; b=AtW9bo1okMtF4QQiaV/JcyHlf8Miy3QtCpMX0wTQArOQgEcJagFpP/rEKBOmnwjxsPpk8KWWZbkh0pDg0OBthFg5Gh0ssRjjjINOor7BL9wWWlIEnhrfGupP7IMDLZDtf/SH5dboojdtjC+1XtDOxsjGyqbVvTA9mR4XYkaIPnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775568142; c=relaxed/simple;
	bh=gTyreAG16byQmEdf47TU/kJOKr5t7UUf5SVHfty7/zM=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=W61H10YzqnH5G/CBd9P1SX4Cz2GGIIG9fO68IYfeRkKrI8LGiMqc7hTc8EcfQaDYKJCCnXhLI8Z3yZX1Fm1NDeFmbk6cwdT7LOGpNI7oWLw+tknpbCsW48GqHboiOgZOe8SKKMlXivhEDLvp82njdSO5mpraSIxQnKukdOfBKhY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=pUO/fYUm; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="pUO/fYUm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BAA4C116C6;
	Tue,  7 Apr 2026 13:22:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775568142;
	bh=gTyreAG16byQmEdf47TU/kJOKr5t7UUf5SVHfty7/zM=;
	h=From:Subject:Date:To:Cc:From;
	b=pUO/fYUm7ctBSKSB+muyygPkfOuxocnTrE3peRcT0JqOXahHoJQOLZhoI8MQQ4Ytg
	 /LVJcUTkSPaexZH8o16MwtFVQiVGgN2vVIHs91g9cBEldg4eg7vbnMBZ+ywU31Lnc0
	 F0Y2fLDyn3KJwqZ9KcGrGG5IlAf63UcU77rnjKzMj4aCZpPC9U62Y7mwPfs5gF1kKC
	 g7r7c84aqypClKbRKCMi90YG+zZibkVdDrBgrlBoeVayQHxWBvMv74H5SttYUGgr/Y
	 Lab0N3zRdVjesqco5dREb/t4NgOLYj6NfzcKLA8gJYN8g1bCOtfOXhJs/ixf2Pf6F5
	 c5qfyj2X/RvJA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 00/24] vfs/nfsd: add support for CB_NOTIFY callbacks in
 directory delegations
Date: Tue, 07 Apr 2026 09:21:13 -0400
Message-Id: <20260407-dir-deleg-v1-0-aaf68c478abd@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDYyNT3ZTMIt2U1JzUdF1jY0sDM7OUFEMDQ3MloPqCotS0zAqwWdGxtbU
 A6SPfqVsAAAA=
X-Change-ID: 20260325-dir-deleg-339066dd1017
To: Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Chuck Lever <chuck.lever@oracle.com>, 
 Alexander Aring <alex.aring@gmail.com>, 
 Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Amir Goldstein <amir73il@gmail.com>
Cc: Calum Mackay <calum.mackay@oracle.com>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3969; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gTyreAG16byQmEdf47TU/kJOKr5t7UUf5SVHfty7/zM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBp1QT7pheKMLd265ATH/q0qgcilCyxdc37k9MFb
 /x6HdHUzmCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCadUE+wAKCRAADmhBGVaC
 FWkLD/9Gp8RJZ7mdWW0KljOB3FefEznNAG5q2n+1l+Q56+bdHK4JoUGxOwO/ikxS1Ta10JlBt2w
 zqr65bivZxQTRGzozKiJbXVINuMlco5XgsXFFNp4dlnAMwZqYQhiKW+o5hQgK7JLIZZbbmXbVJm
 ugjpNCJFLI7cWI+sPDbY2iBo7ypIh6NkqckD2ETvTSPHSt/73UtFjrQ2hxzb0K28+cpMdG/CtcC
 zjNp3HCPmOo9Frxnd2I+P5bBqtxD536f0/Nyj16yZ4EiE+iKTyTSh0ACg+CnDDBHD+BqP0+ob3J
 nhnMEQCEvKZWhvbCgbRPckNGLwRmPifgaG/35+lpSyD6PpDx+yiA+8Oaw1qYZM5vo9DVtMJqmcG
 K2cldhZ62sodzWuaHgXTFqQYtoICvVHaOlX290XXrejIi9rsJaVWDU4MPuaiKzAwwJYtMxBGNTn
 DuHSMidhUWtwqKSgKlqqNS56zNKZePAFyoGx64WXvbG+uJtUVmy0ThmeT3uHgCvreWNgsgRVoSP
 gOnaW1IQ9BJw/EC2oNSovny71nuyzVogVPcQll5/VLuRtmWJVI/8rpa2aKDk3eFzx8l5SEKK2em
 +K76iJu21xXpx9/0JP7x3IsvJrHuaP/ugPgM+33G8WsPtP886NJAlgOq5Z4kYaZO55btlN62uIf
 egXgrrJQaZAPqIQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This patchset builds on the directory delegation work we did a few
months ago, to add support for CB_NOTIFY callbacks for some events. In
particular, creates, unlinks and renames. The server also sends updated
directory attributes in the notifications. With this support, the client
can register interest in a directory and get notifications about changes
within it without losing its lease.

The series starts with patches to allow the vfs to ignore certain types
of events on directories. nfsd can then request these sorts of
delegations on directories, and then set up inotify watches on the
directory to trigger sending CB_NOTIFY events.

This has mainly been tested with pynfs, with some new testcases that
I'll be posting soon. They seem to work fine with those tests, but I
don't think we'll want to merge these until we have a complete
client-side implementation to test against.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (24):
      filelock: add support for ignoring deleg breaks for dir change events
      filelock: add a tracepoint to start of break_lease()
      filelock: add an inode_lease_ignore_mask helper
      nfsd: add protocol support for CB_NOTIFY
      nfs_common: add new NOTIFY4_* flags proposed in RFC8881bis
      nfsd: allow nfsd to get a dir lease with an ignore mask
      vfs: add fsnotify_modify_mark_mask()
      nfsd: update the fsnotify mark when setting or removing a dir delegation
      nfsd: make nfsd4_callback_ops->prepare operation bool return
      nfsd: add callback encoding and decoding linkages for CB_NOTIFY
      nfsd: use RCU to protect fi_deleg_file
      nfsd: add data structures for handling CB_NOTIFY
      nfsd: add notification handlers for dir events
      nfsd: add tracepoint to dir_event handler
      nfsd: apply the notify mask to the delegation when requested
      nfsd: add helper to marshal a fattr4 from completed args
      nfsd: allow nfsd4_encode_fattr4_change() to work with no export
      nfsd: send basic file attributes in CB_NOTIFY
      nfsd: allow encoding a filehandle into fattr4 without a svc_fh
      nfsd: add a fi_connectable flag to struct nfs4_file
      nfsd: add the filehandle to returned attributes in CB_NOTIFY
      nfsd: properly track requested child attributes
      nfsd: track requested dir attributes
      nfsd: add support to CB_NOTIFY for dir attribute changes

 Documentation/sunrpc/xdr/nfs4_1.x    | 264 ++++++++++++++-
 fs/attr.c                            |   2 +-
 fs/locks.c                           |  89 +++++-
 fs/namei.c                           |  31 +-
 fs/nfsd/filecache.c                  |  57 +++-
 fs/nfsd/nfs4callback.c               |  60 +++-
 fs/nfsd/nfs4layouts.c                |   5 +-
 fs/nfsd/nfs4proc.c                   |  15 +
 fs/nfsd/nfs4state.c                  | 524 ++++++++++++++++++++++++++----
 fs/nfsd/nfs4xdr.c                    | 300 ++++++++++++++---
 fs/nfsd/nfs4xdr_gen.c                | 601 ++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4xdr_gen.h                |  20 +-
 fs/nfsd/state.h                      |  70 +++-
 fs/nfsd/trace.h                      |  21 ++
 fs/nfsd/xdr4.h                       |   5 +
 fs/nfsd/xdr4cb.h                     |  12 +
 fs/notify/mark.c                     |  29 ++
 fs/posix_acl.c                       |   4 +-
 fs/xattr.c                           |   4 +-
 include/linux/filelock.h             |  54 +++-
 include/linux/fsnotify_backend.h     |   1 +
 include/linux/nfs4.h                 | 127 --------
 include/linux/sunrpc/xdrgen/nfs4_1.h | 291 ++++++++++++++++-
 include/trace/events/filelock.h      |  38 ++-
 include/uapi/linux/nfs4.h            |   2 -
 25 files changed, 2321 insertions(+), 305 deletions(-)
---
base-commit: bd5b9fd5e3d55bc412cec4bebe5a11da2151de4a
change-id: 20260325-dir-deleg-339066dd1017

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

