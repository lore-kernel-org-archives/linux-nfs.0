Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F43EC282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 18:55:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 172F82082E
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 18:55:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="NFODjyWt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729300AbfBDSzA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 13:55:00 -0500
Received: from mail-vs1-f45.google.com ([209.85.217.45]:45013 "EHLO
        mail-vs1-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728731AbfBDSzA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 13:55:00 -0500
Received: by mail-vs1-f45.google.com with SMTP id u11so577608vsp.11
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2019 10:54:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:from:date:message-id:subject:to;
        bh=/d149eHIveBn5MXAg0380glR8TRTcY6uGrO0jyvfNgc=;
        b=NFODjyWtXFYXl4o6Nrtwyl+BNpPvcN+IveLBEXSM67xAU5vtTQfkJSSltgSMCkkYu8
         0ZLpuJafqNUI2kJgmnkp3JBCfSE+m6tK7wtU2Kvmw0RCRosHWkJ/R7LvJupadeKo6kTd
         wP69Cjc+ayMvSk3LWbEZEuRRUSiOUB0SsgY5oVe61GFZfbHiSPPNLCZ6rjwzPHtZk1ZQ
         umWQHmcDMi0y1S2CKZjhJZ7S/JFLRzxWjQxL/CksU8+qVxu1pkAOOMt3KoH20dlghriz
         RIE5aENDezlcuos9f+6mwL4ui04hfFZ8sFH59nmbwjLZlnSBiLm4PuFiKsJiXtflQtPK
         h5Fg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=/d149eHIveBn5MXAg0380glR8TRTcY6uGrO0jyvfNgc=;
        b=RaBDugxs5UpdNH81AQkYc1tMFmzV7RchTP/b88KuixbD/bCl38CbCP74Q1PPyKyvAE
         D3g1bU7UF0HycQ0d4/8fERLGHABzaz3rAtEGLRYN9lworp0zt5ccM3MaNGp7ZAojvk8z
         /7nT0VRQw/XZFydRbjjawgmNneODM5pq1RpmRYQGgmf451sknFnw2HkW3I3SFFjxApgt
         rQodhH63LabFS3pjAFll3S34UTIFeqx6P5bBCXeQctYuDkJtnxrJ4Pkm9+8g8fhxeZmS
         UYKmfeALMM1Vw9SH75r3NIwXDSC5C44SIBF+wwh2pc56oMI6q4e0K8U+smuJxJXpUkJT
         ogSA==
X-Gm-Message-State: AHQUAuaDeuTwAi+5iIH43iS9diVR4KCdgr2kcmV6eGfiaNFEYYWzQguX
        sp3UNnfuwMEoQw4eSFyME6rtMEk5oG0JOo92s1v2jg==
X-Google-Smtp-Source: AHgI3IZNJTw2HvTPs7V3xCi3uJ4d8AYrR3PvHNhnu79UzVSrWVoUfKOFlq3MuLsmTJKOOkJgWUeKG5XU+TKjpiSyJMU=
X-Received: by 2002:a67:e242:: with SMTP id w2mr387870vse.134.1549306498800;
 Mon, 04 Feb 2019 10:54:58 -0800 (PST)
MIME-Version: 1.0
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 4 Feb 2019 13:54:47 -0500
Message-ID: <CAN-5tyEm3F2Z8bJ_SyLdWqj432xy4_+W0ucMBpOg5PV0u5OGWw@mail.gmail.com>
Subject: why no nlmport mount option been implemented
To:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi folks,

I'm curious why there is an option to by-pass the port mapper call for
the MNT port but not for the NLM port? Is there a reason why having
such an option is a bad idea?

Thank you.
