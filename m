Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.22]:56570 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbaHNQXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2014 12:23:38 -0400
Message-ID: <53ECE285.4080200@gmx.de>
Date: Thu, 14 Aug 2014 18:23:33 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Weston Andros Adamson <weston.adamson@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz testing a 32 bit UML guest with NFSv4 gave: BUG kmalloc-256
 (Not tainted): Redzone overwritten
References: <53D4CAA7.2000005@gmx.de> <CAHQdGtRqeQXEP1+VV5UUYSdobwNjWNt8y11HC_Zb891A+t9FFQ@mail.gmail.com> <7B49B65C-3CD6-43AD-AB11-B3DDC52199FA@primarydata.com> <B5E517A7-303C-40B6-99B4-1FEF72EBFEB1@primarydata.com>
In-Reply-To: <B5E517A7-303C-40B6-99B4-1FEF72EBFEB1@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/14/2014 12:00 AM, Weston Andros Adamson wrote:
> There are two solutions:
> 
>  1) introduce a new check in nfs_can_coalesce_requests - basically the same
>     tests as were removed in commit 362251a0eb540cf2537d78d508b2bcd87fe66321, but each with:
>    && req->wb_page != prev->wb_page.

Hhm,

tfoerste@n22 ~/devel/linux $ git show 362251a0eb540cf2537d78d508b2bcd87fe66321
fatal: bad object 362251a0eb540cf2537d78d508b2bcd87fe66321


-- 
Toralf

