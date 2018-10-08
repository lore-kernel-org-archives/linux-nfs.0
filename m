Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lj1-f181.google.com ([209.85.208.181]:40785 "EHLO
        mail-lj1-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726418AbeJIC7c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Oct 2018 22:59:32 -0400
Received: by mail-lj1-f181.google.com with SMTP id r83-v6so18960361ljr.7
        for <linux-nfs@vger.kernel.org>; Mon, 08 Oct 2018 12:46:09 -0700 (PDT)
Received: from [192.168.0.104] ([217.197.11.36])
        by smtp.gmail.com with ESMTPSA id s76-v6sm4211725lje.94.2018.10.08.12.46.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 12:46:07 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: Language Lawyer <language.lawyer@gmail.com>
Subject: Kernel NFS client and Kerberos delegation
Message-ID: <6369655a-a0b0-5c3c-7c68-b623a4270668@gmail.com>
Date: Mon, 8 Oct 2018 22:46:06 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

AFAIU kernel NFS client keeps ID -> Name mapping in the "id_resolver" keyring.
Do I understand it correctly that with this hard mapping it is not possible for a service to access a kerberized NFS storage on behalf of some user using user's delegated (for example, with S4U2Self+S4U2Proxy) credentials?
