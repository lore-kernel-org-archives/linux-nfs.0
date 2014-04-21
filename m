Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:64870 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaDUNIO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:08:14 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so1734691igq.10
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 06:08:14 -0700 (PDT)
Message-ID: <1398085692.2891.9.camel@leira.trondhjem.org>
Subject: Re: [PATCH 21/70] NFSd: Get rid of the lockowner_ino_hashtbl
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 21 Apr 2014 09:08:12 -0400
In-Reply-To: <20140419143804.GB25682@infradead.org>
References: <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
	 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
	 <20140419143804.GB25682@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2014-04-19 at 07:38 -0700, Christoph Hellwig wrote:
> On Fri, Apr 18, 2014 at 02:44:15PM -0400, Trond Myklebust wrote:
> > It is no longer used.
> 
> I think this should be folded into the previous patch, which is the
> reason why it is unused now.
> 

Ack and done...
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


