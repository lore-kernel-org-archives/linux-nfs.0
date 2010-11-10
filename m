Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:46457 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756047Ab0KJN4N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 08:56:13 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 3557C1735
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 14:56:12 +0100 (MET)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 2ECC213EBF
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 14:56:11 +0100 (MET)
Message-ID: <4CDAA47C.2040705@desy.de>
Date: Wed, 10 Nov 2010 14:56:12 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: kernel panic with 2.6.37-rc1 +pnfs
References: <4CD95DB5.2030006@desy.de> <4CDA74F5.90700@panasas.com>
In-Reply-To: <4CDA74F5.90700@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> I guess that ff8b16d vmstat: fix offset calculation on void*
> could fix this problem.  It's currently in Linus's master branch
> and he hasn't released 2.6.37-rc2 yet.
> Can you please try to reproduce the problem you saw with this patch?

Yes, that was the fix! I will update our cluster and re-run productions jobs
with new kernel.

Thanks,
   TIgran.

> 
> Benny
