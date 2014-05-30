Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:57949 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562AbaE3LiM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 07:38:12 -0400
Received: by mail-ig0-f177.google.com with SMTP id l13so678520iga.16
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 04:38:11 -0700 (PDT)
Message-ID: <1401449890.4645.1.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFS: Use smp_mb__{before,after}_atomic()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Thierry Reding <thierry.reding@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 30 May 2014 06:38:10 -0500
In-Reply-To: <1401440815-4227-1-git-send-email-thierry.reding@gmail.com>
References: <1401440815-4227-1-git-send-email-thierry.reding@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-05-30 at 11:06 +0200, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> Commit febdbfe8a91c (arch: Prepare for smp_mb__{before,after}_atomic())
> deprecated the smp_mb__{before,after}_{atomic,clear}_{dec,inc,bit}*()
> functions in favour of the unified smp_mb__{before,after}_atomic().

Where is this commit? It doesn't seem to have hit upstream yet.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


