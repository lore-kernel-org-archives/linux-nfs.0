Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:38337 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbcCCNuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2016 08:50:44 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 7F1E128037D
	for <linux-nfs@vger.kernel.org>; Thu,  3 Mar 2016 14:50:41 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 72E2C1698
	for <linux-nfs@vger.kernel.org>; Thu,  3 Mar 2016 14:50:41 +0100 (MET)
Date: Thu, 3 Mar 2016 14:50:40 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Message-ID: <1286720010.2387716.1457013040842.JavaMail.zimbra@desy.de>
In-Reply-To: <20160302163746.GA25527@infradead.org>
References: <1456920492-22533-1-git-send-email-tigran.mkrtchyan@desy.de> <1456927079-4788-1-git-send-email-tigran.mkrtchyan@desy.de> <20160302163746.GA25527@infradead.org>
Subject: Re: [PATCH] pnfs  support servers with multiple layout types
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Christoph Hellwig" <hch@infradead.org>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>, linux-nfs@vger.kernel.org
> Sent: Wednesday, March 2, 2016 5:37:46 PM
> Subject: Re: [PATCH] pnfs  support servers with multiple layout types

>> +	for(i = 0; i < num && i < NFS_MAX_LAYOUT_TYPES; i++)
>> +		layouttype[i] = be32_to_cpup(p++);
> 
> Can we use a bitmap and do something like
> 
>	layouttype |= (1 << be32_to_cpup(p++));
> 

Sorry, took me a bit longer to understand what you actually was saying.
But still won't work, as we will loose the order of supported layouts.

To make it working, we can add a mount option for preferred layout:

mount -o preferred_layout=nfs4_file,vers=4.1 ....

Then client will try preferred first, and if it's not provided, 
then will go through the bitmask and pick first working.

Shall I do that? Trond, any comments?

Tigran.

> that's what I did for my unsubmitted patches to submit multiple
> layouttypes in the Linux server..
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
