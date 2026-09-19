Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEAB529408;
	Sat, 19 Sep 2026 02:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784703; cv=none; b=ahaE2JYw1mJ22QrwIqtm0Rv6EdF/sHH14m0nkVDq6v8ttAvfroYCTVnYwEF2OlBCDcRT30ZVZi/pN2RLu9Z47liWwiJAivo2cxTZv/lJSvxuQ0Rbyfq7/2dxNQFEa6Mxg+Kmaz6pTzdTFNqi/mm/z7UXgZxKZ42blVlve0+u/no=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784703; c=relaxed/simple;
	bh=uvURXr00c1elzZMNfcQDp7vIvjZW3AcPX4PdWNFGiwo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Eae9hZLb+PqcfvD1J2OYAXDy3vbDCHFWNU0u+D4AXQb43TrXHiitgBca0Va6+5hj816ZtB99JW33d+oAsikfBFfrc5sKg6+6xRoNAMCf1MabrPwDWXPVYAsTYX2yrl8fWnXH66bsRZnnX5OnNhZMyg0Gwkz4qgKoxBzrNAGqCEc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Vdaey47T; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Wf9nGRii; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Vdaey47T";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Wf9nGRii"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id 8EF821D00104;
	Fri, 18 Sep 2026 22:25:00 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Fri, 18 Sep 2026 22:25:01 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm1; t=1789784700; x=1789871100; bh=+ME2RL0fCy
	IhvG5v38mps/X91Cn8T+QjqURnQ4QlodQ=; b=Vdaey47TlE7J2PKep5zb1H9FHe
	ccVoyjU66UCf4GBdZSuqy2j9hqxqLwqe3xKMo7VsqhbSmml+77cz3OBpvd8NfXAT
	SuwqKy0beRVGhVug3UXRuIB+YH8XFcZHv8OF9O1/dGBvkoIyWWz3YA2NqW8Sp/PD
	Y0ACDvvy9ZM/KOIwUAPr75YSxx7O2zQhtVUtn2kR5rBXvn8NTRc7jcQE75th7j2Q
	YTrZwegE1xt0wRtVrqNld8kB6RzAIfGAnF6RzL6MeU3IoVuRd+P+Bu7CK6/XcAEv
	KrIQ0CwK8UUXDzGUSgd1Mse9m4JLMWI6DW1PcMjwYsWx9GMNyRR7kBjdXFnA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; t=1789784700; x=1789871100; bh=+ME2RL0fCyIhvG5v38mps/X91Cn8
	T+QjqURnQ4QlodQ=; b=Wf9nGRiian3OUKzRjwEd+FwLyPp1gNdGorPQ20U9VlTI
	7tz4YooJAYXRuXaBXOf608IxFzZtss1fCsSIMQQPuV4vxYl07N60M6e0zL8CFGT7
	NXMFNi5J6I+vqNg/u/DDS6N8fnrCrEpX+2asSSKXBB05Wj8vuF9SmWCIvX31ABN3
	055h17XubBPSzdbFSlwdl2m0aGne+d1E0yZZAOfS0W64cxCiwij6q/jzllKevAoy
	w7z2U0IAfesD4Vs7IlCWZsd0B4rPh5tdLKqyLW5Pn6Or3FmnwTtscd5cYN/Wro20
	esSAeJnjL8uwOPaBwj+Wqgxt474WF+pD87AjkYRvHA==
X-ME-Sender: <xms:e_KtahiwkFpur7_OBVu3smCR8ne5T-0IwOCiUIrRoJ2NXrpquKMisw>
    <xme:e_KtamY-_30BYfyXtisZYfVdb-7mYVeTOEGyPZ33ErpKjRluS_PLRbc_3m2fdOFJg
    A0li3OoQUKZRRDElkfCzI2TROR1xtWkN0ywFtAHzNRqcPxDNqE>
X-ME-Received: <xmr:e_KtaiNDf3AJwzQ-FJOqImcqbDbrLvSIYixTfHN9u4INxK3yoigMP8vTcApwV6uDTRkaC0Df2TJIMS3Ja2OC5lv_ycsc0c4>
X-ME-Proxy-Cause: dmFkZTEdhksfL1thDUcCvsCxfMMT9BTJBZau7CSu/uqtOPaTCFHFog0HjFm9fH3UHkGUBW
    pNhdOr4OPAWb2UbAxydtYvklvIUVe2aCSjoXSZm+De1ZD2IIHw/7YO48WyreiGSO2LpjRg
    KSxYDgHM1UZDv56FgEkcMSUK+fyjSeTOMzd4EwjDW8h6kTRdAFi4wJhV1umPk6IeZsUcBi
    mj/nQi/UQNQfWfUBm7MA3oSy1YRr/B9XH/CdSY42e2ba536/rvN7wKf/y+jdfZpPrt8b6R
    ldEvdlKpRljRW1Pll3rankodNUlz/Atr3IA+4NDdHfFqFDBQ0CAkop9Sr2JbpuqQ/Vucst
    clElG/OONfExHxhncEoJxVhmcGuxBbN4E/d7CCWQ1y/C0eOQHd6Z2/lsVciDjVUI6Aa4Xi
    VphvaRuSCSXtZL20vxyG2rU+Pw05stlddQ5YZfk8CE6JJOmsyzUwtta7Axs4K0vjxGb7eG
    4T5bxNFRlFF2ZUCq+ZiIWIFHVgRT7VQ3l0rEsTtniWDiL81y8k5H84kMp6y61XRzKHxjql
    vamvMo5nxT8hjur5KbVl42MsAJpKQHyl48//0zhM9c0/OL6pz3eqeiysfC6rMZW0vL6CVL
    Nm2Hz0iqYhkkFTfCHANncR7l/MN3vS3f2BsmHjm+A7LXz93drQFqiGZDu06A
X-ME-Proxy: <xmx:e_KtaiS5lhjentw-PSfRn9pOpAFIJqHtCY03VFvJCQunD7JAt5ilfg>
    <xmx:e_Ktat4w4mKSksKzOmy0MKrksKsWfZM-IeHpyphI7tA58Yx6xOpFuA>
    <xmx:e_KtalbqmY2A30nKdDjq5sq2q0lx0vjPlPMnj7RRbHryN0J97BixEQ>
    <xmx:e_Ktahaof3RmhMKHNL5IfoQTO0WyUKgarLIZEXB4DfgTUgYYfjAeDA>
    <xmx:fPKtaqWWyJIPwxagQFG_KNS89JilJNlZ4K7uO6Meq0Qco4qIBWkhvkqt>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:24:53 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Jori Koolstra <jkoolstra@xs4all.nl>,
	Mateusz Guzik <mjguzik@gmail.com>,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	gfs2@lists.linux.dev,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	Paulo Alcantara <pc@manguebit.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/14] fixes for vfs_lookup_open, and integration with nfsd
Date: Sat, 19 Sep 2026 12:06:04 +1000
Message-ID: <20260919022441.3305170-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Greetings.

 NFSv4 has an "OPEN" request which combines lookup and create and
 truncate and permission checks etc much like the open() syscall.  When
 nfsd implements this, I want it to share a much code as (reasonably)
 possible with the open() paths - in particular I want it to use lookup_open() 
 and so that it uses ->atomic_open() the same way that other code does.
 (Longer term I want to make some locking changes and having all the code
 central makes that easier.)
 vfs_lookup_open() is a step towards that  but it isn't quite ready yet.
 This series aims to make it ready, then use it.

 A particular issue is that using __O_REGULAR exactly meets the needs of
 nfsd (it doesn't want to open anything else) but the errors returned by
 __O_REGULAR aren't what nfsd needs.  nfsd needs to know if it was a
 directory, or a symlink, or something else.

 I don't think __O_REGULAR should cause symlinks to result in -EFTYPE.
 If a symlink is found, then it should be followed.  That is what
 happens with filesystems that don't support ->atomic_open, but some
 ->atomic_open handlers return -EFTYPE for symlinks when __O_REGULAR is
 present.  I think that O_NOFOLLOW can affect how symlink are handled,
 but where possible it is best to just return the symlink to the caller
 and let it figure out what to do.

 For directories, nfsd wants EISDIR rather than EFTYPE.  It may be that
 user-space could benefit from seeing EISDIR too, but that is a separate
 issue.  So I want ->atomic_open to return EISDIR (if it returns an
 error at all) rather than EFTYPE if a directory is found.  VFS code can
 then map that to EFTYPE if needed.

 So the first few patches in this series improve the documentation for
 atomic_open and then make changes to nfs, gfs2, ceph, cifs to better
 match this documentation.  I would appreciate an Ack-by (or whatever
 else might be appropriate) from fs maintainers for those.

 Subsequent patches make changes to vfs_lookup_open() and then to nfsd
 to use it.

 A significant change here is that opening a file with
 O_NONBLOCK|O_CREAT will result in -EWOULDBLOCK if a delegation
 exists on the parent directory - currently it blocks.
 Jeff - could you comment on that change (07/14)?

 There are quite a lot of changes here since my previous post,
 particularly the changes to various filesystems.
 I've stopped trying to return the dentry from vfs_lookup_open()
 in the error case - no-one liked that.

 Thanks for your time,
 NeilBrown


 [PATCH v2 01/14] VFS: revise and expand documentation for
 [PATCH v2 02/14] nfs: correctly handle NFS4ERR_WRONG_TYPE from v4
 [PATCH v2 03/14] gfs2: simplify atomic_open handling.
 [PATCH v2 04/14] ceph: simplify atomic_open to use finish_no_open()
 [PATCH v2 05/14] cifs: allow -EISDIR precedence over -EFTYPE in
 [PATCH v2 06/14] vfs: add some allowed open flags to
 [PATCH v2 07/14] vfs: O_NONBLOCK|O_CREAT open shouldn't wait for
 [PATCH v2 08/14] vfs: don't return -ENODEV from vfs_lookup_open()
 [PATCH v2 09/14] vfs: change vfs_lookup_open() to use do_open(), not
 [PATCH v2 10/14] nfsd: make EEXIST checks in nfsd4_create_file() more
 [PATCH v2 11/14] nfsd: check for mountpoints after non-creating open.
 [PATCH v2 12/14] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
 [PATCH v2 13/14] nfsd: change nfsd_check_obj_isreg() to use nfs error
 [PATCH v2 14/14] nfsd: use vfs_lookup_open() for non-creating open
