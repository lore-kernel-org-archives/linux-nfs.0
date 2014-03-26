Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43443 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbaCZR0B convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Mar 2014 13:26:01 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so2228686pad.29
        for <linux-nfs@vger.kernel.org>; Wed, 26 Mar 2014 10:26:01 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] NFSv4: Memory not being freed on memory allocation failure
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1395849036-6907-1-git-send-email-steved@redhat.com>
Date: Wed, 26 Mar 2014 10:25:57 -0700
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <22F1169D-33AA-4B8F-ADE0-E8BEEE97E361@primarydata.com>
References: <1395849036-6907-1-git-send-email-steved@redhat.com>
To: Dickson Steve <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 26, 2014, at 8:50, Steve Dickson <steved@redhat.com> wrote:

> nfs4_run_open_task() puts a ref count on the nfs4_opendata
> data pointer, then tries to allocate the task pointer.
> If that task allocation fails nfs4_run_open_task() returns
> leaving the ref count on the data pointer.
> 

Hi Steve,

That should not be the case. rpc_run_task() will always call nfs4_open_release() even if it returns an error.

Cheers
  Trond

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

