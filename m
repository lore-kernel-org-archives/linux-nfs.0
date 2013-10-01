Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:37132 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab3JABPo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 21:15:44 -0400
Message-ID: <524A2225.8020000@panasas.com>
Date: Mon, 30 Sep 2013 18:15:17 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Benny Halevy <bhalevy@primarydata.com>
CC: "J. Bruce Fields" <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v0 20/49] pnfsd: filelayout: layout encoding
References: <52447EA0.7070004@primarydata.com> <1380220872-13597-1-git-send-email-bhalevy@primarydata.com> <20130929121639.GD21083@infradead.org>
In-Reply-To: <20130929121639.GD21083@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/29/2013 05:16 AM, Christoph Hellwig wrote:
> The actual XDR encoding doesn't have business being under fs/exportfs
> and should be in the NFSD code itself.
> 

This is so FSs will not depend on NFSD. Though the actual implementtation
could be done via a vector that gets set at NFSD load.
 
Though I would like to keep it here, because I have a patchset
which implements pNFS without NFSD at all. It enables a set
of IOCTLs or syscalls and uses the same exact FS interface
introduced here but sends the info to a user mode server.

Though again it can be just its own library without regard
to exportfs at all. linked in by any user code that needs
it.

Cheers
Boaz

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

