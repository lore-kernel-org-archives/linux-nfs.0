Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F40D22F851;
	Sat, 19 Sep 2026 02:25:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784747; cv=none; b=SMWBOVNNmKdw9ZN5LeT2t6LeE4C3X0TcE1OMsldkp4Qd/I4G0tOyQJdrBye7nQLsw53bS7prgFFweUqC4tczQp+w6GifaXck787GH48xhSBvoAk56BxyvM1bdZi7yQ4p7IsxU7IoKp9ZtXFtY/8WUyPcfx+Ewd6gdgSI2QVR+RI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784747; c=relaxed/simple;
	bh=nsMD1IsuWcn4rlq0wxYJIvo1Ln7fmePrR1TO2YB+rUc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=igAvl5/piuSL53iKSJ1OmzGIbpjfWAwCTUYwH0v8Sfy3mvwX2eWrniT3jgHCypMQ9x3KS2uYwJ1qIvJrC3x4K+gIA8sjj8gUuoD/fLqWt0r67HycMzNJ4KBet3UN56fY4RPUdoSA0Spc3H/umPOHUEtIGHiJs/jYO8VCBTJ+qNI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=b5zuoRH9; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=oLiTsIQI; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="b5zuoRH9";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="oLiTsIQI"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id 0939B1D0010D;
	Fri, 18 Sep 2026 22:25:45 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Fri, 18 Sep 2026 22:25:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784744;
	 x=1789871144; bh=P5/A7LmBtwefRzrYhGyLInA8c6nOGrnF32GDUrC1oag=; b=
	b5zuoRH9qJzXfdapiv2UN9tl2/lrcknD6FcL5g852rOeroyPCZqhUtakYesvOc+r
	UBA6WrUmv7+BNn1mgeG9PwlRX3Wo5pvcd0Q3ZY1riWkA0kYDEvO4ZNlegwBqJwpO
	tqdd7prhcR0xfbHxuJ7uZxA9leBrO6++R9kL+H1rjAOXgc43jCs6MtDkyigeP2Mi
	qxGoegXD+yzHBlR+X+aDduI8Cqw5dM8CMTM8qmcGoyJTEtAL6EZ6Va+o11TTK9/8
	Gp8WoWfPAiLgUctyk1JHSY900pLexIg2ZrjMVYoNlMaHYfkB2P4CZsEsBsJi/LMP
	yYB2W4PP/pDDTPGFoJCipg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784744; x=1789871144; bh=P
	5/A7LmBtwefRzrYhGyLInA8c6nOGrnF32GDUrC1oag=; b=oLiTsIQIV1kl6I0is
	t5zHK12MLa1qNv0ccwuoHkpeAtyuSt3pc8tuMyY8Xlm3dFOuxPoUwna8gBXS5PC6
	xo+wpfw1d7Sk8ysE0u72VihzcAcQDoBifGEb5H2EyVWw0I7czv6395ygZ/AlNpsb
	qlO0K7eoGI05325PxmcUBSssAUeZ9/WeDqBt9HLHPfvfWOinyJi+NxxVCaw87P5Z
	0+Ho9Xw2S1hEbF7IhQGH8IQ0dsMb+WCYtvoPw6bB2Wvlekmvgz8YtCQzjjKZFzuk
	iY11F7FRMSUmKJkubJWadSU6lsX22Tsnc1xT7TA29JdFt63L2suLnvZGYcEIM986
	hAV0w==
X-ME-Sender: <xms:qPKtajUNVFyhRh_VoBLji217aSpR_Cr7MqmdT7QRkeFDSUYcWf4EaQ>
    <xme:qPKtakZLPXVod0U27JCBkHd9BoYu8EcdnhzqziciCCmVkVDB3JyXC6mtAquFN4H8b
    wfGJCmL8wtjCbb51GHkOfSvFMqHX0yRZqlUcn6e4m4KJG8>
X-ME-Received: <xmr:qPKtaguiE7N8EQYiMc8AvJQlDsnZd-Loz0e2kvIz9mswkMcuyjSxUIJ0QTinJlKzSGwzZs2uPgZgaB17jaQzQuLcDzIyd2o>
X-ME-Proxy-Cause: dmFkZTGrZFL0s8hBJLx8z3hidUOdwjCj9VjHK3n7O8BnTzDOjzuikYR/nZKS/JMQnUKW/m
    ttU6pMwc0Z9tFCObS0zKugLfPCmM9THrNDpJhhW7OY44mORRN5hiq9VrA88SmKEVaH19qR
    i9D05LBi9HI4qBpsPpVhU/61V5aYr8eS/LOMCfgMVULO4KwUgCoc5t22HMtnFDR95rYZw+
    tiY3qz4MyMC8e26QEmZdPX7v7WOi9JIP6OYRRQGrfNEz1xmgvQwmcdQSj03QIeX/Ibdge8
    qJ8/QJ0WjoVEcVGcTafzJ6mX0s4yb+o1DmeiYS+9+j89g5WAZDBBqzve6MsIb8w2Rbd3tn
    l9bvPSA3N0BJOG5fj1CQ0LJvDEDVKm/7X1YmYJ8tCBupZ0t9dpvXsGLdgsbq8W5uts8QA9
    Juah7XqWorElET+Xbs69OSv8my/o/E2LS2iY2yElE5hWt1jNFi17pj6lp7CpZy5OiNfr81
    MHA2FqqKtFg7s5x9pDgwbxbEfbKd9Wk734gQqiQ4YyTAPhfR02X01Z9DkY8kPuh6MTx8gP
    Ajk6sNaw3n62VXdAAQPkB3V+2yZVjsZ2HZBuYvSqskolViyEO32Up3gp/4ofBeXI+pLwxW
    SvzIapKPvR7pr/8vuNz9HLIBG7fqzXldVoDD0JZSbClRuHQxuFLqGpoqnbcA
X-ME-Proxy: <xmx:qPKtajnlRGrcoq-0thgsOo_LuGaLkfrNuj9kTKT-cu64mn5a_FF4fA>
    <xmx:qPKtahV3jo50mdWB8iNEFdg1JtCkI6L3IVYb0Cc2vfA6BAOTewDIhg>
    <xmx:qPKtamkvJ_U26pZHTQQQMfWVjLvol2snTFqvURUEXFKQ1oM8if91CA>
    <xmx:qPKtauRMgHRlzpiuRjhFgcQGfdy1wl5zD10Q2-TQ6wAhZW2N00fUXQ>
    <xmx:qPKtamzz7N4Mc2IHf_bGn6sa__bqia_3JLY4ENbU0_sBUG4hOEarvJ1J>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:25:39 -0400 (EDT)
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
Subject: [PATCH v2 05/14] cifs: allow -EISDIR precedence over -EFTYPE in __cifs_do_create()
Date: Sat, 19 Sep 2026 12:06:09 +1000
Message-ID: <20260919022441.3305170-6-neilb@ownmail.net>
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

If atomic_open is given __O_REGULAR, we now would prefer -EISDIR
if a directory was found.  So move the S_ISDIR() tests earlier.

Also don't return -EFTYPE for S_ISLNK() - that should get -ELOOP and only
if O_NOFOLLOW.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/smb/client/dir.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/smb/client/dir.c b/fs/smb/client/dir.c
index 6fa6d48fdfd3..08425c9eea42 100644
--- a/fs/smb/client/dir.c
+++ b/fs/smb/client/dir.c
@@ -237,16 +237,18 @@ static int __cifs_do_create(struct inode *dir, struct dentry *direntry,
 				goto cifs_create_get_file_info;
 			}
 
-			if ((oflags & __O_REGULAR) && !S_ISREG(newinode->i_mode)) {
+			if (S_ISDIR(newinode->i_mode)) {
 				CIFSSMBClose(xid, tcon, fid->netfid);
 				iput(newinode);
-				return -EFTYPE;
+				return -EISDIR;
 			}
 
-			if (S_ISDIR(newinode->i_mode)) {
+			if ((oflags & __O_REGULAR) &&
+			    !S_ISREG(newinode->i_mode) &&
+			    !S_ISLNK(newinode->i_mode)) {
 				CIFSSMBClose(xid, tcon, fid->netfid);
 				iput(newinode);
-				return -EISDIR;
+				return -EFTYPE;
 			}
 
 			if (!S_ISREG(newinode->i_mode)) {
@@ -461,14 +463,16 @@ cifs_create_set_dentry:
 	}
 
 	if (newinode) {
-		if ((oflags & __O_REGULAR) && !S_ISREG(newinode->i_mode)) {
-			rc = -EFTYPE;
-			goto out_err;
-		}
 		if (S_ISDIR(newinode->i_mode)) {
 			rc = -EISDIR;
 			goto out_err;
 		}
+		if ((oflags & __O_REGULAR) &&
+		    !S_ISREG(newinode->i_mode) &&
+		    !S_ISLNK(newinode->i_mode)) {
+			rc = -EFTYPE;
+			goto out_err;
+		}
 	}
 
 	*inode = newinode;
-- 
2.50.0.107.gf914562f5916.dirty

