Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933640Ab3AIUjv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2013 15:39:51 -0500
Message-ID: <50EDCC85.4020501@redhat.com>
Date: Wed, 09 Jan 2013 15:01:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
To: Dave Kleikamp <dave.kleikamp@oracle.com>
CC: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zach Brown <zab@zabbo.net>,
        "Maxim V. Patlasov" <mpatlasov@parallels.com>,
        Mel Gorman <mgorman@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH V5 22/30] nfs: simplify swap
References: <1357761525-22718-1-git-send-email-dave.kleikamp@oracle.com> <1357761525-22718-23-git-send-email-dave.kleikamp@oracle.com>
In-Reply-To: <1357761525-22718-23-git-send-email-dave.kleikamp@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/09/2013 02:58 PM, Dave Kleikamp wrote:
> swap_writepage can now call nfs's write_iter f_op, eliminating the need to
> implement for the special-case direct_IO a_op. There is no longer a need to
> pass the uio flag through the direct write path.
>
> Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: linux-nfs@vger.kernel.org
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

