Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:27717 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505Ab3JZKq3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Oct 2013 06:46:29 -0400
Message-ID: <526B9C9D.8090102@huawei.com>
Date: Sat, 26 Oct 2013 18:42:37 +0800
From: Kefeng Wang <wangkefeng.wang@huawei.com>
MIME-Version: 1.0
To: Alexander Viro <viro@zeniv.linux.org.uk>
CC: John McCutchan <john@johnmccutchan.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Eric Paris <eparis@redhat.com>, Robert Love <rlove@rlove.org>,
        <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] fs: use helper function path_foo() to simpily code
References: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
In-Reply-To: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any advice?  ping...

On 10/14 20:25, Kefeng Wang wrote:
> Use helper function patch_equal() and path_put() to simpily code.
>
> Kefeng Wang (3):
>   fs: use path_equal() and path_put() to simplify code
>   fs: nfsd: use path_equal() to simply code
>   fs: notify: use path_equal() to simply code
> 
>  fs/namei.c                           | 20 ++++++--------------
>  fs/nfsd/export.c                     |  3 +--
>  fs/nfsd/nfs4xdr.c                    |  2 +-
>  fs/notify/fanotify/fanotify.c        |  3 +--
>  fs/notify/inotify/inotify_fsnotify.c |  3 +--
>  5 files changed, 10 insertions(+), 21 deletions(-)
> 


