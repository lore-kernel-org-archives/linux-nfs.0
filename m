Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549765;
	b=R8Hy1zZqku5IqsNLqIR2RjR3JPWzuf5Uc9UyCI7LeiHCIGl6kjzmJjHLEKLiWz/YANQe
	 xCwbr/04q0H+uSeQciqYLEGwxFNAohcJdAC4tKZbJRoYOfPWT1ueoahWN+sVet1v+J8zv
	 vvVzwZK5bqNAcAineqLRCxJoG3vuSxFDTLCbN4EXBOQL65skA14+1oPeMWEs/Q9YqFD7B
	 SYrtvXPn94RKctvl/3UqA9Dxi6HubCTlVpysPLERSHyGbm6CLsgsaon6iC4GYvsF7zuwU
	 8ZyXI1NTmvloayN02vApeC90I5lDOh1FYW3YDr51QJ33qaiRhJkcAs75Wo+y/CTvXzw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549765;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=n158BJ1nGVIacHP1WocjVqbitH/X257pdqGk4WCbzoc=;
	b=5lM+ndyeOI1sRB6hCfFZRfwdH6M6AwX9BtbgSiSgd8hiLV9XPNCNSg6T2l0GeIPIRKJa
	 CmogXSMGdCzkl/mcRsgSy8hChbGJHF/FxBkdg7Bugd5GWAVlxh0t2l7Vy1d3L8cmf4+tt
	 sUDk4RTXgXxy1lryfh8kYreoitM14ujkBxVoMahVXe/OpEarrIl0qAY+fOup4/rZsSZD/
	 i9+vlfr2o6piJq362I4I+k2xvc3s7CHsFh2D6+U+/XU2UeiPsNWi3ZVG77KKCBkgWbTLr
	 7MiwVJ3NFlXbemByw2lcgx0k15jS0Z9zY90EZshkTTj8m2DjN1RRu8p4/frkn14Eohg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DVIzK4j8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEFCC60A2618;
	Tue, 24 Nov 2026 19:49:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DVIzK4j8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E938E1F000D4;
	Tue, 24 Nov 2026 19:49:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549765;
	bh=n158BJ1nGVIacHP1WocjVqbitH/X257pdqGk4WCbzoc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DVIzK4j8/odCtwKf7uKJm5/9SQyFeYSQEwbbVK1apYy74a8omMRrLc5VVHL9YUyc6
	 MS3S09y0zAZaEHMRKQrY1meyrHwXyHQzG7rznGEgHrfWtg7hgZRGc6iasQ9yEKi3l+
	 3RbWQbn3QZ4xFTiate+QF5+F7wRyx7F9k7qFbZ//OYCuI45cy//ybC1/s74tAWwWDf
	 M85aUvbICcXbxwsprkwKXXkmYWE/8O4HO2AHJB4u1fwOI3UV8pXdKdekLPb/rAQOAc
	 ShpCeDsWI7KoBnpqwTnJxE1p/lEfWORvytzoXy53h4R0QjlztmRuVPtj2fI1g1Gocq
	 OItddQPpWy3lA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:48 -0500
Subject: [PATCH v3 09/12] nfsd: grant a plain read delegation when
 timestamps are wanted on a read open
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
Message-Id: <20261124-delegts-fixes-v3-9-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2119; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=xn+iBRkIklsgEwK0tnAkzkU9rSv08fppuDu8V8FMSEQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo29M/1Yem9bpu2VUY7Vkw5i+GV/l5DmdVSx
 c9efX5u+tGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNgAKCRAADmhBGVaC
 FXsHD/497THdPkpp3ocSd5oqX5ZsF502lI1PD1sIgqaA3w1LCNITHaoH6Tw+pt4Md1C93/ziqzY
 1TCFUNoI2Lo1VRIcjOmU+htR91Db63FS8H9aRcfdJyrGemMzG2/TdBUXC9v4EZb517uFo1NPTeF
 IVh8B2a7z1tLGt0rmW4tpEsfKK42wSv7QPoKdeTvRqxO7uk6y57LwbGeRhFQ5w6y+RRhW8CrEZx
 NltR0MdvkE6hYTHuNM/VIv42aUtq3urwZdTprZC8PF1O1/I4KRJq9ka/bQd5G2nUNaj3m2Ql/s4
 oWeI+I4kA4nWCSnwkuVOkQwrPgJrzPDsxvGYxTH35TIDmeBBxPIDLFxOOd4tbdc5HxYzUAwBuzg
 B0he9CBizm6go20fQHVYngJhUcal1JtN36XUEyELsAYlvNTJS9nYfhD/qdT5kPAL075WOadrMbj
 zDU8Ubf3U5yQIEajkQGNK+qGIPlsI8NcmkDNL76lox+L9AuX2o4tJqkAlbv4d9c63AgeYb7KeOq
 Qt1khvlWrSSiPHrqmsOgLFsJxJpodu9QqvGqQ4tRwbw5t+d+jdD7LZTMRdqYMLVGEjHkS23CRSJ
 4Bm/+N7NFAJ0p8R4BykeEZmQsA7jyztlnlca8vZQTMZK3XXFWNGi1QujJyB1Xs4Doe2kKRtrNCP
 8wLlU33blRVsljw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A read open that wants delegated timestamps gets
OPEN_DELEGATE_READ_ATTRS_DELEG. Several clients can hold read
delegations at once, so delegating atime correctly would need exclusive
authority over atime or a merge of every read holder's times. NFSD
supports neither exclusive atime authority nor such a merge.

Grant OPEN_DELEGATE_READ instead. The want flag is a request, so
declining the attribute delegation complies with RFC 9754 section 5. The
XDR cases for OPEN_DELEGATE_READ_ATTRS_DELEG stay, since
open_delegation_type4 is on the wire.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 51dca62b2bce..db096859dce2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7338,10 +7338,14 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	 * A read delegation can go to a client that holds a write open
 	 * of the file: nfsd_breaker_owns_lease() keeps the holder's own
 	 * opens from breaking it.
+	 *
+	 * Never OPEN_DELEGATE_READ_ATTRS_DELEG: delegating atime correctly
+	 * would need exclusive authority over it, or merging the times of
+	 * several read holders. The want flag is only a request.
 	 */
 	if (!nf && (open->op_share_access & NFS4_SHARE_ACCESS_READ)) {
 		nf = find_readable_file(fp);
-		dl_type = deleg_ts ? OPEN_DELEGATE_READ_ATTRS_DELEG : OPEN_DELEGATE_READ;
+		dl_type = OPEN_DELEGATE_READ;
 	}
 
 	if (!nf)
@@ -7639,9 +7643,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		spin_unlock(&f->f_lock);
 		trace_nfsd_deleg_write(&dp->dl_stid.sc_stateid);
 	} else {
-		open->op_delegate_type = deleg_ts && nfs4_delegation_stat(dp, currentfh, &stat) ?
-					 OPEN_DELEGATE_READ_ATTRS_DELEG : OPEN_DELEGATE_READ;
-		dp->dl_atime = stat.atime;
+		open->op_delegate_type = OPEN_DELEGATE_READ;
 		trace_nfsd_deleg_read(&dp->dl_stid.sc_stateid);
 	}
 	nfs4_put_stid(&dp->dl_stid);

-- 
2.56.1

