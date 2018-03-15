Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50648 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751314AbeCOBn3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Mar 2018 21:43:29 -0400
Date: Wed, 14 Mar 2018 21:43:29 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 07/15] sunrpc: Save remote presentation address in
 svc_xprt for trace events
Message-ID: <20180315014329.GA12150@fieldses.org>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
 <20180313154416.21531.66413.stgit@klimt.1015granger.net>
 <20180314203506.GA7241@fieldses.org>
 <3CA64950-7DC9-418B-8E26-E454A32888AC@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3CA64950-7DC9-418B-8E26-E454A32888AC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 14, 2018 at 08:54:01PM -0400, Chuck Lever wrote:
> "User space" means the C library's printf() implementation. You'd have
> to address this by adding %pI to every possible C library used by Linux
> distributions.
> 
> Also, as mentioned above, we've already used this approach successfully
> in several other similar places.

OK.--b.
