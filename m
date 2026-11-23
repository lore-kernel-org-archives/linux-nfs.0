Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438772;
	b=tV3tXatBGyj4UJ0rcrj2+CKdh4N/fZARfrRxz/NbMFhGuTQP3NKAr0almUpGEGM0S+aj
	 sBm9Qebv/jmsL/qCdcxnviQSkg8tz3DGUiAm7fVsN327SD+AHWoNyBq/vXM9LPb9W1c6d
	 rW3MJ++7hjNFSDrvYQqqcE2DIRYV5NsulqupYZiGMNbPNJj9aX8qvpOIdNXjQj8ZYKMvf
	 1ZmFwoAs9OwWg0hSP6ycfp+UjQ+5i80vvmkeZgUN2402B/Z0WOrlDT9djdXkrrgYMROo6
	 1gJQrKuiNGQN/PS2eTdku3RSrT8BCIUIBA9T1WEaO9KvxugjXKGmUqRlEGj8ASfAUsA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438772;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=xAVJSBcwQfLWZBP+IhdF+4ae6xiAqEPwvKe2c4tPhoc=;
	b=HBtXxPKwJucCJ4CbEXBule2SqhqcefNCYXISLvzukyTrng674swIFdeAqdmrVOSLOdww
	 1DM0THXrea5020IRb/xEoI3dRMdrL+vEIvRcwRzgrq3o+MKoFdh51QV89VGXQaRiTQGy6
	 EQUGpWTOslY3QtUavA3kPjVGol1ce/fR/2Cxqx2uNgUzkCANT7SpbTuDbwwJ0/8Z1QBvd
	 2avsbot6dXr5eWpigBla5/OIl4asCDTEbEQ0Gw+RAkNB3gC2fCAaVYIwh6GxphHr+qNzc
	 HTQTkwExB+3nK6FuNQ6v7zFXaC0DCevR3V+zEZNnOtZLdLl1Zv2muPcEhb3OUWOvXwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K3iKKgiy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E7435606A6AA;
	Mon, 23 Nov 2026 12:59:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K3iKKgiy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C38951F01566;
	Mon, 23 Nov 2026 12:59:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438771;
	bh=xAVJSBcwQfLWZBP+IhdF+4ae6xiAqEPwvKe2c4tPhoc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=K3iKKgiyZj35iSvCjsDntuk27TeWEG211vRDIebmijcTkQl/1MsB8/oOUE72Uh7lF
	 65IUjpo9tZrc4QSXhL3Ye1cTpK8Rz3E9jM2LiFqpG1lU+DPY5MlSpLV+owMi6R0C/M
	 LNPozjWj7Cn5/P1l28K4zXGvelQkVIW2d/2PewF4yXMryeMvLofz8jNjivffEt9ZuS
	 6mCiLf0ZXix/BXc1qi7dv6euN9Oo83wNZa1I4L8h4bNbOdcQTFfPqG8Vtszz5fT13W
	 falgYbFpPMioiYNjpkDLEopfvIRGn4OymEcUWUgcK1A3UP50uzM3e0O9ePXx8qcvVS
	 ZuE6wZg6hQbrg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:12 -0800
Subject: [PATCH v2 09/11] nfsd: grant a plain read delegation when
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
Message-Id: <20261123-delegts-fixes-v2-9-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2119; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=EYw7K3omjVa+1OdrR5FSxGAHhwnWzkkbj2K0ojKfzjo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDimL+YJyVfig5/SxKXsHpZ+Mh7BiRXygodZl
 fHMezTJ1AuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pgAKCRAADmhBGVaC
 FXqhD/90QJFo1bgm4eNBLjZNrrgKrBMvXC/jQPI3gOe7u7KlsGZ5qYAqzNol+zn+QU5/gotrt3l
 3fP22o4+FDioag7JPrH2A9JiyrEk1qL2Z0XP7AiY8AgO7GYyssPEiPCT0jc3LjFDMgcahBhrLzn
 XLcxz576yd8jqjqU1jsp1+7h+dJaRXugwO9Aye2ITDgsaxbJypGwnR69i6DN1lyzqIyy6m1Lu/k
 jem9APnN9dZtSBFuYL0DoQZbtt6USv3jUa0Xf7WchakG3HVf/6o0kIYN52KcoINb04u7CITrnAK
 7AQsqgaijcZZV1i5cl26F7sZLRQh+/gfqxTd3zt25kLtYANTaVYH8uABRez/ik7oVl2SQ3Nez+r
 EZ0+qIriOF/KGanH4FXbNcvEG6ZK84pJaz1MhTdVaSweiNUypkUyHnHzXzDOr18BCE4Wrm8+Yy9
 NV+YQ6IBTRpQVCQNWwR46m/hYVmIld8KHSM8GUeh7yI1/CD/zcD05Ecpdv12aRYGCu7gsfCi0oA
 92hVrX3ye6+PyaboJvB3IbepGwkhferCFpXDvQeF6OiIAR8DI1KwlKeGGx5GgT+5Bzwp5LU+sYE
 ttKR1NVd/in9kyDCzoVUCzX0FyUyFe+4kED++H8L2/0aZasitEKW4LzpArV2Vw+wCpKyOtgf5Oj
 zl4mwJtJ/GnPZcg==
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
index 645ad916d2ef..466416708072 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7329,10 +7329,14 @@ nfs4_set_delegation(struct nfsd4_open *open,
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
@@ -7630,9 +7634,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
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

