Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C40B7C6786E
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:54:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 41AC120824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:54:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="LoObNNIE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41AC120824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726113AbeJZVb1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 17:31:27 -0400
Received: from mail-vs1-f44.google.com ([209.85.217.44]:38352 "EHLO
        mail-vs1-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725983AbeJZVb0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 17:31:26 -0400
Received: by mail-vs1-f44.google.com with SMTP id a202so638502vsd.5
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 05:54:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=xFgN29I5+snBELjAGWj80UtIR0ZCD/55l0wBTs22wDA=;
        b=LoObNNIEklXR6DoObpkJbuZ5xvgcodxh5yB3JjtWt1PuvttBd1xo3t1Emf8yG8b3fT
         ch8tK8pxehHqiwt/2TJQ9Sm9J2JN8bN5by2DEDYLO/R/mxdd/XAAbWroTeyxwIh5CYXp
         axidoIPfr8bz8uIP/pURxyKJxfrlqybSxmo0gkMf0ViN/IprCMx2tPYo46TSkxI4TKrJ
         PjpuGFL2w/6mOi9jjVF57a+LAic4C+yOFb2dUACdPOSECaRy0BmG01y/p1wUEm8XqalG
         RLsALGP0iziiUkzfFxw+OAJhoKUg9fijW0gngmNHv9bTRcZ5n5KPqi7LPs5bJdb8p7fK
         rHJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=xFgN29I5+snBELjAGWj80UtIR0ZCD/55l0wBTs22wDA=;
        b=adDXiB8oo2kr3KJ7PfUAjt60QtPgkNXAsCMtNpJpX9tSZGiH+kSGzqkYTbap0jplqd
         ZF28JzvzZ0LP0oo3W0F52imai3BMcK9dsW6gYpVOeIe6u883PMs5sKARfy6kmP1mCmu3
         tXwOR6VOgrXalGhsLCJmAMezjpJ0JuokIUsqVtjvUJf53vN725/L6gekxlSsnvpnD2wb
         iV+JZLwVSyMOrPPH3qxVXav6lJ852l/XdPU85vdaqF+et+T/e/tPhZrHBXnFuGQGgn8N
         mHTXF+I6BOW4SQ/VTTlKfw946P67KGQ/TUi9Th/1QILAB/XINgIb9s6maR5ELA8AE+1Q
         cHyQ==
X-Gm-Message-State: AGRZ1gJrNg2lLFCs9U+UZsUZMu4dNSg5LIXe8fF1snt/sY8rlkKmTPgS
        7RwqG0quuxsJNBafgJ7ZrHB5jg2R5kOeZllYp6aD1pYY
X-Google-Smtp-Source: AJdET5e8cgw9CbOzXLr7qEOLo6mwMlRJDCcPwLSyHkpW8cdXpCTk3tXWESQRl6X985QneG/WWQp59v987C7aIpUi0i4=
X-Received: by 2002:a67:f441:: with SMTP id r1mr1449000vsn.164.1540558466329;
 Fri, 26 Oct 2018 05:54:26 -0700 (PDT)
MIME-Version: 1.0
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 26 Oct 2018 08:54:15 -0400
Message-ID: <CAN-5tyEn+mM8ucuPXawN9L57XyGHUQHNL6Ddic5TFdXYTY2bSg@mail.gmail.com>
Subject: copy offload support and absent file system
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

In the context of doing a copy between different "types" of
filesystems, it was pointed out to me that NFS has many types:
nfs4_fs_type, nfs4_remote_fs_type, nfs4_remote_referral_fs_type,
nfs4_referral_fs_type. So doing a simple check that fs type of "in"
and "out" might not be sufficient. Do you see any issues allowing a
copy offload between different types? Basically checking that "in" and
"out" descriptions come from any of the these types?

Thank you.
