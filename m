Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:55563 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752234AbdLKPYe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Dec 2017 10:24:34 -0500
Date: Mon, 11 Dec 2017 07:24:18 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Cc: viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, neilb@suse.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5] kernel: make groups_sort calling a responsibility
 group_info allocators
Message-ID: <20171211152418.GA10521@bombadil.infradead.org>
References: <20171211142708.GA23284@bombadil.infradead.org>
 <20171211151420.18655-1-thiago.becker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171211151420.18655-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 11, 2017 at 01:14:20PM -0200, Thiago Rafael Becker wrote:
> In testing, we found that nfsd threads may call set_groups in parallel for
> the same entry cached in auth.unix.gid, racing in the call of groups_sort,
> corrupting the groups for that entry and leading to permission denials for
> the client.
> 
> This patch:
>  - Make groups_sort globally visible.
>  - Move the call to groups_sort to the modifiers of group_info
>  - Remove the call to groups_sort from set_groups
> 
> Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
