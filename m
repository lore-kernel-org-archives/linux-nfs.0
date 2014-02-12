Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33420 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaBLDrK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 22:47:10 -0500
Received: by mail-ie0-f174.google.com with SMTP id tp5so5257020ieb.33
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 19:47:09 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] SUNRPC: Fix potential memory scribble in xprt_free_bc_request()
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <CALrKORqBECRi5jHNJNoXHQSy9rBYw+2=cD96ZVakEejCtzRB_w@mail.gmail.com>
Date: Tue, 11 Feb 2014 22:47:07 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <79D80F1E-41FC-49BF-AA6F-F54B8838C978@primarydata.com>
References: <1392147810-23405-1-git-send-email-trond.myklebust@primarydata.com> <CALrKORqBECRi5jHNJNoXHQSy9rBYw+2=cD96ZVakEejCtzRB_w@mail.gmail.com>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 11, 2014, at 21:12, shaobingqing <shaobingqing@bwstor.com.cn> wrote:

> 2014-02-12 3:43 GMT+08:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>> The call to xprt_free_allocation() will call list_del() on
>> req->rq_bc_pa_list, which is not attached to a list.
> 
> Since the type of req->rq_bc_pa_list is struct list_head,  I think it
> is right on the tmp_list or
> the xprt->bc_pa_list.  Do I misunderstand  sth?

Not when xprt_free_bc_request() calls xprt_free_allocation().

>> This patch moves the list_del() out of xprt_free_allocation()
>> and into those callers that need it.

…and the point is that we do not add the list_del() to xprt_free_bc_request().

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

