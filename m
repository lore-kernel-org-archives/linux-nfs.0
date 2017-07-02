Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38153 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751606AbdGBIxz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jul 2017 04:53:55 -0400
Date: Sun, 2 Jul 2017 10:53:54 +0200
From: Greg KH <greg@kroah.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Stable request to fix a reference leak and list
 corruption
Message-ID: <20170702085354.GA20685@kroah.com>
References: <20170628144758.12225-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170628144758.12225-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 28, 2017 at 10:47:57AM -0400, Trond Myklebust wrote:
> Hi Greg,
> 
> Could we please queue up the following patch as a stable fix for
> commit a974deee47? It needs to be applied to v4.10 and older.

Now applied, thanks.

greg k-h
