Received: from mail-pg1-f172.google.com (mail-pg1-f172.google.com [209.85.215.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D3DA233149
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 07:02:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791961369; cv=none; b=VBvWyAaQCTkB5YQogHYHoLtx4ME60qtJZC4K4qLwa31tp58PDBYczfcR/FpupVEEM7ZbY50MFSKfuJQM/G3Yw2WGczF0gLzwTjFsKUw+XB+J7YKuVBeU80F0dR05g1bvubvQjb6iecBfEyUQcsWsFlWOLhSbzNim8NwQb9n0WA8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791961369; c=relaxed/simple;
	bh=z+1pIzJms/U2lrZNfeDbuqTEsue3mwGJHL38XF/g954=;
	h=From:To:Cc:Subject:In-Reply-To:References:MIME-Version:
	 Content-Type:Date:Message-ID; b=nXNziEBi/gEbIDfMsyW1blvYA1CU3S43i58HDddQIbq3Z5K/upI5B3pfJ6CDToMrje6PL2FG0T7k5AaWkOgCrEuIOV89/gMFQZG8/i0AroEjElB/3aiZHoXz0/Ll4ab3UjMikq/eSNiELndVEup+iM1uwLsz+CJzwMRFLYLYO7k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Hkv1h9nr; arc=none smtp.client-ip=209.85.215.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Hkv1h9nr"
Received: by mail-pg1-f172.google.com with SMTP id 41be03b00d2f7-cc4b1f7e8f4so2284983a12.1
        for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 00:02:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791961367; x=1792566167; darn=vger.kernel.org;
        h=message-id:date:content-transfer-encoding:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gTIhbq0ZKANw33MoTkQP2lZdxnPis+sDRQrv3yuo8kg=;
        b=Hkv1h9nrYrlWV3z0Q872LJQcckiJ12jNcNMfYz4sZK5Jb+YB1xbHSgdWWkQNq3hpUl
         /uxROyeHDMoE3zceekcnCMDt6IM0zn90op5nAxGTlezBw0zsaY/nDuQ7kun1jtUDPr+3
         Rym0FhtqLjcC1wLiO2nJvdgmAe5MF4Buqz63DpphYWnk9cYuYOCAJv1r25eaD/BfhEvo
         5gTwlJvnx5an+hAz0PEkay+ablrPVMnO7UJeRg7IQwMdpjDx1xXGqdndoDrF+aaUhppi
         5iQtk1ejbheW6piBXffls3wb3ZUfnyyNdRvJhe3nj7xJvXlXptZlwRcxBGlO1PYbliID
         5/7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791961367; x=1792566167;
        h=message-id:date:content-transfer-encoding:content-type:mime-version
         :references:in-reply-to:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gTIhbq0ZKANw33MoTkQP2lZdxnPis+sDRQrv3yuo8kg=;
        b=QHOinXMAuzp9Sd8blooHKWLzB2LyAuJDEfdsxrY+FD+3/MQmwWcKBYi0C/4F5RSybs
         9qplbSijMs/FmwrJcU2vpk6ScihICxlIGoSoJ63kUVGlLBF42RgiuFyh3icHLRyrk+MK
         5UpLpCEI/bGliqvqm1agSenzdQaFDt1LIKb8QTuOjaMFKuWk7wngqatagLqF0ArZ1Te5
         sj3Fboto2eDd1dzQ5V5CdQj1ky46tn9dDZiSxaXSVa4PV7limFJ7HRUI40NdO77JV+rD
         cGvRdfoD+qmGO5dAy1GTMxj1CD0ffCUUqHJ4Zvs7JIA1lFUI8CBLUB/2PnapyAN+OD7X
         x8gQ==
X-Gm-Message-State: AFq9FYI+e09l/2GSOJBwFpidF0urgI/elR9o4DRg4gj5U6wOfWP6nnso
	X9gFn53LsJ/AhKmDc7QMbpWGt7509IKwXxSOSBceaLlXQIAk8UjJwOTBAfvxuAoL+IN6rw==
X-Gm-Gg: AYBFou0iFsQSO33jkJC6URqJjFAsRXsYtPOY9WQobUTi7YgjabRC0ZmNaO63O6XiJ77
	g7pNgrH9lwMkMM8WXl56W2nqm+PxHfNvNsBXOyCmv8iOGIj+s3puj9t2W7opYXxsol1WL4wQ8fi
	Q/xQ9k7zjHT9Zg40joHrmtCJsnjdswVhXHbPR+8lnecpJ9R99YZjnCxjEkwqlrzSmBknKMZ11br
	dgUllyG6d2juLhqKVM0vbaFUObm4s5HoOFcVqf92xvYyZhCHJAfjae/qY3pg64ba0skoVTWGnCT
	LKSv+LzzJz3ejH8KaO+EIqsvPBB8SJwKSH3VS4AUiYDgr9CZ/l7aYcl7nvkiNWFIv7s9rjFXnFN
	rjEIrGkJO1yoW2Wu8jmqeWiAKzdNBNOP1745aOXPyn/eNBNIa75UbRSrths44+h5qDWqw5WuDcz
	3H+Z25wD17TUC4+cJonAUJbWVk++avqueVx8Os1hXc/9wqOxPPDljpTfgSr532RYWbWXs+ylLp0
	M/7UEpQH84HRKotU9td
X-Received: by 2002:a17:90b:568b:b0:3ac:17c:6e89 with SMTP id 98e67ed59e1d1-3ac017c701bmr5798525a91.19.1791961367339;
        Wed, 14 Oct 2026 00:02:47 -0700 (PDT)
Received: from [169.254.174.97] ([49.77.220.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3ac6006376bsm3084296a91.3.2026.10.14.00.02.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Oct 2026 00:02:46 -0700 (PDT)
From: Chu Zhou <jack.wemmick@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org, anna@kernel.org, cel@kernel.org,
 neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com,
 tom@talpey.com
Subject:
 Re: [PATCH] SUNRPC: Validate TCP record marker length before trusting it
In-Reply-To: <6ab4b4fd.8f0cbdd2.2427cb.7612@mx.google.com>
References: <6ab4b4fd.8f0cbdd2.2427cb.7612@mx.google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Date: Wed, 14 Oct 2026 15:02:41 +0800
Message-ID: <179196136183.27384.12359852241151556822@gmail.com>

Ping - three weeks on with no review or ack.

Re-verified this morning: it still applies cleanly to current mainline
(v7.3-rc7), diffstat unchanged at 2 files, 44 insertions.

  https://lore.kernel.org/linux-nfs/6ab4b4fd.8f0cbdd2.2427cb.7612@mx.google.com/

I went back over the error path end to end, since the whole mechanism
rests on it. xs_read_stream()'s out_err label is

	return ret != 0 ? ret : -ESHUTDOWN;

and at the point the new check fires, ret still holds the positive
byte count returned by xs_read_stream_header(), so the patch assigns
-ESHUTDOWN explicitly before branching there. That value then reaches
xs_stream_data_receive(), which calls
kernel_sock_shutdown(transport->sock, SHUT_RDWR), and the existing
transport reset machinery re-establishes the connection as described in
the commit message.

Worth restating that the failure mode is a hard hang, not a throughput
problem. The parser latched onto a bogus reclen after below-RPC
corruption, then discarded every genuine reply through the MSG_TRUNC
path while the TCP connection stayed ESTABLISHED - nothing ever
triggered a reset, and the hung task watchdog panicked the machine.
Restarting the server was the only recovery.

Two-line check plus a tracepoint, one comparison per fragment. The 16 MiB
bound is a judgement call - happy to lower it or tie it to a named
constant if that is preferred.

Thanks,
