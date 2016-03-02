Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:53199 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbcCBTWe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2016 14:22:34 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id BA0232807D9
	for <linux-nfs@vger.kernel.org>; Wed,  2 Mar 2016 20:22:31 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id A905A1408E
	for <linux-nfs@vger.kernel.org>; Wed,  2 Mar 2016 20:22:31 +0100 (MET)
Date: Wed, 2 Mar 2016 20:22:30 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Message-ID: <369422940.2178430.1456946550539.JavaMail.zimbra@desy.de>
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

Sure, if we describe in spec that layout type must be power of two
and max value is 32.

Tigran.

> that's what I did for my unsubmitted patches to submit multiple
> layouttypes in the Linux server..
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
