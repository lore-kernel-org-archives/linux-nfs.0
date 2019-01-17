Return-Path: <SRS0=+NMN=PZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63D55C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 14:33:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3152D205C9
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Jan 2019 14:33:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DK7dMfxq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727278AbfAQOdS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Jan 2019 09:33:18 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:54562 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726517AbfAQOdS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2019 09:33:18 -0500
Received: by mail-it1-f193.google.com with SMTP id i145so1622042ita.4
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2019 06:33:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=DfFWBdNxJtkd3O/Sg7AR6ceD0kGWupOek9ktqfloeSU=;
        b=DK7dMfxq6VcyhXnq7F7f92/FddORyTowuhjOQ0l4+6VfD0PUKAz39NQdxpaq60cOQp
         AJJiPQQbXWhBLZRUrqVAa8b+R9rWNzfTJoJ4R5OxMX1lRrYHPE560v+EFEAmOh3Eo13B
         U6kskt/bAZ/M6W9X+Q5a4fNPIoLnkWDfzJ0590NK91PnyzZq/rUDQU41Egx2QrhDexMF
         9nbj+v48iaVJV1rVPMZBWzSqpF6ut5uLWC7gePqoGL7zuIgn2UpJ0pNJ8W7UHbgochDF
         Dn7Z+L872t4qF3MeVIE23wXWQcFwFG9wUCgmD1IZFWjKyNxEF9xGpnvh4/aRY49hRwal
         a8jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=DfFWBdNxJtkd3O/Sg7AR6ceD0kGWupOek9ktqfloeSU=;
        b=QrDHD52ZCh1HU8wAURtCDOFGla7uTmKZt2ITPGuJrUeKglxZqdCziWiyjKYSJNRpvi
         PiZSsmbCNLw6eERV5B/vpPdwuZgaN8hS3UiQCp4ka7t0F8gU+24BVfuLJsDiZw4zQI8b
         EIuM0eJsaWyhYKVP8EH1F8dmmWv2STzz8T1d57lmz4kUoDovieR5zCrSPAKOTiY68vpE
         dzgfqa8it2Sv1pxBbZTcrHXzwJJQH/HA79U5DgtFD3zllSvueEzqgR79YZcS4oR+B1DD
         otzXdTZ6BruK/08pyALVdtiAI3UD3Y4/arNfeafj4swQIhWGMhyZ22Gw5rPjDk9WsrRp
         8ysw==
X-Gm-Message-State: AJcUukdROUdO59VcWfE6Zk/c0DjuWlGTBLeVedAoIno6WZ6zN5gvuTWh
        PyaSxJ4FVDYHhJAnngCE8sI=
X-Google-Smtp-Source: ALg8bN4LsEcnb8d3dCoGHN9XC092khmJx3jhUUdaxKsgwqo/4GEgMA9hrRv51gbwBpWnqobji27jTA==
X-Received: by 2002:a24:1dce:: with SMTP id 197mr9056931itj.154.1547735597192;
        Thu, 17 Jan 2019 06:33:17 -0800 (PST)
Received: from anon-dhcp-171.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id g12sm577707iok.38.2019.01.17.06.33.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 06:33:16 -0800 (PST)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] lockd: NSMPROC_MON should be send only once even if in
 multithread
From:   Chuck Lever <chucklever@gmail.com>
In-Reply-To: <1547705746-69554-1-git-send-email-zhangxiaoxu5@huawei.com>
Date:   Thu, 17 Jan 2019 09:33:14 -0500
Cc:     Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <4E812155-4DB4-4EF4-91ED-EDBB1B0BBFF7@gmail.com>
References: <1547705746-69554-1-git-send-email-zhangxiaoxu5@huawei.com>
To:     ZhangXiaoxu <zhangxiaoxu5@huawei.com>
X-Mailer: Apple Mail (2.3445.9.1)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 17, 2019, at 1:15 AM, ZhangXiaoxu <zhangxiaoxu5@huawei.com> =
wrote:
>=20
> If multiple processes are locking the same file, the NSMPROC_MON
> message would be send more than one times when the host is not
> monitored by the peer.

Hi, what is the harm of sending more than one MON request for a peer?


> Add a mutex to ensure that we just send once. If some one has send
> the msg, Just waiting for the result or try again if failed.
>=20
> Signed-off-by: ZhangXiaoxu <zhangxiaoxu5@huawei.com>
> ---
> fs/lockd/mon.c              | 10 ++++++++++
> include/linux/lockd/lockd.h |  1 +
> 2 files changed, 11 insertions(+)
>=20
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 654594e..4ba2658 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -155,6 +155,12 @@ int nsm_monitor(const struct nlm_host *host)
> 	if (nsm->sm_monitored)
> 		return 0;
>=20
> +	mutex_lock(&nsm->mutex);
> +	if (nsm->sm_monitored) {
> +		mutex_unlock(&nsm->mutex);
> +		return 0;
> +	}
> +
> 	/*
> 	 * Choose whether to record the caller_name or IP address of
> 	 * this peer in the local rpc.statd's database.
> @@ -165,6 +171,7 @@ int nsm_monitor(const struct nlm_host *host)
> 	if (unlikely(res.status !=3D 0))
> 		status =3D -EIO;
> 	if (unlikely(status < 0)) {
> +		mutex_unlock(&nsm->mutex);
> 		pr_notice_ratelimited("lockd: cannot monitor %s\n", =
nsm->sm_name);
> 		return status;
> 	}
> @@ -174,6 +181,8 @@ int nsm_monitor(const struct nlm_host *host)
> 		nsm_local_state =3D res.state;
> 		dprintk("lockd: NSM state changed to %d\n", =
nsm_local_state);
> 	}
> +
> +	mutex_unlock(&nsm->mutex);
> 	return 0;
> }
>=20
> @@ -284,6 +293,7 @@ static struct nsm_handle *nsm_create_handle(const =
struct sockaddr *sap,
> 	memcpy(nsm_addr(new), sap, salen);
> 	new->sm_addrlen =3D salen;
> 	nsm_init_private(new);
> +	mutex_init(&new->mutex);
>=20
> 	if (rpc_ntop(nsm_addr(new), new->sm_addrbuf,
> 					sizeof(new->sm_addrbuf)) =3D=3D =
0)
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index b065ef4..c56069c 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -89,6 +89,7 @@ struct nsm_handle {
> 	char			*sm_name;
> 	struct sockaddr_storage	sm_addr;
> 	size_t			sm_addrlen;
> +	struct mutex		mutex;  /* should be send only once even =
more threads */
> 	unsigned int		sm_monitored : 1,
> 				sm_sticky : 1;	/* don't unmonitor */
> 	struct nsm_private	sm_priv;
> --=20
> 2.7.4
>=20

--
Chuck Lever
chucklever@gmail.com



