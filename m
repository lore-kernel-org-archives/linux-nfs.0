Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99E684779B0
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 15:00:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786546824; cv=none; b=oX6CfQjwPDwehmgMnTLugkNoy1AaL6Aogg+M/X2N88o1MoOvVOELVU/IkU0if4RMMiRgEsrocxUdjtpBUUa6n+aS3rKuE+Yv1evUdchC21zaPTEaz9hMoDTa8IZFmVxrDpTOi635gyEzyEAUDN2IcFyODN6SdWOwnISnOxRxxPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786546824; c=relaxed/simple;
	bh=VUjHI6PchYG7x/QRhXZGQzAHxFL9hkUIsXWxXPoNHtQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ky6LnkQQSMkxYUenfu7arQxGkGmeqk6Dk9RcMOiFzWEfS1OGLK1yx2UW3ItYyBR7uA6pxKWasNQrspmAZcklesN1ixOt7SZMwCyXyIqGs0/OwxpywQoUuCDUDtW/PEjvQ4YqItE/k7vSKGltmevsVRJCB/W7QoQI9jpogpcw7TY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ngm5XgZU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ngm5XgZU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B42001F00A3F;
	Wed, 12 Aug 2026 15:00:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786546813;
	bh=puZnyjClaEToaZ/1aK2I1QuHnYOC/NEpG3CTNGRBQv8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Ngm5XgZUzR83lKdJqDtXn2O8Dh3VFlQIM044s2xh0GFfffI3xYIAe/ejQ656mz65Y
	 jWvkHXzQntECVQYdHmzLDl5/at24OFdLRTUEOIKLYIuQKvd04XfWPxDed6j3/aqRoP
	 KFs9yIFkx3cgWd2ISoYzgje1XDumKHU+LMOCzNGvLzUhxA5K92hBxG91i1S1mMfQL1
	 lMbmsvTRCV2jxz6cCv1EBeQ/YMIW75lx8nfAGsPsBslxxGNXOuj4G57LSEcA4jU4dQ
	 ifgVWqlsx0KbWk+LHNI3/xyf2EfyqE0e0+Pnr6Mv/0aVK/+Ld9IMXV5TE7Sg11hmsn
	 taUPjumQs/BBw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 12 Aug 2026 10:59:55 -0400
Subject: [PATCH v2 1/4] NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260812-recall-any-keep-count-v2-1-a82f4ca23812@kernel.org>
References: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
In-Reply-To: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1573; i=cel@kernel.org;
 h=from:subject:message-id; bh=VUjHI6PchYG7x/QRhXZGQzAHxFL9hkUIsXWxXPoNHtQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfIp7zNJGLF+9UIY4tHHw3vWBa4QewNRtFRbe+
 pWBBHuzt72JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanyKewAKCRAzarMzb2Z/
 l9hTD/oDBd379Ooa2Xz0gQcLzW0ntr2ZCTfrw7vduFZyAH5VGmEv5lMTHqgq82+Tv2OsxVWQqhh
 B2bgTR2x/uwPNjdAlu6QooCyp47Jm5E15J9u8m1JO2FSI/QXnVJfxq0bf62n4XWpQL/k6QjfyrK
 AKMROKkH6OhBs2RAkXSTcJCVjlXSAaN6jNb2scDcdoY/UKzPciArw3TC64g01QBLnwe1z+d3TKx
 6F+urXR+98nSaNt33BgT9XDjaTzfEA63lSTAWpLz+OgbXK08kcoK8+TQ1rm8fodxkwqzHCYcbhx
 WgoyhBFpPqKzwkB/F6LQRMd8txdMTSsdxHKYKfUbObZOjBK532d8FktIRjm6xVL6RrhckqKPR+i
 phuP752ScCwk+qcnkgwe6IP5jYD9OfMMBEBg4kwtAV8QrUlU3ylq11YQ7kMoMEp+esPM3eL3p+d
 6nrwTJaf4/8xl1onb4JGCh+JqtXAFvTdeMsg3h8G5JTSX1PhVyoCVKmnETpb9gXD+Ws4uL4OAdy
 SGBtrB7D2UTJl3mIBrT0tX0NV9M0ZWc0jrDpP7lQsreCMzDov44KTZGd8/7NI+LfyuEj7LvA7Zt
 kHNJeq7kuJAdZDxedHZ7UaAxghcYOyOaSel0LOhK15ufzT4kT3vngMdUpFwWM44RUzLNjktHDTW
 AEGkeOReXdXyXUw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

deleg_reaper() sends CB_RECALL_ANY to every ACTIVE client holding
delegations, but CB_RECALL_ANY is an NFSv4.1 operation. An NFSv4.0
client's callback service accepts only CB_GETATTR and CB_RECALL, so it
replies OP_ILLEGAL. The decoder maps the unexpected opnum to -EIO, and
nfsd4_cb_done() marks the client's callback channel down.

Nothing brings the channel back. nfsd4_run_cb_work() sets NFSD4_CB_UP
only for a minor version above zero, and the only nfsd4_probe_callback()
call site an NFSv4.0 client reaches is nfsd4_setclientid_confirm(). One
visit from the reaper therefore leaves the channel marked down until the
client re-establishes its clientid. RENEW then returns
NFS4ERR_CB_PATH_DOWN for as long as the client holds delegations.
nfsd4_cb_channel_good() stops returning true, so the client is granted
no further delegations.

Skip clients at minor version zero.

Fixes: 44df6f439a17 ("NFSD: add delegation reaper to react to low memory condition")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 510380b6aa7a..09b1aa2914bc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7947,6 +7947,8 @@ deleg_reaper(struct nfsd_net *nn)
 	list_for_each_safe(pos, next, &nn->client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 
+		if (clp->cl_minorversion == 0)
+			continue;
 		if (clp->cl_state != NFSD4_ACTIVE)
 			continue;
 		if (list_empty(&clp->cl_delegations))

-- 
2.54.0

