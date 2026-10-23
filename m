Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792758640;
	b=CcZXoHeF4dqJm3zo+Dj/J2rdoOpENKEkoleNxV4Vzh0gfS7uKkNPW0Kku3eONm2Uv29L
	 LcgvHOkDkUwwuaYt0uqVzTKI8UR84VmsaGBB6s9qeooejhdVGUtpOB2NL81FKGw7cQbwc
	 G31tdMMBn22kgSlg2ZkH5jWTeEUPKDCQgPBiBzezuuP+ssAY/BiX6LUBFFe8CbQ23iyd9
	 P6Fb78RojpgU+9H/5V8Zh4kVEl+6cqUcpNwA5OLaUHxLEMuBIko7M/Fjn7q1WOT44HneW
	 h5etbxFoclYT3Jcdau3KSo36iSRJJ1m/apOfN21fpzTzPB4ULgaLLPi5VXgtM/aoqHg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792758640;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:MIME-Version:
	 References:In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:
	 Cc:Content-Type:Content-Transfer-Encoding;
	bh=hveEa+Al99MHs4h8FdaOj8FTv1WpMJnjPQ1EmAcnVtQ=;
	b=UBaXr2kg5mwF8QGuqSr2f8JfVU+ixN4B6g6Bqe/NIKYh2dk+IPDp0dvYJQ4j+OH0cUvN
	 8i8DVmS8zhkLW3Sx0QN67g0NhrAvPzVTtE4twbdORgvalFWSpDkTBDI+6lcucjTA0FPiF
	 +tNfbRFWrkdpl5cE+1KNffD9sE3H3RCZbZvJkn92mBMzSicTazWCsDQDZmP6ypIAsjpn8
	 Z7/RNA8WYo6MczGpNyVRcnpiXwFJP9tA29HeugFT3DUqaqxpskmiBmPZLXgfSL4tFtoGn
	 3UzZqLAC12+kZHI4Kmj9sy9QSPbHhyW3bLaQD3iga71TK18X9rWLwaMwVaHNMPbp5aQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Xkco++or;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b="r/F3+i1+";
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17A47606A33E
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 12:30:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 17A47606A33E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Xkco++or;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=r/F3+i1+
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792758639;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=hveEa+Al99MHs4h8FdaOj8FTv1WpMJnjPQ1EmAcnVtQ=;
	b=Xkco++oroMwAlbcmFkuSPqcWszcRZjFqCB0rPx5wkYuKUGyA3mdHTHtHZnthn3kZp3FYr4
	c0GYzjbBRgGQyimuDyJn9MbzbzO8z71vq8qqem2bf+ajNiQdWXSpRZaK8P1NwQmVJgDAbR
	1QnCTFo8/s7QduJUmK5tA+EEqq3Ufm8=
Received: from mail-dl1-f69.google.com (mail-dl1-f69.google.com
 [74.125.82.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-644-OoI_eVEZPMSYZUUaLa7-ug-1; Fri, 23 Oct 2026 08:30:31 -0400
X-MC-Unique: OoI_eVEZPMSYZUUaLa7-ug-1
X-Mimecast-MFC-AGG-ID: OoI_eVEZPMSYZUUaLa7-ug_1792758630
Received: by mail-dl1-f69.google.com with SMTP id a92af1059eb24-147be78cd56so3237673c88.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 05:30:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792758630; cv=none;
        d=google.com; s=arc-20260327;
        b=aRpd7nuVrcapz9iFvuvkbG4htm5KHfgqeujOwNAbiqLluFpCUf/KUvdEgOcFtP6MC8
         C7Yc1wPyVADsK8nozr46fX0pLGsHtRFAbLy6HNdglVWLcCEz4zeYcnSU4QEc0rqzVqhx
         XS20z+tVE4zcml60tPnbsXzXfwQrz2b4HO1kefjuCqC4mLGWebKED8ucEgpFDonwPStm
         COwb1CHCGVclMBHBtvp82eF0jscjLzM9QyfuZw/BIGwp9T7H9+k9BiSD2MQZtrRJshUw
         h2Tn0q897GLrIxlzuhOGsljOhvrOk3WABund5jcSpmLyeBDVYFgHOU/ZMq7EWx9SETTv
         ardw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hveEa+Al99MHs4h8FdaOj8FTv1WpMJnjPQ1EmAcnVtQ=;
        fh=Egkw+cLyKFkG5Bg5l7a34VLnJMFuLNd/AaU3kEo8VpI=;
        b=hsnZ6cTMp3248a+dkvWQriH4suczUNw6l0UDeS5LIuj33TWTrgJ1qK/U9+SnGzl4i9
         6E01fqQ5SVhYTGrOdVaJ8ZLb4GIufwtqUacGUQrXj9h+/oinEmxHHhFiQ5yH3sUc5LvD
         39QyL7++DSsXbr2hCi1LEQJCvPW6HsYpwZOpuJZcA2hQzXtgeoucIWAxhfIpV6hKdRA7
         xjQqJ8A/cr64hIC2zaPOzlXT5FlwogPlV/PXlcnXyadM+BtorISgpEObsFZY9dNJUG7V
         B5xK+Z/jWMCTCjxj9bQUCy0/+HfgtMITcx5Zhpmzgy5EUCfwlu5IQkfP4OdZfVHqeXo3
         iimw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792758630; x=1793363430; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=hveEa+Al99MHs4h8FdaOj8FTv1WpMJnjPQ1EmAcnVtQ=;
        b=r/F3+i1+HVIfZ9wl+Dglx9Qsm4+tWtkzV/+fxV/TfHGFQKFKByLoXQiBR1gAvUlJbf
         jbCmWuf4ntpR6fllupclsQJ5Ll6KCzwK1fUCiq06gqIWMnbOHL2/BuPg52yvckiFWhHt
         ioR2lKHEnDqmQzpSPWzv9O7aLt1LKG/25apJCaFNqAriCnz/ExQUsD0P5dlp+7duqUJB
         jsmVv5H4wStxlFlZQyIiEx1QC6kWn4g6WDMPwIShv5dG1i77F/ZH6bFv2smhz+Nn26Vs
         Tz3YSsGi2NMml50u+QHni2He6OD2FNv6FmxtsR2ybX+Oa1C0njzxbl2WY/XFiMgrk9dI
         +uyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792758630; x=1793363430;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=hveEa+Al99MHs4h8FdaOj8FTv1WpMJnjPQ1EmAcnVtQ=;
        b=gPa2fwawL2TdV23Hcpx87qm13tJHTAo+Hu1MGlL4DWRpG0vOfcQOoCs562PDWEgWe4
         C8XoU4Jiebv8LftBIguAYhEn4SzLHcBwZHH1sdhSLqcBRKbUfs85JkMQx+aWaay2UuCu
         WdhYb/Smq37E1+Og8s95ojG5oWEwGAqqvmhigOQQzlTPVkCuvxS6w/6MXQeixRwRkryS
         U6zpsN5qeBhZ+BQfdr4EhMtGJpHlXdZlq8zLxt/COIv97mf6JwgFfJd9FjRH6zbBZ/Nb
         hF65DfMDR8Cwo65xfh33F96chsov/Wxa29xkr20ZLGLqnvAjnFVT3k+KhYH2DvypjpKQ
         KBWA==
X-Gm-Message-State: AFq9FYLko/XCD5CxtS7AsGmpLuXk4FEm4mUX3wcvU5by3MfEDYCaT5gx
	3Tv3zHFxvP/pjbeZ3SAhC1XJDYoHYv6D60nfgXLTUD++snAsV4gugH+53X8xUO0ozG7XyE14OD4
	TX0NBQS96MVFCpQIKXFQ6WhizfI2EJlS8WUXBE0KI5b0VEylQX8Owu2G170dPcgvFSt9Kal/xLP
	KjTS/LgcUdcGfsU2fIQ9lN9PKzF2UWrA6CUc1qZ8kbZEOZ
X-Gm-Gg: AYBFou2JP8XBf18t/C2x86lviMZx+M6Lu5hXEkE4EAH9M50wbAMOW0CvQqVirwmdQgs
	pkbcVc5ZkbyyQlAm8bYtdfG/jUTxvFJTeGjgn10JsvYs1thHSsUj9JBsS2s7l34E5AmG9OBPQJV
	w1cUU/5B6KstLrxFYhfAKdGxq9PWEXZHk0qJ2zQ2ztYIpagXq0jGEBUZW6
X-Received: by 2002:a05:693c:41d7:20b0:366:913f:4d27 with SMTP id 5a478bee46e88-369d9815875mr2807279eec.30.1792758629995;
        Fri, 23 Oct 2026 05:30:29 -0700 (PDT)
X-Received: by 2002:a05:693c:41d7:20b0:366:913f:4d27 with SMTP id
 5a478bee46e88-369d9815875mr2807231eec.30.1792758629281; Fri, 23 Oct 2026
 05:30:29 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20260902133554.28863-1-antonio.feijoo@suse.com>
In-Reply-To: <20260902133554.28863-1-antonio.feijoo@suse.com>
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
Date: Fri, 23 Oct 2026 14:30:16 +0200
X-Gm-Features: AclHuK-wakIvXqCUzSART3LGe2wvzsGf2znyejJW7VPxlbiq1JXi3WfERCN2VZs
Message-ID: <CACWnjLzVeXAfVWgg_YTqtNTDd7LXSkM9dA0znwdPLY=4226bbQ@mail.gmail.com>
Subject: Re: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3
To: Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
Cc: linux-nfs@vger.kernel.org, Mike Snitzer <snitzer@kernel.org>, 
	Anna Schumaker <anna.schumaker@hammerspace.com>, 
	Trond Myklebust <trond.myklebust@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

There is another problematic case for this problem : if an
unprivileged container attempts pNFS I/O, SELinux may block the
request_module() call, leading to a writeback hang instead of a boot hang.

Having the module pre-loaded at mount time avoids that scenario too.

On Wed, Sep 2, 2026 at 4:04=E2=80=AFPM Antonio Alvarez Feijoo
<antonio.feijoo@suse.com> wrote:
>
> An NFS root mounted over NFSv4 against a Linux NFS server hangs during
> boot, either wedging permanently in the switch-root exec or, on a loaded
> machine, spinning until the softlockup watchdog fires.
>
> The flexfiles layout driver reaches nfs4_pnfs_ds_connect() on the first
> I/O through a layout segment.  For an NFSv3 data server that calls
> symbol_request(nfs3_set_ds_client), which becomes
> request_module("symbol:nfs3_set_ds_client") when nfsv3 is not already
> resident.  request_module() execs /sbin/modprobe via the usermode
> helper, and on an NFS root that binary -- and libkmod, and the libraries
> behind it -- must be read from the very filesystem whose I/O is blocked
> waiting on this DS connection to be established.  The helper cannot make
> progress, so neither can the mount.
>
> On a system whose init is on NFS the first such I/O is typically the
> execve() of init itself, immediately after pivot_root(), at which point
> the initramfs -- and the only reachable copy of modprobe -- is gone:
>
>   WARNING: fs/nfs/pnfs_nfs.c:792 at nfs4_pnfs_ds_connect+0x47e/0x490 [nfs=
v4], CPU#0: systemd/1
>   Modules linked in: nfs_layout_flexfiles rpcsec_gss_krb5 krb5 auth_rpcgs=
s
>                      nfsv4 dns_resolver nfs lockd grace netfs af_packet [=
...]
>   Call Trace:
>    nfs4_pnfs_ds_connect+0x47e/0x490 [nfsv4]
>    nfs4_ff_layout_prepare_ds+0x...  [nfs_layout_flexfiles]
>    ff_layout_choose_ds_for_read+0x...
>    ff_layout_pg_init_read+0x...
>    nfs_pageio_add_request+0x...
>    nfs_readahead+0x...
>    filemap_read+0x...
>    __kernel_read+0x...
>    bprm_execve+0x...
>    do_execveat_common.isra.0+0x...
>    __x64_sys_execve+0x...
>
> Note the absence of nfsv3 from the module list.
>
> This has been latent since the flexfiles driver was added, because a
> fatal DS connect error used to be absorbed: ff_layout_read_pagelist()
> returned PNFS_NOT_ATTEMPTED and pnfs_do_read() reissued the I/O through
> pnfs_read_through_mds().  The read completed over plain NFSv4 against
> the metadata server and nobody noticed that the layout had been
> abandoned.
>
> Commit 7a375cafc14e ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS on
> fatal DS connect errors") removes that fallback for layouts carrying
> FF_FLAGS_NO_IO_THRU_MDS, correctly, since silently contradicting the
> flag was a bug.  But nfsd sets that flag on every layout it hands out
> (fs/nfsd/flexfilelayout.c: FF_FLAGS_NO_LAYOUTCOMMIT |
> FF_FLAGS_NO_IO_THRU_MDS | FF_FLAGS_NO_READ_IO, unconditionally), so
> against a Linux server the no-fallback path is not the appliance corner
> case the commit describes -- it is every layout.  With no fallback left,
> a DS connect that cannot complete is now fatal to the boot.
>
> FF_FLAGS_NO_READ_IO does not save the read: the client only diverts
> reads off IOMODE_RW segments, and a read-only NFS root is served
> IOMODE_READ segments, where the flag does not apply.
>
> Declare the dependency via MODULE_SOFTDEP("pre: nfsv3") instead of
> discovering it at I/O time.  The layout driver is itself loaded by
> request_module("nfs-layouttype4-4") from find_pnfs_driver() during
> mount(), which on an initramfs boot happens while the initramfs and a
> working /sbin/modprobe are still in place, so a softdep is resolved at a
> point where the usermode helper can actually run.
>
> This pulls in nfsv3 whenever the flexfiles driver is loaded, including
> for layouts whose data servers all speak NFSv4.1 and which would never
> have needed it.  That seemed the better trade against an unbootable
> system.
>
> Reported on openSUSE Tumbleweed with kernel 7.2.2 under QEMU,
> reproducible with dracut's TEST-60-NFS suite against any knfsd built with
> CONFIG_NFSD_FLEXFILELAYOUT=3Dy.  Booting with rd.driver.pre=3Dnfsv3, whic=
h
> loads the module from the initramfs before the pivot, is a complete
> workaround and confirms the diagnosis.
>
> Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
> Cc: stable@vger.kernel.org
> Assisted-by: Claude Opus 5 <noreply@anthropic.com>
> Signed-off-by: Antonio Alvarez Feijoo <antonio.feijoo@suse.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayo=
ut/flexfilelayout.c
> index 7fe8b91fa47c..12a4a7908fe3 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -3079,7 +3079,7 @@ static void __exit nfs4flexfilelayout_exit(void)
>  }
>
>  MODULE_ALIAS("nfs-layouttype4-4");
> -
> +MODULE_SOFTDEP("pre: nfsv3");
>  MODULE_LICENSE("GPL");
>  MODULE_DESCRIPTION("The NFSv4 flexfile layout driver");
>
> --
> 2.51.0
>
>

