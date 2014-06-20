Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f172.google.com ([209.85.128.172]:32882 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbaFTRtu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2014 13:49:50 -0400
Received: by mail-ve0-f172.google.com with SMTP id jz11so3876368veb.17
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2014 10:49:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1403285426-1835-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1403285426-1835-1-git-send-email-Anna.Schumaker@Netapp.com>
Date: Fri, 20 Jun 2014 13:49:50 -0400
Message-ID: <CAHQdGtSkg6LG-J5u4qKTcK4WVWqsog2rfhRX8aQp6oyP6aUz1w@mail.gmail.com>
Subject: Re: [PATCH] nfs: Fix unused variable error
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 20, 2014 at 1:30 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> inode is unused when CONFIG_SUNRPC_DEBUG=n.
>

Thanks!

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
