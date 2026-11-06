Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793997654;
	b=N7l0pZsfwJVzF655xCeoq6XzF+pnC4DMi6IMYT7yxIIgPNmjJAaCjATD9iM+zACb3ya7
	 noi/3dhHw8vD9dcmXwsT8C/LjEorAaphwMkVLUkKXNnYiWvPFRzvz91dkfMZnkIj0DCCp
	 9i7x4VehrVrLmphoC7Y/TyNOh0Xv/+Rg1RMuN23xLEF3S3/Vs2GSC8YVakTL6eSGe91sS
	 o7Qa+gCKL/KbAeVvEUeXSvz/JS5Uk1PHYwlhU6HBSfuic86wpm69WSW8JnL5yafua+JR7
	 s0JU/dtOpB+fjISCpz0KaOi0WTSBgiBtd9yIwoZrf5+ENBLykWBygp9LMTzlnpRW2lw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793997654;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XtDq01cnsKhJfrGI+/j+xyTXAu2mJAnd8zUUKjPQu7o=;
	b=tzeQW3wBFfG+cYDZpu5r70ejQUP4sAc1yFhEdbC/NDq1oEwmzN9ccm/lRsAGJa9A+eJ/
	 /WMQUoAxXDfll5/P5sC+mowhYMJhOEL/aL1G2vIRuYJXP4mgqgARcPvvumokzVHelUr0m
	 z8DagXGDYx6R1ezTC4gsHEPyCwc1KJxUpxcrMMmAgK9BQ9exjxjQYj4xxskqhGmO4KHbZ
	 Zph8Xj3f+0GfF9n98pUTPAfBnsUJ8pGsYj/SYpFG+ZB4H3IcANqo6A1AF8b3WBtpC/ejh
	 tVqwdtztd9D9vvPlSxqaxh/+RmWjDs0Vsvw01ude+suswCUaqBlABS6dEBVh70kdJLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ojS8NCJ1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0AE9606A336;
	Fri,  6 Nov 2026 20:40:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ojS8NCJ1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 177191F008A3;
	Fri,  6 Nov 2026 20:40:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793997653;
	bh=XtDq01cnsKhJfrGI+/j+xyTXAu2mJAnd8zUUKjPQu7o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ojS8NCJ1oGek9n1yHAWwF3Fl6dSQTDwvk01mWlmxh3tuEwaD8ccM9ybkhHgQ5pqyu
	 R4HWrnfQCnIoGOcfN4D2yuT4OE91wD11a7uXdbDPO5Htn93Pcbik6R1LHIImpIBEuW
	 334F8aJN7n7RFoOGd/skNddAQ8g8ClF5c4+jokBNFyoPNR2O9Tp2P+zwAgRMUFC1Te
	 lB5HNfjd5TGPBQJqTQ8monZAA9ujiO2RopOKWlgQSwoioEf09vV4A5ClW0Jgw6Rt/8
	 XCZREULsfGOvE26SXMFFvtblj3WGuDuthB/f5eHkLFMZBc6WHrnPHBz8d2JTYFsEXl
	 FYk295PW0cncg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:40:29 -0500
Subject: [PATCH v2 3/5] nfsd: don't stamp over an applied delegated mtime
 at DELEGRETURN
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
Message-Id: <20261106-deleg-cb-getattr-times-v2-3-8433618ab9a1@kernel.org>
References: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
In-Reply-To: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3460; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=GOoAAbOQhe4V7/emmA559zCSkLqXRSt6Ao51XDEGayo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7jtRAvW/gM45WtG07AihPBfmtedtr6py9oDsF
 Sz15plqDHSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau47UQAKCRAADmhBGVaC
 FTh7EACw3WUX5d+UYG5UWfLXe+3XN5r/NBm87wwH+hCqneGxQSdfXnQmSZXmEFRxNq2xgMN5CZy
 FtmGHi/WhZLLRD9mH878RfnWZKF9dZbgOIBlK9k3o2JN2kas2GVlQdoHEpU+LP7j1ZVe879TZAc
 FClOrXxKBCgFfBH28sX1UMI3LFaNW/fpLUmGCzftXa4Ujn1xRpySM0zUOP9Li//odm/7BL8a1NP
 D1l3F4kDmZuIsBFfCa647uJS9IaK2k/LfPPQKBpbra5IzP9Emy7s86Vg5ACn3ofNV7ta13u4Xhn
 UwgyrTZmjvgrK8cPLnxR6HqX+TTgnMgSYsSRCOpa6zQoDefDMej8paqU/xjOK+zpbrW4fGvBIs2
 7A+MF/EkUqijrS33gw74R5E1V4KDC3rlfsw+RfSk5A1u2R7dvTHlQN90yWYu0Uy+QtFzCLVC1Jd
 ZPfVpzK7NCxT+3/ojVEaUPbM5JFbMXC/njGbGiTIr72vMftf/l0GY6yfjBiiEFuAlB1qTD22r0R
 K8XfrA+YGlzOjUOggogg8jzezoFrYISDHZfiQbF1JkPWMpQVv4a1JQkOPaFKXnqIgd/dsFt7BSJ
 ETq3lp32vIeiU3XzLVUfM4pVFCEpLbD/sfztcDlFHX/dnIlJ4EycoPJf89sqX2ILTYV7SgbE9WE
 XJ02mrxe00HZTBg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_finalize_deleg_timestamps() stamps a/m/ctime to "now" at
DELEGRETURN when the file was written and dl_setattr is clear. But
dl_setattr is only set when both the mtime and ctime vets pass:

- nfsd4_vet_deleg_attrs() applies the holder's mtime but leaves
  dl_setattr clear if that mtime doesn't pass dl_ctime. A client mtime a
  fraction of a millisecond behind the server's ctime at grant is
  enough.
- cb_getattr_update_times() applies the holder's mtime but never sets
  dl_setattr.

Either way, DELEGRETURN then overwrites the mtime the holder supplied
with the return time. Seen as git t1092 failures over NFSv4.2: an
untouched file's c/mtime jump ~25s after git recorded them.

- Set dl_setattr whenever the holder's mtime is applied.
- If that mtime doesn't pass dl_ctime, set ctime to the current time
  instead of leaving it at its grant value. DELEGRETURN no longer
  stamps it, and where the change attribute derives from ctime (no
  i_version), it must still move across the holder's writes. The client
  fix "NFS: don't let delegated c/mtime stamps go backward" makes this
  case rare. RFC 9754 specifies the change time only when the mtime
  exceeds it; RFC 8881 section 10.4.3 says the server SHOULD keep
  time_metadata and change from going backward.

Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding WRITE_ATTRS delegation")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8306a647fe9b..f276c16b3ea4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10744,11 +10744,16 @@ void nfsd4_vet_deleg_attrs(struct iattr *iattr, struct nfs4_delegation *dp,
 
 	if (deleg_attrs & FATTR4_WORD2_TIME_DELEG_MODIFY) {
 		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
+			/* Don't let DELEGRETURN stamp over the holder's mtime */
+			dp->dl_setattr = true;
 			iattr->ia_ctime = iattr->ia_mtime;
-			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
-				dp->dl_setattr = true;
-			else
-				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
+			/*
+			 * dl_setattr keeps DELEGRETURN from stamping ctime,
+			 * and the change attribute may derive from it. Set
+			 * it to the current time instead.
+			 */
+			if (!nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
+				iattr->ia_valid &= ~ATTR_CTIME_SET;
 		} else {
 			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
 					     ATTR_MTIME | ATTR_MTIME_SET);
@@ -10804,8 +10809,11 @@ static void cb_getattr_update_times(const struct path *path,
 		if (nfsd4_vet_deleg_time(&attrs.ia_mtime, &dp->dl_mtime, &now)) {
 			attrs.ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
 			attrs.ia_ctime = attrs.ia_mtime;
+			/* See nfsd4_vet_deleg_attrs() */
 			if (nfsd4_vet_deleg_time(&attrs.ia_ctime, &dp->dl_ctime, &now))
 				attrs.ia_valid |= ATTR_CTIME | ATTR_CTIME_SET;
+			else
+				attrs.ia_valid |= ATTR_CTIME;
 		}
 
 		/*
@@ -10845,6 +10853,8 @@ static void cb_getattr_update_times(const struct path *path,
 		 * them.
 		 */
 		WRITE_ONCE(ncf->ncf_file_modified, true);
+		/* Don't let DELEGRETURN stamp over the holder's mtime */
+		dp->dl_setattr = true;
 	}
 	if (deleg_attrs_deleg(dp->dl_type) && !nfsd4_srv_cinfo(path, &cinfo))
 		ncf->ncf_srv_cinfo = cinfo;

-- 
2.56.0

