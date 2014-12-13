Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:52270 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930AbaLMA0k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2014 19:26:40 -0500
Received: by mail-vc0-f181.google.com with SMTP id le20so4049184vcb.26
        for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 16:26:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1418423580-1212-1-git-send-email-andros@netapp.com>
References: <1418423580-1212-1-git-send-email-andros@netapp.com>
Date: Fri, 12 Dec 2014 19:26:39 -0500
Message-ID: <CAHQdGtQkrjWV61qPCN=vbo9zy1CKxu0Fp00vvpWV57tWWJ9FhA@mail.gmail.com>
Subject: Re: [PATCH 1/1] SUNRPC add rpc_gss_svc_t to gssd upcall
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: William Andros Adamson <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy

On Fri, Dec 12, 2014 at 5:33 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Otherwise rpc.gssd will send a V4 NULL RPCSEC_GSS_INIT call with an RPCSEC_GSS
> service of rpc_gss_svc_none for rpc_sec_gss_svc_integrity/privacy requests
> from the kernel.

I thought this behaviour of using rpc_gss_svc_none for the RPCSEC_GSS
negotiation in userland and then "stepping up" to a stricter service
in the kernel had been declared legal by the powers that be. What is
the concern about doing so?

Cheers,
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
