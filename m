Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:60569 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbcHTGTT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Aug 2016 02:19:19 -0400
Date: Fri, 19 Aug 2016 23:19:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: andros@netapp.com
Cc: trondmy.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version-2 01/12] fs: Don't copy beyond the end of the file
Message-ID: <20160820061910.GA14801@infradead.org>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
 <1471627512-4102-2-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1471627512-4102-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 19, 2016 at 01:25:01PM -0400, andros@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/read_write.c | 3 +++

Please also send a regression test for this and add it to xfstests,
thanks.
