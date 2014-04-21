Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:38859 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaDUMqx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 08:46:53 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so182340qgd.7
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 05:46:52 -0700 (PDT)
Message-ID: <53551339.5030207@gmail.com>
Date: Mon, 21 Apr 2014 08:46:49 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <20140421064204.GA19231@infradead.org>
In-Reply-To: <20140421064204.GA19231@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/21/2014 02:42 AM, Christoph Hellwig wrote:
> On Thu, Apr 17, 2014 at 05:09:24PM -0400, Anna Schumaker wrote:
>> Questions?  Comments?  Death threats?
> Can you say what tree this is based on or even better publish a git
> tree?  I tried to apply the series to various trees so that I can get a
> better picture for further reviews, but git-am always bailed out
> somewhere.
Oops, sorry!  This is based on Trond's testing branch.  I can work on putting out a git tree later today!

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

