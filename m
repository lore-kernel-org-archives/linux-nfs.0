Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:58201 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaDUNNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:13:44 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so3878589iec.4
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 06:13:44 -0700 (PDT)
Message-ID: <1398086021.2891.10.camel@leira.trondhjem.org>
Subject: Re: [PATCH 30/70] NFSd: Replace delegation->dl_file with the
 dl_stid.sc_file
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 21 Apr 2014 09:13:41 -0400
In-Reply-To: <20140419144030.GC25682@infradead.org>
References: <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
	 <20140419144030.GC25682@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-04-19 at 07:40 -0700, Christoph Hellwig wrote:
> Instead of adding a mostly unused file field to the stid in the previous
> patch and starting to use it here I'd recommend merging the two patches.
> 
Ack and done.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


