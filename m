Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:40370 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928AbbKLSan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2015 13:30:43 -0500
Date: Thu, 12 Nov 2015 11:30:40 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: [PATCH] svcrdma: Do not send XDR roundup bytes for a write
 chunk
Message-ID: <20151112183040.GC25178@obsidianresearch.com>
References: <20151112144433.13507.34603.stgit@klimt.1015granger.net>
 <648A8847-9836-42EC-9D62-77C01C6E9ACF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <648A8847-9836-42EC-9D62-77C01C6E9ACF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 12, 2015 at 09:47:13AM -0500, Chuck Lever wrote:
> I wish git send-mail had an address book. I’m really tired
> of misspelling the to/cc addresses on patches.

It does:

CONFIGURATION
       sendemail.aliasesfile
           To avoid typing long email addresses, point this to one or more email aliases files. You must also supply
           sendemail.aliasfiletype.

       sendemail.aliasfiletype
           Format of the file(s) specified in sendemail.aliasesfile. Must be one of mutt, mailrc, pine, elm, or gnus.

Jason
