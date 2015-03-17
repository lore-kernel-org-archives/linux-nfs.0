Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:27288 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493AbbCQMa1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 08:30:27 -0400
Message-ID: <55081E60.9010200@Netapp.com>
Date: Tue, 17 Mar 2015 08:30:24 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/5] NFS: Add READ_PLUS support
References: <1426540666-31896-1-git-send-email-Anna.Schumaker@Netapp.com> <20150317103145.GA27478@infradead.org>
In-Reply-To: <20150317103145.GA27478@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/17/2015 06:31 AM, Christoph Hellwig wrote:
> On Mon, Mar 16, 2015 at 05:17:41PM -0400, Anna Schumaker wrote:
>>    Test     |   v4.1    | no READ_PLUS |  READ_PLUS
>> ---------------------------------------------------
>> generic/013 | 135s      |    143s      |    123s
>> generic/075 |   4s      |     11s      |      4s
>> generic/091 |   9s      |     16s      |     15s
>> generic/112 |   4s      |      7s      |      6s
>> generic/127 |  62s      |    117s      |    114s
>> generic/213 | [not run] |      1s      |      1s
>> generic/214 | [not run] |      0s      |      0s
>> generic/228 | [not run] |      1s      |      2s
>> generic/236 |   1s      |      1s      |      1s
>> generic/263 |   4s      |      6s      |      8s
>> generic/285 |   0s      |      1s      |      3s
>> generic/315 | [not run] |      2s      |      1s
>> ---------------------------------------------------
>> Total       |  3:47.47  |    5:11.85   |  4:43.77
> 
> So why is 4.2 generally slower than 4.1?  I guess we really should look
> into that first.
> 

I did!  There are several tests that run on v4.1 but skip over fallocate() calls.  v4.2 no longer skips these tests.
