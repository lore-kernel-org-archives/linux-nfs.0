Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256659;
	b=pK8ZCeq4ImE9BzO6h2Z69xP6jbv2wILFVV2a3Vz6e3sx+t/WOY/nv7nCmo1MzyRvhOu8
	 VeD5Cib0l3y1lm67tFx62Dm/1qUrHQKXNlEMJUDUbUHgO+GGRMs5qO/npoGn4ekbDZ6+t
	 XORdyr0kZ38TxUWOZYpI+XMyyMlHNO1zc2UhDWkxQ87jVFtQVOjQqYTSmh3QVqQjspdwT
	 syGhDTqGG6Jp3EnRCR/MWTpSDP+a8tdKMxt0aXPkDL7LrMcebqlFArcxIZBSoNY4oJ+dZ
	 BlOK3Nb7J+i2k9raHb9sRFBrhWOBLO5m5JfOd8yZB1n+xMUJxtHDVX/h/t0fue81vFQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256659;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=7x/8VCqvaFCO8+7zpHviWuIIp1prqurVWXYfbUYz2wY=;
	b=YYWjVqyxkvTIKPu81vdvaoPw2BkNBA3IuIYgaFePGK3k7IvtfIy+JknUI3WPARk59LRU
	 K6bHLKPCuAPMDIjEl737FyFKK5yHlrl0p08tcScCbZQ/ooibUqbNakr4EG77x83lbrnee
	 GowQAOusUCN5VaLBi/ICyPEoraH6fcthwPz2SxN13ixPSJU4XvUCTVPXysevS7dBw0rkj
	 vwKm2/Udb2dFI4I6bm6YL5lfAa5bJRnv+Ve3Acjqf9mO/uHN9H70jV+RQKdOTSbHCt2sz
	 QUgX1/W3Amp2BStGjcsCFZYOxThqrLnAzgRUwrtL1QvaoTptlX8SDLgOeqhT3U+77dQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AyCi+Ng3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C76FB60A3822;
	Mon,  9 Nov 2026 20:37:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AyCi+Ng3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD0D91F00923;
	Mon,  9 Nov 2026 20:37:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256658;
	bh=7x/8VCqvaFCO8+7zpHviWuIIp1prqurVWXYfbUYz2wY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=AyCi+Ng30+K8ScWvRC9ZomOikj+5Kqst83XENZhYpZyJ+cMkG4IoNIvM860LwABmj
	 hpbqr7/MzfHIln1+wZwEr0wsTN3jlA6kit1VYNEa1VkkWiKsSm403XrMkOVu24e/HX
	 DTdogMdr0eQ2fRPuEkpDzM/ioqGy/GckZNMb6rmacCo6pg2BqrauoM9B3tWP0y8+0c
	 BZ4kcCH7PMxMDawXUJDcHNC5TyzLgDqx9dj5JN56mjSDrCDavil3MFQFVLz2zQMhlp
	 qDMUhvyyIwiOGGMkucbn648WkZERIIlSmm35b4aTsNf8BKgP1WlNT0XiWVUuSrcPss
	 uzkbsPEMKHM3A==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:49 -0500
Subject: [PATCH v3 8/8] nfsd: raise delegated time floors after a
 size-changing SETATTR
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261109-deleg-cb-getattr-times-v3-8-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3252; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=KZuNc+64bp1rsHbSGc9oFR6UPNzyIvhlX/k9cn+SHqc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i8GTmIfpFDCzritW4jUwLpg8jdUekCsj+2kW
 WdA+VQtGDGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIvBgAKCRAADmhBGVaC
 FR9zD/0ZxxFLJNoQc/gD0tGIeH/9xcQxL6rQcd0Xy03A3Zl2Jzdi+Vq5diEvrYZxFv79MZFazEM
 3AyMkxbU8zUer6QxtISdxVRga4ohC7en6uKAiZSfHb4hPloO6Ss/hYjAWZDEwiEiFd8iE6bVOta
 WmCdZnkrRbh38EsOy2/q/la4GceGe45YrUnL0w7J/IXTbLUaaGsSlrOvWA1i3ZyKrixroOBqIwJ
 xuW3tkw3poAYIazQDGtdWlN0wPhDR2PQp+WlvBY16A402enmlOpk08xcTTM/tKl5x19kZ+N6V8l
 HoLFzkeZSuw9psneQBTMwUs2p7QO4+1VZs1eGkM8Q4Tc+RxeuYK0fnUVLVqAlDoNF6DQWlyQUlv
 URTKLjAaVE2vyRwIXuU33SVZXV/2Ls//yEa+UQZ+u+qSdtdI7/YY2GOUtO+qEjHaL63+JkZGqcy
 up3+6IdcMjSumkfhdIBkdVZyrqhQZ3PJO5x/xXDQ31kqv4hiA3qd+MZaktCVq3YRbwp2IR2AjkZ
 06GkBAzbWcBY/opgxlZhqpPOBkCuNB8+Mc2Q9e0tY1PhGn6zJxRc2jxTsnZ/Bb+F5OXlR05pJ6F
 eWBAVI3IYyy7HcPNg+TPWvLBTCkeaAq0veMFNgaG3VWCwzvTYFUyn8utplblRlQP2lhaswKJ0N/
 NY3q/IaNZTG5viQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A size-changing SETATTR stamps c/mtime on the server
(__nfsd_setattr(), RFC 8881 section 18.30.4), but dl_mtime and dl_ctime
stay at their earlier values. A holder mtime from before the truncate
still passes vetting and moves mtime back past the truncate. The Linux
client can send one: if a delegation return starts while
nfs_vmtruncate() has i_lock dropped, DELEGRETURN carries the
pre-truncate mtime.

When the SETATTR uses a timestamp delegation's stateid, have
nfsd_setattr() record the c/mtime the size change set in dl_mtime and
dl_ctime. A holder time at or before the server's own stamp is stale.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  4 ++++
 fs/nfsd/nfs4state.c | 10 +++++++---
 fs/nfsd/vfs.h       |  2 +-
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a65e13f0f77a..7fef904c3366 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1379,6 +1379,10 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				status = nfs_ok;
 			}
 		}
+	} else if (st && (st->sc_type & SC_TYPE_DELEG) &&
+		   deleg_attrs_deleg(delegstateid(st)->dl_type)) {
+		/* Have nfsd_setattr() record the c/mtime the size change sets */
+		attrs.na_deleg = delegstateid(st);
 	}
 	if (status)
 		goto out_err;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 03e694f635db..606c4b469728 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10812,8 +10812,9 @@ void nfsd4_vet_deleg_attrs(struct iattr *iattr, struct nfs4_delegation *dp,
  * @iattr: vetted attributes, not the copy notify_change() altered
  * @dp: timestamp delegation whose holder supplied the times
  *
- * Set dl_*time to the times applied, so a stale holder time can't move
- * them backward and a repeated CB_GETATTR reply isn't reapplied.
+ * Set dl_*time to the times applied, or to the c/mtime a size change
+ * stamped, so a stale holder time can't move them backward and a repeated
+ * CB_GETATTR reply isn't reapplied.
  *
  * Context: Caller holds the inode_lock.
  */
@@ -10830,9 +10831,12 @@ void nfsd4_record_deleg_attrs(const struct iattr *iattr,
 		dp->dl_mtime = iattr->ia_mtime;
 		/* Don't let DELEGRETURN stamp over the holder's mtime */
 		dp->dl_setattr = true;
+	} else if (iattr->ia_valid & ATTR_SIZE) {
+		/* RFC 8881 section 18.30.4: a size change sets mtime */
+		dp->dl_mtime = inode_get_mtime(inode);
 	}
 	/* Ctime may be "now", or inode_set_ctime_deleg() kept a later one */
-	if (iattr->ia_valid & ATTR_CTIME)
+	if (iattr->ia_valid & (ATTR_CTIME | ATTR_SIZE))
 		dp->dl_ctime = inode_get_ctime(inode);
 }
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 78cfa0dcaf5c..34ec8293e7b8 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -103,7 +103,7 @@ struct nfsd_attrs {
 	struct posix_acl	*na_pacl;	/* input */
 	struct posix_acl	*na_dpacl;	/* input */
 
-	/* input: vet and record these FATTR4_WORD2_TIME_DELEG_* times */
+	/* input: timestamp delegation to vet and record times against */
 	struct nfs4_delegation	*na_deleg;
 	u32			na_deleg_attrs;
 

-- 
2.56.0

