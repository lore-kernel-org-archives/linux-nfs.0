Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CA2A20320
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jan 2024 17:45:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706291119; cv=none; b=S/u+NCma8iwoLmJOXgK7sd2S02hvuUMm7+Y1U5mlkJP34gda6ShP2J1w86CtuJt2CfOZPPYFgfZdqJhPwOJDqvb34Gc/qUpA08Y4ZVhP7OmMdStrGWuGFQaH4TMNA10cPoNU/iNvcEc+VyaFYE2olzBfNBV2fVURHNhY2ijA8+Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706291119; c=relaxed/simple;
	bh=AnkpOGIQFWkJ/JOeRn0Nu3/dEqNIgTVSo7LYtNBt3EY=;
	h=Subject:From:To:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=nF0DpwA5HUaOCqfz9QsEWLQS8MXoYUkvNbgf7xpYw9q0+IkYZ2c85An+6Vm5R2/ZWboUuQx7iWahLWj+8ZET3DXcJpNxmjBjNNoLnqIko8x08/Gfj2MbhkdxUq5OQ259CubFRG8jI+dkW7sYtQ+R6IDV2ol81YtgqHikJcbXbVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OL3rzoOz; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OL3rzoOz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E5F18C43394
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jan 2024 17:45:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1706291118;
	bh=AnkpOGIQFWkJ/JOeRn0Nu3/dEqNIgTVSo7LYtNBt3EY=;
	h=Subject:From:To:Date:In-Reply-To:References:From;
	b=OL3rzoOz/H6VMA6xM3WWRb3LyUCcWzKPTRB6dY2YWl0zHnfezECIuv0GqcvPjqU3F
	 VSLc+uV6MJFuoyN+HxE3NC6MGYRC552D5QhjaBrjsmcmorkN94iaPLjnuWQKAXJUfB
	 e8RTVtGFHdoSFY3xXkbrcllEGplcOqU1N/xWH/YyMTrFhnF4qyBGjQBOILuFZ+fq+B
	 j5+6rtv/S2OPGuJftWvFN/I+2BkRIORcHjKmDe3k5iwhRx1X4DAN0q8grdhGurvR1N
	 3w1CkehrqwsKVI97ECZNgXfz9/THGmv+XxunuUWjUER0I55OUvxsrxVreWYfeOtMPy
	 mjBguEZJwbeRw==
Subject: [PATCH 2 01/14] NFSD: Reset cb_seq_status after NFS4ERR_DELAY
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org
Date: Fri, 26 Jan 2024 12:45:17 -0500
Message-ID: 
 <170629111684.20612.8595881042301584822.stgit@manet.1015granger.net>
In-Reply-To: 
 <170629091560.20612.563908774748586696.stgit@manet.1015granger.net>
References: 
 <170629091560.20612.563908774748586696.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

From: Chuck Lever <chuck.lever@oracle.com>

I noticed that once an NFSv4.1 callback operation gets a
NFS4ERR_DELAY status on CB_SEQUENCE and then the connection is lost,
the callback client loops, resending it indefinitely.

The switch arm in nfsd4_cb_sequence_done() that handles
NFS4ERR_DELAY uses rpc_restart_call() to rearm the RPC state machine
for the retransmit, but that path does not call the rpc_prepare_call
callback again. Thus cb_seq_status is set to -10008 by the first
NFS4ERR_DELAY result, but is never set back to 1 for the retransmits.

nfsd4_cb_sequence_done() thinks it's getting nothing but a
long series of CB_SEQUENCE NFS4ERR_DELAY replies.

Fixes: 7ba6cad6c88f ("nfsd: New helper nfsd4_cb_sequence_done() for processing more cb errors")
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4callback.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 926c29879c6a..43b0a34a5d5b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1178,6 +1178,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 		ret = false;
 		break;
 	case -NFS4ERR_DELAY:
+		cb->cb_seq_status = 1;
 		if (!rpc_restart_call(task))
 			goto out;
 


