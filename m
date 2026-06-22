Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9568F2D7DCE
	for <linux-nfs@vger.kernel.org>; Mon, 22 Jun 2026 14:45:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782139541; cv=none; b=G1W1aGEUCiCK2Xy071+DlFAssFpWL+GI7XffEIw3hZEcKN/o+1PBuTykP7Fh4qAlRPZm54kWJO9e3e1CeW/CWPGL9lA9BDvzW5DZqOnh3vLmHBryqywIwxMrJ3gu1ujJmYbjZtn7NKZBwFrGI4ii1zynlplITV7lhrsNO2zOsbQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782139541; c=relaxed/simple;
	bh=4nklSuMgY84tg6AVzlLxLrmO7rOR764dxgdwRosB0Uw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=lcCMW3l2ILxG+jx5uSwOBbLbAOnbLEIyh1yuSJ4aTrJoBpNmUKrRMUjvSgro2TRd5JftHYVJQrwWeQo10jYaH2798nt0SceaNueO7I45phU+a1Z9NZICgEt0IhXsMWEc4ccii+Nv7GjGLDicSFWzWdkchAv6PUX72YPuH4XrcXM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EmN+Dtqe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EmN+Dtqe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 33A4B1F00A3A;
	Mon, 22 Jun 2026 14:45:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782139540;
	bh=xU/nTiq2pQqlLwjLs9IZQZyXT6Yiu/KI7V0J3uNL6o8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=EmN+Dtqe73aa894/oa71IXzhT65K1imQ6/Y1DGRLe2BgXp+3PESIAl2jDZBE8EH3v
	 xN5V60aYZxS7NR+XtHRoyh+zmsqUoZVsyr1cnA8AvRD1KqBp7k+5mHrgCc8aBCdXld
	 FY+lda3MxeWDC8bm8RRyNAV4l49kRtAiqUgZXyaSzsq2F+cnY0pB6WXcMvBDc6ww1m
	 abbJA3+94wl57CsXr9oMFCmFWnxTE/v9ZzL1RiCMInvCJEIzq7zotG2yeLXXj24iM5
	 zsWh1rYmrX3/FyZ3oBfd4ZKWmSDcUBgH2ZDS76KwxM/hzmrfSg+6zzuw0lPQ0HoUPc
	 qySbj3o8iWepA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7F255F40085;
	Mon, 22 Jun 2026 10:45:39 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 22 Jun 2026 10:45:39 -0400
X-ME-Sender: <xms:k0o5av2mx8-bUG9lqLr6LrxV-6lSaAV_WpU09-NS5Kje9ecFPZVq2Q>
    <xme:k0o5ao471AqH6ARU5BAVVRd73srTayvBRCBJ8zYptJdhOD77QjDgY2KRDCEfXj3sV
    qh15Ox2zkCzDp9SYyV5rQ1rb6MHBgWhG9dq3FZCo1KmyI2cgwJ6s8w>
X-ME-Proxy-Cause: dmFkZTGKdKfplLa92Z8rZWslfY9FIS4KUjQ4Csrkd6wOIzjq1ARdURIx1UXsrecVHohg/M
    eFqMLlrTQa8XbBBgcCvrrCmQtj3MuVk0rzho+SjS4E+/lnnb6QJDqFOKRZxPg7JIK9XH0O
    Sm4GdcSPg9jCALQ5tCtCCVKk6CDZHUpoZOqmfCk6WLj/I5ULaAtyEBoeYwIkiLKmjkZoko
    JEWPQ97uHobKVN75gHfTZLC2kygAkTcmkMKH5uCBZGayyPFIHUmyp+zWi4/82OfH3p06p9
    8wqEPjhTAawtmBYw48C6GPUorFdbW1WgOuOMc/wRrl4ooesDEjf1ttKTgepnUOC8f+n1V2
    PGNLOYUptBUFYFps0wNoOk/Wiaa1G7Jkr2ZBl+yiSZISuyq+nrnMu+DfLT5G8lDm5EDvqm
    HPSTa1XIXs1cJFei0T1cCntpUcXPuK50e3OxuR2F74RwFlgnI9Tom9LJvDRjLwcAr3aKoE
    rd+SciblfxwRGcxvmIIUaIS2FusXCHbnlGX7jltf4R4ae2LotAuSsUn0oLXtawcKvEc5kN
    QsWTz4bFbJ69q4qPjgKqdtSqHSL2lHNcdiNBPpA8vbTxcp7K+4s88sGVBKEJYX2OtdofSr
    QiCXnzyuoeUX1aZnENUEakJqF1iFb5shS3NcQUEKT7nPrdMDiTT9wpyl7/5A
X-ME-Proxy: <xmx:k0o5aqa2WHR_C7mVRmidlQrFya_z76Ro_3AOjFE_4DjmT8XZS1_QBw>
    <xmx:k0o5asfjTyHFXcXiGI_PjextYzZSi3iGwDT02VvQJg_YpEYGAhrdFw>
    <xmx:k0o5arKDqRbMJQhV72nHpluwu2SqX_6JWXiOgPTrjqvzeqGtvNIPhA>
    <xmx:k0o5apIcgCskcg1r00L1KE8Zx1k5Lt7FB2Q827fhDOgL25xFpW1_kw>
    <xmx:k0o5aqXkDboCgyFyeviZDV5_R1hh3-4jHxfz5xCSh8KH30wawoQJRTa1>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5DA4CB6006E; Mon, 22 Jun 2026 10:45:39 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A_7NIs0qKC9w
Date: Mon, 22 Jun 2026 10:45:18 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Jonathan Corbet" <corbet@lwn.net>,
 "Shuah Khan" <skhan@linuxfoundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org
Message-Id: <d0e00b35-ce08-45f9-9bc9-7dc63694c171@app.fastmail.com>
In-Reply-To: <d0daedc8491e046c036bfe4e6915dc677e79428e.camel@kernel.org>
References: <20260512-nfsino-v1-0-284720522f4c@kernel.org>
 <d0daedc8491e046c036bfe4e6915dc677e79428e.camel@kernel.org>
Subject: Re: [PATCH 0/4] nfs: remove the fileid field from struct nfs_inode
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Jeff,

On Sat, Jun 20, 2026, at 9:06 PM, Jeff Layton wrote:
> On Tue, 2026-05-12 at 12:12 -0400, Jeff Layton wrote:
>> v7.1-rc1 contains patches to make inode->i_ino to be a u64. With this
>> change, there is no need to keep a separate "fileid" field in struct
>> nfs_inode.
>> 
>> This patchset eliminiates that field, and the inode number hashing
>> machinery that is no longer needed. This shaves 8 bytes off of each
>> nfs_inode.
>> 
>> Trond/Anna: please consider this for v7.2.
>> 
>> Assisted-by: Claude:claude-opus-4-6
>> Signed-off-by: Jeff Layton <jlayton@kernel.org>
>> ---
>> Jeff Layton (4):
>>       nfs: store the full NFS fileid in inode->i_ino
>>       nfs: remove nfs_compat_user_ino64() and deprecate enable_ino64
>>       nfs: replace NFS_FILEID() and nfsi->fileid with inode->i_ino
>>       nfs: remove fileid field from struct nfs_inode
>> 
>>  Documentation/admin-guide/kernel-parameters.txt |  7 --
>>  fs/nfs/dir.c                                    |  4 +-
>>  fs/nfs/export.c                                 |  6 +-
>>  fs/nfs/filelayout/filelayout.c                  |  4 +-
>>  fs/nfs/flexfilelayout/flexfilelayout.c          |  6 +-
>>  fs/nfs/inode.c                                  | 87 +++++++++----------------
>>  fs/nfs/nfs4proc.c                               |  4 +-
>>  fs/nfs/nfs4trace.h                              | 79 ++++++++++------------
>>  fs/nfs/nfstrace.h                               | 84 ++++++++++++------------
>>  fs/nfs/pagelist.c                               |  2 +-
>>  fs/nfs/pnfs.c                                   |  2 +-
>>  fs/nfs/unlink.c                                 |  2 +-
>>  fs/nfs/write.c                                  |  2 +-
>>  include/linux/nfs_fs.h                          | 25 -------
>>  14 files changed, 123 insertions(+), 191 deletions(-)
>> ---
>> base-commit: 5d6919055dec134de3c40167a490f33c74c12581
>> change-id: 20260512-nfsino-1f9a8ca2f3ed
>> 
>> Best regards,
>
> Ping?
>
> i just noticed that this never made v7.2. Maybe consider for v7.3?

These are actually the first four patches in my linux-next branch for
the pull request I'm planning on sending (hopefully) later today.

Anna

> -- 
> Jeff Layton <jlayton@kernel.org>
