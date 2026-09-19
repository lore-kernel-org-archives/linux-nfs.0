Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EB582F851;
	Sat, 19 Sep 2026 02:26:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784782; cv=none; b=mnwshe/XsMCtkMb6aDemBTC863QwyBWiP3RTRTG/IDSlqllCjDGMwPwYu9bCgwP4IDGQOlFKuPFPGK1ATjQk0JBg3pO77sb9deK7c/ijigahzL6V1zrDm3PJ0nGhC49OlkZDmMjRNJ/NkFvZtlfKTP+4X7iPo+ejxAr8NplDXq0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784782; c=relaxed/simple;
	bh=j8OOzptoD5RNeKhsa3PeZ0nEOPil9Mc7POxxlR9R1vQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=g3JiE0xfOdBV1qe0F8nVHdYlhH8rrwECJfm/jo3k5O/kA5yXfFtuT9ScRn+07SoVYVpkaw/7aNKIlEI5Y40jif9hzxNA8XkD+qvuVmq7ZQc4L4OpcvXC07fye6hEaMK4jzeg/9kszYs5cx7NCmceuDZPYbS7SKurJTa0sRScDGk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=RKBrjvoe; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Wui0lRau; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="RKBrjvoe";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Wui0lRau"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 6A6901D00113;
	Fri, 18 Sep 2026 22:26:20 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Fri, 18 Sep 2026 22:26:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784780;
	 x=1789871180; bh=0TT+qBuvIvfAoAmyAJE0LR9784Fr+UaGbvZD0Vh6io4=; b=
	RKBrjvoe9E924uxtp0XcOeWJhHsFpDHTqixO6lkmo7H08O4i2Q8cqFhjxw5bjg5O
	z0kY0p6wny9KN0o2GehII9cRSF/GySh/sbLrUXzHBlvSV3RyYp0aHcO/pi/mkO5T
	T6eKicvlhK/gGRtSt0CiqDJVnBVGpCEgsbBaLEfdQ9ZfgdfbkqZObyejqPLHblZA
	DOoQX6MQCDMcJhTD+Hmd0J0EGTLiQEPklIKkaduBteSosH4K0SwnhK8dpT5IxwdI
	FQfYJFy5NTvOewUuWfZcRhLC8mWZQ74NfbATb+wZZuF0au452unVjWEvGx+K2F6L
	4bY1Kt8dtXp3MS+YekDtdw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784780; x=1789871180; bh=0
	TT+qBuvIvfAoAmyAJE0LR9784Fr+UaGbvZD0Vh6io4=; b=Wui0lRau1RfhBDcPx
	J7TjKNICLnKmUrYMWa+t3j9EN2JtDWUpJSrUJPjb7dzsys3V5HtM+loeJisGPyJR
	ecFJKTX1pDErMCB0LezzhmTeMoG8mDbLqDTK07+WCaDW+/nJ8zpPO/k8nbA7IpB7
	iar+BL2ElE0D+BMG2oazkVL0BRg20PPEUr7RgKwLBRKZzVILc0MwZ1YF0H1bxF1M
	5vgU0oxW1zzhy3hMsvhZdi0S1VbfPJ+pilXXxjGE8PLCHt4jFLROgpERVU60PVCu
	IAvKpr33fk6JmOp/97i56iYoOAETEr5sFaikN0KgTtjYgtmzxsRL0jQ/lBaXnwaC
	QFuwQ==
X-ME-Sender: <xms:zPKtasMSSVn4fGlneGHJYQ5R_nLqrhnvdH-RGkjvTGabKflg5uebgA>
    <xme:zPKtajXjytr6WBqxt3r-1h0YNW259yTvx-b0OI33xb_l7BWtH5xBHAmjGtWrFHesc
    nhzOtsgB5jN6_XZxPlPTLZwp6a4awMM61ZXHmYKOJmeV52Oxw>
X-ME-Received: <xmr:zPKtakZpGlr6uj3JcIdcyAOI2AU7ccHNKsAfXsTiWc39sR0ppvPSU4iWQ7qhp1Fe0HCeLBAStib6Vg7qj2IeK20sYlJr6ZM>
X-ME-Proxy-Cause: dmFkZTGgqDvHUiFoelb3szb25Xc5WIL1X0CmKVd0SSFttbFGm3ZS4/WbThw2/23Wv0kT2L
    zTiD3f7/mbRn4xQkog4u9WXAUu/Z8xbLL7habzJ5iT0L9pvsBxuMoK5k8M+5CBBhCA34Md
    HPlNAQAuPUTpsFoyG9EfHruislsqzF/ELe8vhu1WoHNTpMpKsXLXUP8fPb+iJDnGZK+wxX
    pyu1Y8XGp2Ez4Y8aWvA0+LsWIM5P5beRGa1K+yf2x8AAFZFB+FqQNejpWDyXiPsbkOSKyy
    pf6WO9eid06RPw0E0qVieiQBSzbPbVfHpbR/XZ98dIIyde1pgFtUnUmkW5DtGlTWNRmkpr
    xo9ov0paemyMBcZL3mkNu4RMEIMn10H+W1VzfiVFIbb/4QMadYntzNZAOOh4Mw92CRLE9O
    ZmbMt4CPowP56Gr5RokQi0zoB8HoSEoWkpVnEhrb4aUtJj0Xli8UiLLdMwnhCW/9wB5q4h
    xLO8BpTluO1wLN/y7Mjnv3ivwTDbH9iWlWZGlpLKHfwxV18PgZkxHYqgRzjpiRlz4PNfav
    2kDTpQ1Ya/0v68l5bIkpBlKNdkEp2RfiGOR63DaoIfVjbPo2/qfUvrcrraBbICATP2dY+/
    ov6vR56YnEEQqWkbMSHoN8AhnW4bKhLQbzGgKtoTX3WWTThHYhR3VFJY3l1g
X-ME-Proxy: <xmx:zPKtagtoLXZHOa5lRLhde_mqwMqs0lV6DC-8KAd9LoDVdTL0wXGYrw>
    <xmx:zPKtajkzIizlVGUsI3q5aY5iZBknUZQwi-CRHCSAUvCJei-ZYGmgTQ>
    <xmx:zPKtahWt3NV_b95w_iYA-2ZlBdtCngGXGYIAIOHehPKkOKt4zpRbQg>
    <xmx:zPKtamkt-F1aReF-XpB_ROtv0dcpIGs9PozDhyzS6h3O-9n-NUBGaA>
    <xmx:zPKtavAjLlGjw9Zrdh1FZ-qrK9CUEqqbFSrdT7kLZttFJYFssV1g625v>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:26:14 -0400 (EDT)
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
Subject: [PATCH v2 09/14] vfs: change vfs_lookup_open() to use do_open(), not vfs_open()
Date: Sat, 19 Sep 2026 12:06:13 +1000
Message-ID: <20260919022441.3305170-10-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260919022441.3305170-1-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

The vfs_open() call misses permission checks which should happen before
an open is attempted (atomic_open does separate permission checks).

Much of the code in do_open() will have no effect as relevant LOOKUP_
flags aren't set.  truncation will be done (which nfsd is not expected
to use) along with some audit logs and security hook.  The important
benefit is getting the may_open() check.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index ba3e7e4b5fdb..8ef2d44b6108 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4604,6 +4604,9 @@ out_dput:
 	goto out;
 }
 
+static int do_open(struct nameidata *nd,
+		   struct file *file, const struct open_flags *op);
+
 /**
  * vfs_lookup_open - open and possibly create a regular file
  * @parent: directory to contain file
@@ -4660,6 +4663,9 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 	}
 	op.open_flag = open_flag;
 	op.mode = mode;
+	op.acc_mode = ACC_MODE(open_flag);
+	if (open_flag & O_TRUNC)
+		op.acc_mode |= MAY_WRITE;
 	dentry = lookup_open(&nd, file, &op);
 
 	if (IS_ERR(dentry))
@@ -4677,7 +4683,7 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 			error = -ELOOP;
 	} else if (!(file->f_mode & FMODE_OPENED)) {
 		nd.path.dentry = dentry;
-		error = vfs_open(&nd.path, file);
+		error = do_open(&nd, file, &op);
 	}
 	dput(dentry);
 
-- 
2.50.0.107.gf914562f5916.dirty

