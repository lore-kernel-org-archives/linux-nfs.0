Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbbGNOfR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 10:35:17 -0400
Message-ID: <55A51E24.6000502@RedHat.com>
Date: Tue, 14 Jul 2015 10:35:16 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Kinglong Mee <kinglongmee@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] blkmapd: Skip the SCSI ID if data length is zero
References: <55A2FEE4.6030201@gmail.com> <20150713064216.GA31842@infradead.org> <55A375A1.4000800@gmail.com> <20150713090142.GA28557@infradead.org> <55A380A5.20009@gmail.com> <55A38C1C.3030600@gmail.com> <20150714071537.GB31117@infradead.org>
In-Reply-To: <20150714071537.GB31117@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/14/2015 03:15 AM, Christoph Hellwig wrote:
>> +		/* Needs an SCSI ID with unique date not zero length */
>> +		if (!dev_id->len)
>> +			continue;
> 
> That explains what the code does, not why it does so.
> 
> How about:
> 
> 		/*
> 		 * Some buggy targets (e.g. VMWare) export zero length
> 		 * EVPD pages, skip them to not confuse the device id
> 		 * cache.
> 		 */
> 
I'm not a big fan of calling out vendors in comments. I'm thinking
dropping the "buggy" and "(e.g. VMWare)" would be appropriated.

steved.
 
