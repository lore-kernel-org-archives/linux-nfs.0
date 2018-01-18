Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58244 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754758AbeARJ2Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Jan 2018 04:28:24 -0500
Message-ID: <1516267701.3594.11.camel@redhat.com>
Subject: Re: [PATCH] Remove unneeded reference to nfsidmap_internal.h
From: Justin Mitchell <jumitche@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: SteveD@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 18 Jan 2018 09:28:21 +0000
In-Reply-To: <20180117221020.11056.59627.stgit@manet.1015granger.net>
References: <20180117221020.11056.59627.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-01-17 at 17:10 -0500, Chuck Lever wrote:
> This file is not part of "git clone" and is not #included from any
> C file.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  support/nfsidmap/Makefile.am |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Hey Steve-
> 
> I don't see nfsidmap_internal.h anywhere.  Wondering if I missed
> something?

It was removed as part of my ABI cleanup (commit f080188e) to stop
libnfsidmap from leaking all sorts of private symbols. 

Some of it went to libnfsidmap_plugin.h and some to
libnfsidmap_private.h

Some external packages which offered libnfsidmap plugins were using
these undocumented symbols by copying libnfsidmap_internal.h, so i
reworked the neccessary parts into an API as libnfsidmap_plugin.h and
hid the rest. 

I clearly missed this reference to the file as it didn't generate any
warnings for me, sorry about that.


