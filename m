Return-Path: <SRS0=ZX+r=P2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD0D1C1B0F7
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 20:59:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 972D920657
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 20:59:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dxInR+CR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729557AbfARU7z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 18 Jan 2019 15:59:55 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:37797 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729553AbfARU7z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2019 15:59:55 -0500
Received: by mail-it1-f194.google.com with SMTP id b5so7624012iti.2
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jan 2019 12:59:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=wAD2sMaoGtME7MObNFsifuRKfFBNiSXsWdMjCv6iOvI=;
        b=dxInR+CROQWnS4MxK2v99Xp0j/9FAKTc5I7NqfRaGUzoagTmbdGJm/l2wW9VISDcj2
         0qRR/NwCMJPAgSI5Eu5f/uY2CxtbHrRFNV5XblYUGFhSd/Kkxb3BNa3m6x49tx0iRk3k
         Ozpesc/WiN3yBRMshlLZCYcTJfzq9SCcKRDIybDJFmcfjBYB8w0EHpSvJ/Kocer6SusK
         mBdz8LB4tybl7KovHAuF48bRJLp9goq/BJwc8qr6Zm4drOCkiPoq+VgIj+hNiSachBnn
         ZzHrfyQO9JVuHZdYEkeK3W76ZdyRHe/DzdweGo3oGVO9Z3nENuc/AmVnAQzkpAhU1YeP
         6F3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=wAD2sMaoGtME7MObNFsifuRKfFBNiSXsWdMjCv6iOvI=;
        b=F6w3QtM+/MRt/5yANn2PZJLs2j3y3IcubmLFDZAWi/M8SW1iNrFKoeHWotzp3HVH2N
         336pDdgnoRnnKBZ76N+Epj6WJfRqS744hmoff5W8SpKB8miTrvfWgwSP5qaZo5F32btr
         Jwe9r1UJWW92tcPQewKpsojBGqPWU3KqskfrtDA9qDP74xFF8JxQFYZynBcWPeN1wrMW
         H+7uHU2SSGUmA+fBAOkLukEtM2puxz+7+x+W2cnnSrOdy5Cuya1/OWOhPDIZPiqGLt8f
         aZrEcy9R9F8raSf0jtRRI//1yK9u0rCP2NP5mYAzUC/4dek3jeO0krNgQEss6nIMOYau
         Seug==
X-Gm-Message-State: AJcUukeOlerieRiN4fU5zYXSMPbzXGtyY8LGlOAJsQZvkEvxBE/w8AL1
        //iTbBXnAKw3qGYcqJ2EOwU=
X-Google-Smtp-Source: ALg8bN5kVtCRUfcUNlOJCd/UF2KE/FIsLyH+QNBnJbWPID3KW2HR3KDY8t2B8WJK4/SgEMVQZxRLCg==
X-Received: by 2002:a24:4545:: with SMTP id y66mr11131347ita.174.1547845195027;
        Fri, 18 Jan 2019 12:59:55 -0800 (PST)
Received: from anon-dhcp-171.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id e22sm2361407iol.49.2019.01.18.12.59.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 12:59:54 -0800 (PST)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] lockd: NSMPROC_MON should be send only once even if in
 multithread
From:   Chuck Lever <chucklever@gmail.com>
In-Reply-To: <00390d85-d2dd-be57-4192-bff562a75684@huawei.com>
Date:   Fri, 18 Jan 2019 15:59:52 -0500
Cc:     Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E87ADB64-FE89-48A8-A401-3153E029D0DA@gmail.com>
References: <1547705746-69554-1-git-send-email-zhangxiaoxu5@huawei.com>
 <4E812155-4DB4-4EF4-91ED-EDBB1B0BBFF7@gmail.com>
 <00390d85-d2dd-be57-4192-bff562a75684@huawei.com>
To:     "zhangxiaoxu (A)" <zhangxiaoxu5@huawei.com>
X-Mailer: Apple Mail (2.3445.9.1)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 17, 2019, at 9:48 PM, zhangxiaoxu (A) <zhangxiaoxu5@huawei.com> =
wrote:
>=20
>=20
>=20
> On 1/17/2019 10:33 PM, Chuck Lever wrote:
>> Hi, what is the harm of sending more than one MON request for a peer?
> Maybe no harm.
> The rpc.statd won't record the peer twice.
>=20
> I found this when I tested the xfstest generic/089.
> The rpc task for that msg sometimes take very long time.
> rpc took 57 sec who t_mtab/2377 srv rpc.statd xid 2453489031 prog =
statd/100024/1 proc 2 prot 6 flags 0x680

MON is supposed to be a call to a local service (on the same host).
It would be interesting if you could determine why it takes so long.


> I think the msg just send only one time is enough.
> RPC and rpc.statd maybe consume for a long time on the network.


--
Chuck Lever
chucklever@gmail.com



