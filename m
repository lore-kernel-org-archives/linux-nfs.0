Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11690 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab1BPPwW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2011 10:52:22 -0500
Message-ID: <4D5BF2B5.2020502@panasas.com>
Date: Wed, 16 Feb 2011 10:52:21 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Andy Adamson <andros@netapp.com>
CC: linux-nfs@vger.kernel.org, Andy Adamson <andros@citi.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>, Fred Isaman <iisaman@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mike Sager <sager@netapp.com>, Mingyang Guo <guomingyang@nrchpc.ac.cn>,
        Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: Re: [PATCH 11/16] pnfs: wave 3: generic read
References: <1297711116-3139-1-git-send-email-andros@netapp.com>	 <1297711116-3139-12-git-send-email-andros@netapp.com>	 <4D5B4192.4090107@panasas.com>	 <21F5A956-5830-4BB1-8F91-92C3121510BD@netapp.com> <1297868955.6596.24.camel@heimdal.trondhjem.org>
In-Reply-To: <1297868955.6596.24.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-16 10:09, Trond Myklebust wrote:
> On Wed, 2011-02-16 at 09:53 -0500, Andy Adamson wrote: 
>> On Feb 15, 2011, at 10:16 PM, Benny Halevy wrote:
>>
>>> On 2011-02-14 14:18, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Andy, taking into account the many contributors to this patch
>>> the author should be "The pNFS Team" IMO.
>>
>> The author can't be "The pNFS Team".  Somebody needs to be the author. I asked for volunteers and said I would be the default. Do you want to be the author?
> 
> Right. Patches authored by 'The pNFS Team' will be rejected, as
> discussed in Hopkinton last autumn.
> 

OK. I'm not the original author so I can't claim authorship for this patch.
FWIW, The earliest record I have in my tree for the earliest versions of this code is
authored by Andy an Mike Sager...

Benny
