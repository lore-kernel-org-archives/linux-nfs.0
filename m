Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:46408 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdLIRUJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Dec 2017 12:20:09 -0500
Date: Sat, 9 Dec 2017 09:20:07 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Cc: linux-fsdevel@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-nfs@vger.kernel.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH 0/3 v3] Move groups_sort outisde of set_groups (fwd)
Message-ID: <20171209172007.GA20973@bombadil.infradead.org>
References: <alpine.LFD.2.21.1712081000360.13749@tbecker-rhat>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LFD.2.21.1712081000360.13749@tbecker-rhat>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 08, 2017 at 10:30:24AM -0200, Thiago Rafael Becker wrote:
> Hello,
> 
> People in linux-nfs seem happy with this patch set. I'm looking for comments
> from VFS and s390 maintainers.

Well ... you sent a response to your 2/3 saying "please ignore", and I don't see a replacement 2/3.

Also, there's no need to split this up into three separate patches.
It's small enough to all be done as one.
