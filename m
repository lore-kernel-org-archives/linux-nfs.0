Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB49F434E47;
	Wed, 12 Aug 2026 11:32:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786534355; cv=none; b=CjYRadKxIo4QJRTuaK9xzgG9G6t+VsJcNL4Wet6Niwhr5r45CnDg+eO+mZBUnMwPB1fEKBO2vJFNmGMS+ZdDK0E4WrJ6Fx9Y1jVzTp24z8NwuTghQpRGTeWa/A9fohT9XZmeYeQyTZcq8KVGKSTfSRJowKnwp27Tw8dmbxv4B7A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786534355; c=relaxed/simple;
	bh=sn+ts2ZQNfSNAwAtXCoxbTpeHPjyiWcgneDSzAIxzww=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=g/9vYh/Ly9cvc+KGahx4A4OI+Da7lVZ/ueAzKqFqNzSSg0t6WRXucq5Dtk6tGlAfKxktS8KrATAirSwjjrbR/YVYsW3Kup8jUNAqTnt5TVfsZOrkALPpJM+nYBF4ZJXMY2wUePbXtXsIiMHFF2S6fXN6VBZjHAXjWeKrK12pEFU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SNDiU84k; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SNDiU84k"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D5321F000E9;
	Wed, 12 Aug 2026 11:32:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786534354;
	bh=pDBY8zosY0dtrX7wxrg+3LZhgYOykB9y0Qe0VTawtRw=;
	h=From:Date:Subject:To:Cc;
	b=SNDiU84k3x+vNeI+MqH2V5VBThuSvYdij5N+Co/zeO9E9k4c+ZGsEed1FnyEurziv
	 PEIlD38hZxZKKwUxQlOF7L7pUTsEjqwdGjl49Q1vgKhsAdo5kwdziZCxcaV0v511v8
	 HrI/LPjKinx6IT2i01f18mMz8CkiXlY8yiNDOLllxA1pahuQH6jwDuO6TKzs0UdSin
	 jW1vjnmXcSG3yqZydIicNohfsqy7sDGpXZlMBr+zBIkWdb9eL3yFScup0ZmGVK2TcE
	 sBOUzKa0Wk3ZiLOUi479nltEq1luUmFFPGyAWosGvQehbXdYs1LTErYgEjPBiNlddj
	 oKtm6ixdggWwQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 12 Aug 2026 07:32:27 -0400
Subject: [PATCH] nfs: allow nfs4_handle_delegation_recall_error() to
 silently handle -ERESTARTSYS
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260812-nfserr-v1-1-620e439ec124@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDC0Mj3bw0oI4iXcOkRAuztNREc0sDQyWg4oKi1LTMCrBB0bG1tQCd0qC
 5WAAAAA==
X-Change-ID: 20260812-nfserr-1ba86fea7901
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=957; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=sn+ts2ZQNfSNAwAtXCoxbTpeHPjyiWcgneDSzAIxzww=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqfFnNCH/wwfF2GxIibDVBj8OfYs/Hh6srBRA/9
 BF2tydcHPGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanxZzQAKCRAADmhBGVaC
 FaaQEACcvjY9fyGg/Kn02xZG5wtgJ+KTt6DwYvakr1DHzdwpzI4y0kQxO6GH1qYWJRqw6eL2lNj
 hDyLXuiZ0z0hKxYQfpgG7974qTtODEufFi83o8PydQ2sx7qRigXU5WH+AXIbfUnGt7RIc7qQt7u
 bB0es9y0zWul7S4J8VSUPhV0j0nwS6ttU4z7r4qEi4z44M55pULGu0eLtHvlST6XdZvPf2TWbnl
 AQseBlg3VoV6J1G/mfDykd0wfkDrBmaeFzz+RzVPlihnAtWbPedk3V+c+9peOsU8babxj4Hr4eM
 PGCd9T0K1gmNE2vQ/MM8GD/7NofQRJZJU0ll332L/cPBIPozq84OxoD/KWt13D1jCBeLquq5Eu1
 7wHpf7tCC2HvTOqTn/uuDwVKCicqBNaZRBAV58YKxUJyW9ZOw0SeVL99KzyMj5fR/c1KygBvTgh
 G4FF/6EVMVH6OYe/kjVR8SoPSy9P9HKR++8uh9eYguZGHV8O5COWT7oze+7T+xkivfLdki1nokJ
 ih3LzvTDMzgYghgf7bACnILqLP+3pBPQDgvDTOGs1aM1ej/dmbICjoPiu/GE7s4cwweDtRd/AZC
 poBTBB/pS+BWmkmUpUocpjHWCsAaGTxxxgxTP5EnUKnyuvCvvvpdn2ICsJIYLE9o1fO7z7cWnzw
 p4mcHs5ADO2NCGg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Currently, when a process stuck waiting on a delegrecall catches a
signal, it emits a scary looking printk():

    NFS: nfs4_handle_delegation_recall_error: unhandled error -512.

Allow nfs4_handle_delegation_recall_error() to accept and return that
value without the printk().

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5709c6fea85b..3354d84c5a9a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2302,6 +2302,7 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
 		case -EAGAIN:
 		case -ESTALE:
 		case -ETIMEDOUT:
+		case -ERESTARTSYS:
 			break;
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:

---
base-commit: f5bbbfec59b4e2fb7520a91de3df8a6174325d6a
change-id: 20260812-nfserr-1ba86fea7901

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

