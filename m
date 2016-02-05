Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33464 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbcBEXd6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 18:33:58 -0500
Received: by mail-oi0-f47.google.com with SMTP id j125so50932349oih.0
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 15:33:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454706518-4641-4-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
	<1454706518-4641-4-git-send-email-andros@netapp.com>
Date: Fri, 5 Feb 2016 18:33:57 -0500
Message-ID: <CAHQdGtRyM0MZ5X3DrjJBJwru_u6fkTmGQe7LjN=D633vGUCrXg@mail.gmail.com>
Subject: Re: [PATCH RFC Version 1 3/6] SUNRPC: allow rpc_xprt_switch_add_xprt
 to add xprts on the same net
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 4:08 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> NFSv4.1 session trunking wants to add multiple xprts to the same net.

So does the original code. We never want to add xprts from different nets.

I'll fix the typo in the original patch.

Cheers
  Trond
