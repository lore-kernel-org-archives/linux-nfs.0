Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06B1AC47094
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jun 2021 15:25:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E3FEB61107
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jun 2021 15:25:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230411AbhFGP1e (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jun 2021 11:27:34 -0400
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:36730 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S230386AbhFGP1e (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2021 11:27:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1623079542;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type;
        bh=KSxFuzdvnaSD/hQDMG5nZuMDfjyv6JLJ1uBuMDxyf4w=;
        b=BVA+rkg6q3zZvveARTy3b5nE1jOivm6TeeuT/yrLutEgJsv3CFPBNVzAebH3mQK8yp99za
        RCKrCw6rQzxrRfutE615ekmoU928j55LoOlFS3rGcuKwZkMvajNVynXMxG1nWwmCIo9r63
        Yd+23MjPGm9GIMc9sWt3ZKpFA9TzOh4=
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com
 [209.85.166.69]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-5-Z6Yt5kUxPqmKC8FKgmn6rQ-1; Mon, 07 Jun 2021 11:25:41 -0400
X-MC-Unique: Z6Yt5kUxPqmKC8FKgmn6rQ-1
Received: by mail-io1-f69.google.com with SMTP id e13-20020a5d8acd0000b0290492c16924a0so12300181iot.14
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jun 2021 08:25:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=KSxFuzdvnaSD/hQDMG5nZuMDfjyv6JLJ1uBuMDxyf4w=;
        b=kcL0oSzrC3vRZkli3isL+H+yX3eL78vwNQ5JaVBPONvslhZOVY3MjIVHGr2mkfjJ/8
         gMp+bjITS6g7bYP7fY6V6Q7TOTLORgGqYg0Wd6JGZ2uEm14pd3TG+CECM1dD4N2hkUBe
         5zOnggymus0QsnnadP0fNUzwEoUas3V8r/kEDxJ1d9vjxGjRDmk0ix++RUE2zsCAWaOr
         BfTkSfyxmbN6mG0yef0U6UeHDcAiQxTFb5u1baMlLxPAOQ7GY4DnYjoOHO03LOB7EZp0
         f9pWSDweuVfylP5+PHNdnIocLaDFO0A800Y2uwQZ1wNLPqSNIuo+YNtHNDQ3ENAZ+Zfy
         aIqg==
X-Gm-Message-State: AOAM532JF9ftQX6cQqeuehVNjBgKxhXkGMrl1VVIaHIsnMZ1VLJddffm
        n5S4okoK4B0+l/tGfZsujvPQE/cnQ0tjFV/a+EvU0b5nwmFguuHNejiOdjw5XNArk1kG2gnwdsU
        KhsECn8QXq1LfQIDV1EYPV7brqMNGG2lUFhqe
X-Received: by 2002:a5d:914f:: with SMTP id y15mr15048614ioq.196.1623079540932;
        Mon, 07 Jun 2021 08:25:40 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJw/M3bz/PQUDGYbDG+aY0xrQFE30oh++RR0qeAAsrGmKMF4B+tsXTrhjQM/a17+qcHJYmHtq1gZlqV7aQlUGzo=
X-Received: by 2002:a5d:914f:: with SMTP id y15mr15048603ioq.196.1623079540738;
 Mon, 07 Jun 2021 08:25:40 -0700 (PDT)
MIME-Version: 1.0
From:   Alexander Ahring Oder Aring <aahringo@redhat.com>
Date:   Mon, 7 Jun 2021 11:25:30 -0400
Message-ID: <CAK-6q+hS29yoTF4tKq+Xt3G=_PPDi9vmFVwGPmutbsQyD2i=CA@mail.gmail.com>
Subject: quic in-kernel implementation?
To:     netdev@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        smfrench@gmail.com, Leif Sahlberg <lsahlber@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

as I notice there exists several quic user space implementations, is
there any interest or process of doing an in-kernel implementation? I
am asking because I would like to try out quic with an in-kernel
application protocol like DLM. Besides DLM I've heard that the SMB
community is also interested into such implementation.

- Alex

