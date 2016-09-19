Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:59566 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbcISPhg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2016 11:37:36 -0400
Date: Mon, 19 Sep 2016 11:37:30 -0400 (EDT)
From: Frank Sorenson <sorenson@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-ID: <1562181493.158890.1474299450886.JavaMail.zimbra@redhat.com>
In-Reply-To: <FF4A1D11-89A1-45DB-ABAE-03692244A4B1@primarydata.com>
References: <1474056735-4008-1-git-send-email-sorenson@redhat.com> <7EC0B2B1-CE1A-4509-9FE2-A5D6529626DA@primarydata.com> <1272446089.121606.1474290650680.JavaMail.zimbra@redhat.com> <FF4A1D11-89A1-45DB-ABAE-03692244A4B1@primarydata.com>
Subject: Re: [PATCH] sunrpc: include gid in the rpc_cred_cache hash
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Trond Myklebust" <trondmy@primarydata.com>
> To: "Frank Sorenson" <sorenson@redhat.com>
> Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
> Sent: Monday, September 19, 2016 9:49:02 AM
> Subject: Re: [PATCH] sunrpc: include gid in the rpc_cred_cache hash

> AFAIK, both generic_bind_cred() and rpcauth_lookupcred() can make indirect
> calls to gss_lookup_cred() with a bog standard credential (acred->gid ==
> current_cred()->fsgid). Am I missing something?

Nope.  I was.  Thanks.

I will change direction and go down the route of hashing in the auth flavour ops.


Thanks,

Frank
--
Frank Sorenson
sorenson@redhat.com
Senior Software Maintenance Engineer
Global Support Services - filesystems
Red Hat
