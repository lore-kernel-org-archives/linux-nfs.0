Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B713E3E5ED7;
	Thu,  6 Aug 2026 20:20:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047637; cv=none; b=A+oJFLY6PzrAu5Kwzequv2uAcaPpDvI1NFr3L2RtrqZadBmO+cmjnl4lXU2ACF/KUx+nOVxEiDu0SKhKvZ0Ac98JnsDAloEMrosaTiNVA19zd+RF2d6EA5n9e7Y16weblyAUhSzEr5vfTRIllVJfjxCwxZ2XR7pUs878RNsD0ww=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047637; c=relaxed/simple;
	bh=tQymvd3cq9u4Xw7lCoMZNfOhQ71cBExEm43PoiqBKcM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fFYamRHIk+Yt1Nr/EDL2VmnOokIp3lyzStH2+MZfSvN6G70eb3CUrFfa+AiHIHHUCoknlwXx+NVgVHq9z1o8CKEOGg/FIcNnZkVMb7u6LgCuYde5l/Hb3pHEsJ5s3xMwBhWE8JrSbzs49NFjS5l/2tiZXHXYjZwAbtSzMeN6Dmg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=I8mDG1cm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="I8mDG1cm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D404A1F00ACA;
	Thu,  6 Aug 2026 20:20:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047636;
	bh=bdMS28E674svxUoP4VoVM0nGWgrI+E3JONo+rrgpu/g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=I8mDG1cm2Oz3v0uPwCZ8wtf3ak0/vzEweREpkz9+AfG44gpaBlIQD/xsWy3ZJJImY
	 a0SfHZdiq/gkTmBs1hJQh6ZVX5d9b/opdtXmdFznuFvlU164V1DcYBVCGtKhAAt5Ck
	 00YJztmwA/Ud0/lWwWqxgyBxRr3d0Ju/uy4pcpvqnu/NrNXQg/2W4iRyKLms8vtSil
	 7YgsCdvVMv4dJWkMXZWucNt/DSAuLjQLfIoPD4DqfZljGhZ9Hzmyn2IdJ9e/A2Wc1d
	 3vdh/RjhYTBglLR5mS9tLPU9faSjDPAjTCGWwpNoGZgaLAmehEiCvfufK+UM6RxhbM
	 NS71K7BOSELUw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 06 Aug 2026 16:20:22 -0400
Subject: [PATCH v2 7/8] SUNRPC: treat every client-side TLS error alert as
 fatal
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260806-svcsock-cmsg-fixes-v2-7-ef1b1fa7219a@kernel.org>
References: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
In-Reply-To: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1810; i=cel@kernel.org;
 h=from:subject:message-id; bh=tQymvd3cq9u4Xw7lCoMZNfOhQ71cBExEm43PoiqBKcM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyM6NatW9FsjNY1FJBRzzwjZA21JFaZ1eUhV
 vP0qahGjSKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsjAAKCRAzarMzb2Z/
 l0qgEACprxyxgDZzBTo/4oGHRxsu/7Bw7SXZrNXUC9yGw1J1pdzr+JztiXjG1hG+NtqGB9WwZur
 lcPZT154V8ZcFheqswW2ueOdxMIvWuYk3raothVWy3ZAVv005IWy9EWwrxawJeb8mrnhKGXmfKt
 MlJX2cGCISlEhb5XTQQNHs4fN/nTEj1whno5e6ZR3LP9JW2KalKyKFArjD74ytPZ9bBD3ej+H17
 HSikKAb6SVa7/vi11pk2vc0jvAyfyR9olxast/95Aq3DKsW+EobtJNlp9poxYOHgIHpevgRSAtt
 clIMEykq0pLfyd9YfTqdwBMtqz8CjNbdvq6w3HT17+75H51jaed0bjSLbbS+bChiBX+xPjyB0+s
 ov2UEzYzoNqNawf5EyuKOqsUNU6tBZISpO0BfhkRpAcjWE3+iYj2GPsYof7SOAHoVSzuwDWDHfc
 hReyPiURNyV73MGVXNajlRv/g98tdpAMi0VaE33742CttNPwMHJd84gX2aPZAghbgtGk5DSsIeg
 pfSoBxF6oZ6MS3xNYoqUHNhNQmuEd17EUque7LMssT7VcveheLtV/T8xxP03qtD/Fm+tbeQ+yAu
 P+nPUd0Ufrfvl6Ep3JavtHEpS4P824pL1UIqo4NElsgO3j/NCYlhOgnz2id0jEUSlH8i/9p60Zm
 r9NyugK1iKLD+Qg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

xs_sock_process_cmsg() decides whether an alert ends the session by
reading the alert's level octet. RFC 8446 Section 6 retired that
field. The severity is implicit in the description, and a receiver
treats every alert listed in Section 6.2 as an error alert
"regardless of the AlertLevel in the message". A peer that aborts
with unexpected_message but leaves the legacy octet set to warning
makes the client return -EAGAIN. xs_stream_data_receive() wakes no
pending task for that error, so RPC Calls queued on a dead TLS
session wait for their timeouts to expire.

Decide from the alert description instead. close_notify and
user_canceled are the closure alerts (RFC 8446 Section 6.1). Every
other description ends the session, including one this kernel does
not recognize.

Fixes: 39067dda1d86 ("SUNRPC: Use new helpers to handle TLS Alerts")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/xprtsock.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8e9d47d77e5b..5527f7f8a185 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -375,8 +375,18 @@ xs_sock_process_cmsg(struct socket *sock, struct msghdr *msg,
 		break;
 	case TLS_RECORD_TYPE_ALERT:
 		tls_alert_recv(sock->sk, msg, &level, &description);
-		ret = (level == TLS_ALERT_LEVEL_FATAL) ?
-			-EACCES : -EAGAIN;
+		/* RFC 8446 Section 6: every alert but a closure alert is
+		 * an error alert, whatever the legacy AlertLevel octet
+		 * says.
+		 */
+		switch (description) {
+		case TLS_ALERT_DESC_CLOSE_NOTIFY:
+		case TLS_ALERT_DESC_USER_CANCELED:
+			ret = -EAGAIN;
+			break;
+		default:
+			ret = -EACCES;
+		}
 		break;
 	default:
 		/* discard this record type */

-- 
2.54.0

