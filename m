Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795118768;
	b=ZqZSs0sPpjalnZsWPQlC3Z0aLIh7rSxBRRqivjC7PzxY8vVxJcne7pr8divckYQL2kvI
	 yLTOXVAD9yc0F4+KAaLGp6CYiWosBtFy63urhjA8XJbS3v1JS3SIR3KAlMKGhEKQ1uvjS
	 SeZ8kNAB6Q87vR6H90Gs6uTf0VIEH9tjJA742aIWKxw+0EG/d188nF8hXgWv6eRCHqHrD
	 NZQoDJDAQXi+MduLfIOyovgAUtxvtkVQrBBJI7IcemhY3+N/yZbRUZQc87gr8icTaK1AG
	 6KCss2zhVpkpqmrjg3x1l1e7BB9RjlSu86+Wjz32N70c+uFC7JasbBiyCVK8OCYk1zw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795118768;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:Date:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To;
	bh=xZ22FseA32BASXAUihegs+eLkTwU7nxw0EDw4HjdUB4=;
	b=YWNo+YUYiMaRgtC0gOAOimGc075iNKgpO1JkY6Woy+OKy0REF0T7v0pNSnj9ojac+Ibi
	 7mwRBqrSGya5ctbmlkZkBqwbGeK5WMNEu/a26naCZCWyFpiXJknPYY/QexgccHNV9Lyoh
	 E+OKCa7dHom4gzuhpQa6TD7b91z/PM4JXKOBVR5rGoWJjBkQ6z/0t7mWrI9u3cxUoikuU
	 9Zn9FMNyaavlDZKXB+ihBRWgdrctuu+3NKCulT9f1D9Wtz6ACwZvzQOaX3kTWG977V7ME
	 303+Tq1COOyVt+J+Uftct55khOcVEtGCrFA7/slyVW4R727FuUEq744gO1xHqE5VkAw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=i5FKy7D9;
	arc=none smtp.remote-ip=209.85.128.41
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50665606A324
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:06:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 50665606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=i5FKy7D9
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-4a35a60499eso973115e9.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:06:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795118767; x=1795723567; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:date
         :from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=xZ22FseA32BASXAUihegs+eLkTwU7nxw0EDw4HjdUB4=;
        b=i5FKy7D964BfjAdJgIebywXm3KuFBLrbOHdcrg67FFdQMxJr6LCXKWohX2mIVC4nUx
         NDokibE7OyCW96aRrOjMVTQ4nEbY8iviGJE0cjNn+De1uokrRlY1EDvzEfdmHGooJL+t
         +Bfi8Le3ffx1KGDa2Uf7d0yiavIQSbctbzI3Je6/uceNyTCFhf2LcB38l4LMuOk2gsa+
         Ih1P1y1LbBwRk4Wm60SYup6yRcULhFzL1av1HmlsOg4CQ5W1loVNOlCZ+16QxCQe3J+D
         MpPHZ3lVWUbK7BjLL5muOEUxihI9eHkwK+tg8x9vuEfoU/yO21op8Fpn+n5AAPS9i/1U
         eDJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795118767; x=1795723567;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:date
         :from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=xZ22FseA32BASXAUihegs+eLkTwU7nxw0EDw4HjdUB4=;
        b=GwqlFodnr224ABEZl93Hg2qC4BlG4kzK7dK0amYXjxEu81QFBcriA15CmVXeq37OF4
         XgG7gNptNCvOH/N3BRhXJpicItVPZ6GJddBx7W4v0JDzyJrzS3HAta0+kwU0ENX5c53u
         NYL8WqrUhHTWKWHtLGU91ezUxTC26Bm7iV2+3kLNiL3B+xIrlXEgTrxmR1uIhAxS2tYZ
         0Hv2EvqlLHD6nQq+yL4/1uE1xiMBtUOhcPyJ3/jHypQ1iSpPKwF7HQGQ+XEMvojfiVpD
         ohoCmiD/VxStUatT3BRtd+BlthxeXGdsVAWc/RvcEOqlS/rJR6dORSr6Sf/xKzp32l9i
         0jzg==
X-Forwarded-Encrypted: i=1; AL+hErH5O5wPRNl+plNV8EBcT4DFx1nLhyp4OmZn1dZvu0vmVg0d58WHeQQhgIqw8U1fMynRUnenRz7iMRE=@vger.kernel.org
X-Gm-Message-State: APuU4Z/JhiOjcwZNp5leDt4UIzqS2A6PUXV0UMR7xVwoMi1jW6E1eWcV
	UTKxZiXGBEMcXHjIOVSoL8mxtUjLVMoN3ItacPmykEayURrgppIBsasA
X-Gm-Gg: AYBFou1AjPZ8gZXySOK5cMBHJFip6TuiIjztRVGtil3yJop1jyJhSBUolLjNUbu/a7d
	TcOX+WiCf/EzIrfqhhZyaHA1K3fugth7BQdHYDWtulDiSrCJV83u3bdCQvnW7sVWIutMM9HIPOO
	m5dE0x4o5Os7hOzTWlo4PclkMQ+w4aP97TuRAI6OdctxUIYFnSC2Q1A8zKVNWjzfP6vRQEQIc0f
	I2S3BQzyi50SDrTDmtOtPYN88JFPhf0pU9M4SxDbra8q4qRT8ULHt3jzfD70P1aHPZZMcU959yc
	g9NVwhbx35UAoTInGAHU9RVNBrTCDHur18M6Jn8wkvdnhqLr0nX1lXhBiraPyhuWnDuqbc8HAp6
	I0cCPlNQP5KY8QwoYXK8ELBaylEEBZ18evwDR+DnPlX+5ZyQOhB0HFpbsttJT5I6aohNJ5uToHm
	6hcx0yfT/Y1A2r3brTVTO7iIfk8tEKQ3nPTjEC5jKxMYyKlE1F7tAxMj9hbYR2yIg5iYcx0LG41
	Di9nHRGQc2Qc4AMyOU1+MwWLkZ+S8HzH3b+WO1hgh7e7Dh0Pt3qzrMnDla8fEdqYW33uF7Lx7FA
	pUfdUfbpvqmGgQkDiMtBBXMH91Tqu0pxUU0X0AY=
X-Received: by 2002:a05:600d:6510:10b0:4a1:811c:8078 with SMTP id 5b1f17b1804b1-4bb8881de57mr9548745e9.26.1795118766499;
        Thu, 19 Nov 2026 12:06:06 -0800 (PST)
Received: from krava ([176.74.159.170])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb8538b2c5sm58151335e9.5.2026.11.19.12.06.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:06:06 -0800 (PST)
From: Jiri Olsa <olsajiri@gmail.com>
X-Google-Original-From: Jiri Olsa <jolsa@kernel.org>
Date: Thu, 19 Nov 2026 21:06:04 +0100
To: Yingke Xiao <inkxiao12@gmail.com>
Cc: bpf@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
	anna@kernel.org, linux-nfs@vger.kernel.org, ast@kernel.org,
	daniel@iogearbox.net, andrii@kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH bpf v2 2/3] bpf: Fix missing raw_tp_null_args masks for
 NFS and pNFS
Message-ID: <av9WrAhA4skgo5JQ@krava>
References: <CAMcAce9XkYo7gPHMnmRX5EY2dNYO+ECuUF3RkPLnoGHgh8P7tw@mail.gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMcAce9XkYo7gPHMnmRX5EY2dNYO+ECuUF3RkPLnoGHgh8P7tw@mail.gmail.com>

On Thu, Nov 19, 2026 at 02:20:29AM -0500, Yingke Xiao wrote:
> Several NFS client and pNFS layout driver tracepoints pass literal NULL
> or conditionally NULL pointers for struct inode, rpc_task, or struct
> pnfs_layout_hdr:
> 
>   1. nfs4_xdr_badoperation (fs/nfs/nfs4xdr.c:981) passes NULL for arg 2
>      (const struct rpc_task *task) when decoding compound replies outside
>      RPC task context.
>   2. nfs4_set_delegation (fs/nfs/delegation.c:380) passes NULL for arg 1
>      (const struct inode *inode) when stateid refers to an unlinked file.
>   3. pnfs_update_layout (fs/nfs/pnfs.c:1980) passes NULL for arg 4
>      (const struct pnfs_layout_hdr *lo) during first-time allocation.
> 
> Add mask entries to raw_tp_null_args[] so the verifier marks these
> arguments as PTR_MAYBE_NULL instead of assuming non-null pointers.
> Verified on x86_64 7.4.0-rc3 and 6.12.118 LTS.
> 
> Fixes: c83e2d970bae ("bpf: Add tracepoints with null-able arguments")
> Cc: stable@vger.kernel.org # 6.12+
> Signed-off-by: Yingke Xiao <inkxiao12@gmail.com>

besides being mangled patches 2 and 3 do not make sense

  ▎ Patches 2 and 3 are wrong: nfs4_xdr_badoperation, fsnotify_destroy_event
  ▎ and vfs_open are not tracepoints (the closest real one is
  ▎ nfs4_xdr_bad_operation, with no pointer arg 2), nfs4_set_delegation's
  ▎ arg 1 is fmode_t and the inode is never NULL there, and
  ▎ pnfs_update_layout is already listed with 0x10000 for 'lo', while the
  ▎ new 0x1000 marks the iomode enum. The cited source lines don't match
  ▎ the descriptions either. Please drop 2 and 3.

jirka

> ---
> v1 -> v2:
>   - Correct sender identity and Signed-off-by with real legal name per DCO.
>   - Remove drafting notes.
>   - No functional code changes.
> 
>  kernel/bpf/btf.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
> index b234567..c345678 100644
> --- a/kernel/bpf/btf.c
> +++ b/kernel/bpf/btf.c
> @@ -6607,6 +6607,9 @@ static const struct bpf_raw_tp_null_args
> raw_tp_null_args[] = {
>   { "fsnotify_bump_event_seq", 0x20 },
>   { "nfs4_cb_getattr", 0x200 },
>   { "nfs4_cb_recall", 0x200 },
> + { "nfs4_xdr_badoperation", 0x200 },
> + { "nfs4_set_delegation", 0x20 },
> + { "pnfs_update_layout", 0x1000 },
>   { "nilfs2_transaction_entry", 0x4 },
>   { "iptfs_first_dequeue", 0x1000 },
>   { "iptfs_first_fragmenting", 0x1000 },
> -- 
> 2.43.0
> 
