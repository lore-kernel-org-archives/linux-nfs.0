Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB9AA45000
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 06:43:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.161.41
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786862598; cv=pass; b=NCsNeJSAOepFEV2IS9anoleKmRDhoZGOaBJR5OX+UU0DwpvDky06cpuuPuFnSymRRw4KJrEBNLmIRrlpxIPnYwasC4pcIQHCToJW0/0jzPfmu50ZQFS0ZRRS7QUJxXAElustZySxVV7VUnPo0kssMabz5n1aGlE16Z5eqVDbpRM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786862598; c=relaxed/simple;
	bh=4EhlUtqI0ZQR5ej3cHGdmGP2zw4JEnoPb+AFwXKPrk8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=H3WnPkc/9068xB5l/7mjA0i+85T7e8BoRBpcC3xV+ItKMPIWXqkgop7PoDMHH+MTXDbh3cWCbiPKtM40nMcKS6Kv5gkmh+STz8T/DKld03HrtLfom6RjrmsfgqnWeNxlTLpyZ167kKYMvi8UYWaGlSPAMe1ry/WpDLzPrD4qVos=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HzMihKoQ; arc=pass smtp.client-ip=209.85.161.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HzMihKoQ"
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-6ae8445b7b6so1065314eaf.0
        for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 23:43:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786862595; cv=none;
        d=google.com; s=arc-20260327;
        b=U6j9HaQS/AeggMJe2wKiNUTSs3jL18afPPBS7HY2IkhkyvOc8T81N4D4084EuLCjqS
         DlAsA4r//sZ75rkTXGb+EiKJZ43JgloG41J1HeIdNcuP1S0JqgGqK7yerhM8ejLAqhox
         J0d2Q1yrWr0/4qUZIGQ61t2pMS5eyyayySTij10QWk16YBkZI606d3KCdBrPS1bON2KR
         CKLZRakQVzpC/vkFok3Oc0NM+TE16zDB9V4NZwsKJEjIndjLzkldHniTy6Aq5oNY/CpD
         o6jyXfi2XIC/V/xZDRx2y/wy9BimT4UW12acZOKZzoMNXBjzV5q6B49Ml8Fjp7Ck0wd+
         Wx6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=xHy2XC2Tp+BRD4bd8zHCFWzo07C1nxgQlyHueqmbM/U=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=DdWu9H7uofqGva4fq3WC61SNXMwlO45+irM7RGeAtOfJapcp4RJKLUsS11CapDT2ql
         wkBBOAdHlpJ6YcLYKdYr3X8kxMEDveq3crYIT+SZSfp9hwLcaIB0mwkNS42eutrmOYm6
         Yc+UWw+vW2nrY4ewzjLew+5XEoM8+jH3JvmaONNwuaadK/c6No21w0OrEu7J3HHMiUAb
         Z3BjKEzBmhh97zqSs/PMKzWddxqPNXWO5gAJEyxh3cEZWtUeWuoiI2/TZEeFi5GAQ4Ax
         AyCrhnsGKloQUxBKdW+rc3MQ5D9GqJsDuAMNasrwWVXGc0gHTTJ1t+wYxrefp0OTttHn
         TGqw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786862595; x=1787467395; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=xHy2XC2Tp+BRD4bd8zHCFWzo07C1nxgQlyHueqmbM/U=;
        b=HzMihKoQ1J0ThrMG3aImSrpc3KgFCiVTfbjuLZE6LneMD8SRD0vn0XyugEZDsmtvK0
         I27sTu6NABE3OTAnn+Xt72eWlvGhl0TFLjGoKqd/1MVaxrfvUXWwxQAl1soKpvHeo/sn
         EA+IqobliavQPJc8w3q2T+ZD2fnEaYOi+UqUzNfuUnxXO0StbZlYDwXVkyQQ4imEdIOf
         pKMetcTtdRt6My+3xTOyUyHj36M+wd6c9imquieRB5COA80KelH6Qh+Xl3LY4WK2cZ9I
         +kyhdNj+IdgPikhWtTvrj5/vZka8M5/Uu/D+ygZSD5kD0wjz03scKKFAesVIjQ7eeiOw
         ihhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786862595; x=1787467395;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=xHy2XC2Tp+BRD4bd8zHCFWzo07C1nxgQlyHueqmbM/U=;
        b=QlxmLcJwC8Vddkz6Qpi62uJ3QYlGuECSrMPe8wxW1dharPM6KccBqd2h2dACq6oNad
         PNvGLhFM1tZKIywqOd+YhFUQh8IncS10JjyV69vv0yEqB7mR7zjydapQDgJZx0oACTy/
         66jPhk9vsrVx6/6W4ueh90+zylBPYG7wvyGiE6PmxAEB8ZkKM+UX+ROAw92TnwEBHVDc
         FWUr2tHgj8SHVRMA9dOkzy6Uu2fudenmj+5vcmI5+Dm+oKvOekXVjdDNFV64j+fqC5g8
         EtLH0NKYmDWf+3yhfTjU/r704XbGZ5pU1wHbTiY7rkiK5U+0nIeg5t+X1orklEGo6s4E
         RQEw==
X-Gm-Message-State: AOJu0Yy2AeoAAR3hBxR42Os0A/z7a7MNgeDvUOtnx0YE0HOQgxdC4FXb
	naF3Pf/wBFfi+5mUwyUwZzjhM5iw93w6kHgc8r8GK3XZ6ag+Ol4O24JtV0g9fwJDwaBiXObYL+R
	WZAQo0+8vi/zvWjQGoGkIqSy8sTN14JWgHOYbC98=
X-Gm-Gg: AR+sD12IvvjppHWx5B1O3M9XTy4E3drH9Wd4RRmc1cAYqBxkVcBmPzsaYBp2VBnfajJ
	HE/dkEhd5Wo0LMFIQjJBTTZyrnpXLZyebTrBtoDRBvU9pjcBZvy3bVXQFqHQ0NFgk22gC5Cs8Io
	FmReFO/MNxDl/Xd7JQIgnVTOP6U9iPGzhymMPdfRDSJHDgAixnpTtpR8kn2+oMFYxK2TYkAcWWt
	ZGpDye5W2sohXXwEmFFXwbRN8MqpsKVpLek8Y5UWR9XCnAheeJTFzRSApVbdC1Yjp+brKTwq/fe
	yI1s2lAcIWdhtdnFTtyCl9tqCzvZ7n2NyVazJ9BE+qb3
X-Received: by 2002:a05:6820:6ae3:b0:6aa:f7ac:faf3 with SMTP id
 006d021491bc7-6b0d6246224mr14928730eaf.19.1786862595514; Sat, 15 Aug 2026
 23:43:15 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org> <20260815-recall-any-keep-count-v4-4-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-4-bfb5b83d6cb1@kernel.org>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Sun, 16 Aug 2026 08:42:00 +0200
X-Gm-Features: AcwNN1VJrRiCQVDrIMUlnwUN9S6rOtdJ_H5RJznuYF-U3u5I0x65dPagz49mzCM
Message-ID: <CALXu0Udh--HV_H-90PxVzGA8vuP-u54fkwsqkf0_gkDnEg_C6w@mail.gmail.com>
Subject: Re: [PATCH v4 4/8] NFSD: Send a meaningful CB_RECALL_ANY keep count
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Sat, 15 Aug 2026 at 18:39, Chuck Lever <cel@kernel.org> wrote:
>
> deleg_reaper() sets craa_objects_to_keep to zero on every
> CB_RECALL_ANY. RFC 8881 Section 20.6.3 defines that field as the
> number of objects the client may keep, leaving the client to choose
> which of the excess to return, because the server cannot read lack
> of recent use as lack of usefulness. Zero asks for every delegation
> the client holds, including the ones backing files an application
> still has open.
>
> There is also no reason NFSD has to reclaim the entire delegation
> working set on the first sign of memory pressure.
>
> Derive the keep count from cl_deleg_count so that each callback
> asks for one delegation. Both the shrinker and the laundromat re-arm
> while their condition lasts, so a client with more to give is asked
> again on the next pass.
>
> The Linux client ignores craa_objects_to_keep and returns unused
> delegations selected from the type mask alone, so the count changes
> nothing for it.
>
> Fixes: 44df6f439a17 ("NFSD: add delegation reaper to react to low memory condition")
> Signed-off-by: Chuck Lever <cel@kernel.org>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2214b4d60c7e..5c2dd6657fac 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -7942,6 +7942,7 @@ deleg_reaper(struct nfsd_net *nn)
>  {
>         struct list_head *pos, *next;
>         struct nfs4_client *clp;
> +       unsigned int count;
>
>         spin_lock(&nn->client_lock);
>         list_for_each_safe(pos, next, &nn->client_lru) {
> @@ -7951,21 +7952,33 @@ deleg_reaper(struct nfsd_net *nn)
>                         continue;
>                 if (clp->cl_state != NFSD4_ACTIVE)
>                         continue;
> -               if (list_empty(&clp->cl_delegations))
> -                       continue;
>                 if (atomic_read(&clp->cl_delegs_in_recall))
>                         continue;
>                 if (ktime_get_boottime_seconds() - clp->cl_ra_time < 5)
>                         continue;
>                 if (clp->cl_cb_state != NFSD4_CB_UP)
>                         continue;
> +               /*
> +                * This read races with hash_delegation_locked() and
> +                * unhash_delegation_locked() on other CPUs. A stale
> +                * count only skews the keep value; the next
> +                * laundromat pass sees a more current one.
> +                */
> +               count = data_race(READ_ONCE(clp->cl_deleg_count));
> +               if (!count)
> +                       continue;
>                 if (test_and_set_bit(NFSD4_CALLBACK_RUNNING, &clp->cl_ra->ra_cb.cb_flags))
>                         continue;
>
>                 /* release in nfsd4_cb_recall_any_release */
>                 kref_get(&clp->cl_nfsdfs.cl_ref);
>                 clp->cl_ra_time = ktime_get_boottime_seconds();
> -               clp->cl_ra->ra_keep = 0;
> +               /*
> +                * Ask for a single delegation. Recalling one before it
> +                * is needed costs the client an OPEN when it next
> +                * touches the file.
> +                */
> +               clp->cl_ra->ra_keep = count - 1;
>                 clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
>                                                 BIT(RCA4_TYPE_MASK_WDATA_DLG) |
>                                                 BIT(RCA4_TYPE_MASK_DIR_DLG);

You can add a Reviewed-by: Cedric Blancher <cedric.blancher@gmail.com>.

Could you please backport this to the stable branches up to Linux
5.10, because conforming NFSv4.1 clients get robbed of all their
delegations if craa_objects_to_keep=0.

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
