Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B9FBE257440
	for <linux-nfs@vger.kernel.org>; Tue, 25 Feb 2025 06:53:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740466387; cv=none; b=mmch8DRJPUHwVPUI8P5Vsm2shZzMY7R3W0r5xhldTO/FFqvZ154PziPRJLfq8kzPUpSbZI/bIdnZ2aeRQ7OWHWzh2+Imab9rBEUJoqCczKIescOCNl/zZSDhR5p2Dztkgm/t6GFnxJ+Xi7o4M3CMdRy1rtcAGypkbbyB3njzaUo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740466387; c=relaxed/simple;
	bh=QpPtDxFJ0RN58SdD7zgjlEK+xIqQEG1wZjnsw06WrGY=;
	h=Date:From:To:Cc:Subject:Message-Id:In-Reply-To:References:
	 Mime-Version:Content-Type; b=BO7BX5zyKy8A6xh2Jgvp21y9W1/DxOYOEyc9U00WhvrOkkX/TfmN/4rEjMx2h8nUYWftjNl8PtfVDIxnOXm2ehxrRoSjpIGN0CDoBNQRNctqC23jfqDvv48lmiUfgOuHolA/vADE6vCV+UBuZ5vonskyQf6OjvdWvOWMT6BZr0w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=U55r9Op3; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="U55r9Op3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 06468C4CEDD;
	Tue, 25 Feb 2025 06:53:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linux-foundation.org;
	s=korg; t=1740466387;
	bh=QpPtDxFJ0RN58SdD7zgjlEK+xIqQEG1wZjnsw06WrGY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=U55r9Op3KBOOsVYbFSFsg6GdT7MwoZXALNWNAOgFCSt9R3WYVk6JsVHsBZ/AUVwj1
	 QdLotKNEr1X3PpjOBHGG6gXkKBHtO8laPtqZz3/Cu61KKdzs6CydLikoPnfAmXyafD
	 to9dNBFP+rz8RE1Qcsrz3DcLWUJCoGOYAElUq+L4=
Date: Mon, 24 Feb 2025 22:53:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>, Anna Schumaker
 <anna.schumaker@oracle.com>, linux-nfs@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 for-akpm for-6.14-rcX] NFS: fix nfs_release_folio()
 to not deadlock via kcompactd writeback
Message-Id: <20250224225306.fb08838ac74f42f1c621fd19@linux-foundation.org>
In-Reply-To: <20250225022002.26141-1-snitzer@kernel.org>
References: <20250225003301.25693-1-snitzer@kernel.org>
	<20250225022002.26141-1-snitzer@kernel.org>
X-Mailer: Sylpheed 3.8.0beta1 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 24 Feb 2025 21:20:02 -0500 Mike Snitzer <snitzer@kernel.org> wrote:

> Add PF_KCOMPACTD flag and current_is_kcompactd() helper to check for
> it so nfs_release_folio() can skip calling nfs_wb_folio() from
> kcompactd.
> 

--- a/mm/compaction.c~a
+++ a/mm/compaction.c
@@ -3182,7 +3182,7 @@ static int kcompactd(void *p)
 	long default_timeout = msecs_to_jiffies(HPAGE_FRAG_CHECK_INTERVAL_MSEC);
 	long timeout = default_timeout;
 
-	tsk->flags |= PF_KCOMPACTD;
+	current->flags |= PF_KCOMPACTD;
 	set_freezable();
 
 	pgdat->kcompactd_max_order = 0;
@@ -3239,7 +3239,7 @@ static int kcompactd(void *p)
 			pgdat->proactive_compact_trigger = false;
 	}
 
-	tsk->flags &= ~PF_KCOMPACTD;
+	current->flags &= ~PF_KCOMPACTD;
 
 	return 0;
 }

I am of course concerned about how well tested this was!
