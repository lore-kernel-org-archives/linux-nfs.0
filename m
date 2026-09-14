Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91C9345629C
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391675; cv=none; b=E82DuNNswa+dZNfkNESUIMrAO1CklNa/Nl3oXYjcLiIk86zoEfvk5A5/MTLiyce4evzVIc6DdjchGXL6D5b8PpC5nvr0g5BtMxEiXxCGySoCmHMlk5TtmtbqqFLSMscsowepzCrXk/1XbUHU9XCgiAWYCTW5abicsTz47BAlhRU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391675; c=relaxed/simple;
	bh=1zUD/5y5lWqgBN3OFWvST55O/4wG3deQLeFSm9NKll8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=RI0a+pATm8foGGwuWx8UhBBn6J/7GJ7kcQyUbn17dMWk5TbfdlCyyqnvGXTxBzZAzTZm6F5c6WiVf9hrJDE4gLFHdEiYpU70qFkeYR5orEJeuUb+Eh3hBlwhoaGRF6VRRQ2moXUC8qhLCHA1OjbSiXPMt1untk9qERDcKFO2/jo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YGk5K2n1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YGk5K2n1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB8A71F000FF;
	Mon, 14 Sep 2026 13:14:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391673;
	bh=OBAh5D/FtPhg9IMP0mZk0PGkShNmqALCyJlbjg5SKTs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YGk5K2n1svwhTBEgHlNq51wI91yX/4s2+zDH6Ty3hlOHJy3wxktAbR1lmL2humuOG
	 5M2LdlA5HdHFktyBrBSJiUYoEiOux5w1S4/AJi506l0gXpAd6/Ko9DYUQz01h1krPM
	 O2nyABkpliRYiOF/OipS4t5seLjz8pff1qF46noCiMD+6H8cxICzQZhYwYffPa13Vg
	 lEX2IW4s/8wZkO/94OKT3bbSlKAwezgbwVqmIUyK0arQZm0ZNHfztHTGpt7yeU0kiS
	 QzY+6XsSImImRQavZGqR7QnP2yyI+h5yzdYYYt0wKFLnTCSU2VGcJm6mSDiGK+6blh
	 UXBr5Uo6NxYbg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:15 -0400
Subject: [PATCH nfs-utils v3 06/11] mountd: bound the junction path before
 copying it into e_path
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nl-crossmnt-v3-6-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1337; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=1zUD/5y5lWqgBN3OFWvST55O/4wG3deQLeFSm9NKll8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/Mzi0Acxls1f0ghvcD/k2oaqbMORg/11NAll
 RY3cOvj9yqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzMwAKCRAADmhBGVaC
 FWS1EAC71JUMgj/IF5uRPBS7+Ai4I+CZTp9CEf+2pG0ZWiaIU/JhIk4m6wyOSvggMDPu/D2Ioa4
 NzeS1Je3Nl0ekSEwCL7vkj1jJeIzpLtjme5CiYWQ30T4gUrwrWW/fhfg8rVem+QX/+IJ0mQruBP
 TQo2wAF6SDu5O28tLmZ52QT09XD+ieLwVXYOKmBFagFbGMXYzYMBf+ZwzDuEHkpJsC7Iybi00hV
 rH/NWkPJjA5/PrpkDURDDA9/RUIs11ryRVNPtXyYvlEUq3bzbAV0KJz03zrA8gPfq3xcMBW1RXj
 kc+bvXYGwW2nsa25S4d34TVB0XHOOtqW5oGW6KE2fPxckH/8oG+KBZT567GsxwRA7bd/TVcUlyd
 y2FVogik3GQAIJW/SOHBYUGB2pq8P8Gp8br7Z9Jo/AvSwOBkmYQVp8rDkD6R0fIBxk5F00dJYwO
 LoqllVPv+jxCZwOj89Cd5bjR+VAAuhNbMPXHTIpFws4dIvqrQ0k0v5e2JEkLMBIOI1WN4kCcZYp
 vMF3/aQIXHHe/1YOyc52MkbonuY7hz3viPPd2g6RQtoA1o6dDRcDyn7T/CRVm8x0UxMSXn8vYMt
 SLVxeZaRTfa3kWpUNUwzX0I0VTwUw9xcj5XPgwmcUlTU3ydPLyAqThdv3D2L4nIDnl9UoneBW2O
 N5sEdVioCh8TB3g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

create_junction_exportent() strcpy()s the junction pathname into
exportent.e_path, a fixed char[NFS_MAXPATHLEN+1].  Neither downcall
bounds the path first:

 - nfsd_export() sizes it from the 32KiB pipefs channel buffer
 - the netlink path strdup()s it out of NFSD_A_SVC_EXPORT_PATH

A junction more than NFS_MAXPATHLEN bytes deep therefore corrupts the
heap.  Reaching it needs a trusted.junction.nfs xattr, so only server
root can set one up, but the copy should not depend on that.

Reject the path instead, as mkexportent() already does.  The callers
handle a NULL exportent: both downcalls answer negative.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 support/export/cache.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/support/export/cache.c b/support/export/cache.c
index 79dd0abe9a1b..6a5cdd9d9670 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -3434,6 +3434,12 @@ static struct exportent *create_junction_exportent(struct exportent *parent,
 {
 	static struct exportent *eep;
 
+	if (strlen(junction) >= sizeof(eep->e_path)) {
+		xlog(L_ERROR, "%s: junction path %s too long", __func__,
+		     junction);
+		return NULL;
+	}
+
 	eep = (struct exportent *)malloc(sizeof(*eep));
 	if (eep == NULL)
 		goto out_nomem;

-- 
2.55.0

