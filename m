Return-Path: <SRS0=AoDj=NU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DE66C43441
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 18:01:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1932520818
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 18:01:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q9h2eZnK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1932520818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728026AbeKJDnO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 22:43:14 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36380 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727995AbeKJDnO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2018 22:43:14 -0500
Received: by mail-it1-f193.google.com with SMTP id w7-v6so4587336itd.1
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2018 10:01:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=QPi3ISwQPMwInMCal+C8DlW8ufoY7e+sdx2QNWIUOAA=;
        b=Q9h2eZnKh6lzWMKu8XBUF4909gkXWKZoISPjBtv9wLsSMD3v1ip9ilBYqhqTRcMyGa
         d7Vi0EP++5ouYunvMK2+uMcm6F8iHLuKASX5cLy62wR9JQ+qbAGfOGW81WMcDNoTh3Cl
         B8T/KV7AcdEgP50tOu/6V2RLAqP2/Zv97nOXrhE8QyDVvX2mF7l/hRYiEqZWBiaMphd8
         grzTW1Yge5qLg/nWEL4TT782QEGv6A0kfWCkQvAOkGNO+e7JGRvb5x9f0tR2E1wnca7J
         pfMeC+d5F930zSZWpHlx5gUZ3cmQ95X02td17dV5LO9O5JFnPq7prtiyzSg1ac6LjHi7
         prmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=QPi3ISwQPMwInMCal+C8DlW8ufoY7e+sdx2QNWIUOAA=;
        b=EQp6zNoikv61HqzhtI+WH6v87+n8JDSyb0eFsSaSi8EwXUkVxSN6E6ZFp/CKgEEJrg
         +uTm7uiukXFO5l9kXGbr9Y4CmhXs7wh2xsZ+zTGMl/os6rHD1f5Cjm3MMTF4PyK6yft8
         AXe4wbXujrkwWRPvGs1dVgongPXB+IF38hVJr5iyspcFZh/S+n1jwVhGWwawms+EqPZs
         s5Tk2QJ0pJmHVQG9Ju6WPaYdPnRTHOwTDGK5LB1erIPhs4i/nxGB5RABSdO2oF9aQsp9
         Fy2obvurUMnm26WFCkSR1GOPBel6b4Ieavv1z27Oi9cD31Bx+Oz0YJRbTSljQiexR7kZ
         pS6A==
X-Gm-Message-State: AGRZ1gLQ9zN5jylqj/zuM57KOVtHz+tC0RBVPGnYAGs1dvOOp8MgborE
        E6gVyalK5JxDigM82mDN8fQ=
X-Google-Smtp-Source: AJdET5fyupRAzBSvX3/HXS3MXRwLmFbn2HjKg6nlNQHFsBD3hYXPSc2admNepqSnLUr2uIiYeX9otQ==
X-Received: by 2002:a02:506:: with SMTP id e6-v6mr9103741jad.69.1541786493974;
        Fri, 09 Nov 2018 10:01:33 -0800 (PST)
Received: from anon-dhcp-171.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id p22-v6sm2569111iog.3.2018.11.09.10.01.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 10:01:32 -0800 (PST)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: NULL dereference in rpcauth_lookup_credcache
From:   Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20181108214452.GH6090@fieldses.org>
Date:   Fri, 9 Nov 2018 13:01:30 -0500
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
References: <20181108214452.GH6090@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 8, 2018, at 4:44 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> Since -rc1 my regression tests crash my client.  Is this a known
> problem?  I'll investigate some more, I haven't even looked at the =
code
> yet or checked which test exactly is hitting this.
>=20
> --b.
>=20
> [  164.109570] BUG: unable to handle kernel NULL pointer dereference =
at 0000000000000008
> [  164.111207] PGD 0 P4D 0=20
> [  164.111528] Oops: 0000 [#1] PREEMPT SMP PTI
> [  164.112303] CPU: 2 PID: 2947 Comm: kworker/u8:5 Not tainted =
4.20.0-rc1-13223-gafb6d1c474ef #1898
> [  164.113487] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), =
BIOS ?-20180531_142017-buildhw-08.phx2.fedoraproject.org-1.fc28 =
04/01/2014
> [  164.115301] Workqueue: rpciod rpc_async_schedule [sunrpc]
> [  164.115920] RIP: 0010:rpcauth_lookup_credcache+0x3d/0x450 [sunrpc]
> [  164.116700] Code: 89 f5 41 54 41 89 d4 53 48 83 ec 38 89 4d b0 4c =
8b 7f 20 65 48 8b 04 25 28 00 00 00 48 89 45 d0 31 c0 48 8d 45 c0 48 89 =
45 c8 <41> 8b 77 08 48 89 45 c0 48 8b 47 10 4c 89 ef 48 8b 40 28 e8 cb =
d2
> [  164.119299] RSP: 0018:ffffc90001ee3cf0 EFLAGS: 00010246
> [  164.119872] RAX: ffffc90001ee3d10 RBX: ffff88007cc18180 RCX: =
0000000000600040
> [  164.120800] RDX: 0000000000000001 RSI: ffffc90001ee3d60 RDI: =
ffff88007cafb198
> [  164.121643] RBP: ffffc90001ee3d50 R08: 0000000000000000 R09: =
0000000000000000
> [  164.122464] R10: 0000000000000000 R11: 0000000000000000 R12: =
0000000000000001
> [  164.123373] R13: ffffc90001ee3d60 R14: ffff88007cafb198 R15: =
0000000000000000
> [  164.124296] FS:  0000000000000000(0000) GS:ffff88007fd00000(0000) =
knlGS:0000000000000000
> [  164.125322] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  164.126006] CR2: 0000000000000008 CR3: 000000007829c003 CR4: =
00000000001606e0
> [  164.126860] Call Trace:
> [  164.127045]  ? call_retry_reserve+0x30/0x30 [sunrpc]
> [  164.127622]  rpcauth_lookupcred+0xa0/0xc0 [sunrpc]
> [  164.128200]  rpcauth_refreshcred+0x15f/0x170 [sunrpc]
> [  164.128807]  __rpc_execute+0xa9/0x460 [sunrpc]
> [  164.129281]  process_one_work+0x227/0x630
> [  164.129684]  worker_thread+0x3c/0x390
> [  164.130062]  ? process_one_work+0x630/0x630
> [  164.130609]  kthread+0x11d/0x140
> [  164.130936]  ? kthread_park+0x80/0x80
> [  164.131339]  ret_from_fork+0x3a/0x50
> [  164.131676] Modules linked in: rpcsec_gss_krb5 nfsv4 nfs lockd =
grace auth_rpcgss sunrpc
> [  164.132719] CR2: 0000000000000008
> [  164.133050] ---[ end trace b4028a6781a696ad ]---
>=20

I just encountered this repeatedly with cthon04 general tests.

MNTOPTIONS=3D"rw,proto=3Dtcp,vers=3D4.1,sec=3Dsys"


--
Chuck Lever
chucklever@gmail.com



