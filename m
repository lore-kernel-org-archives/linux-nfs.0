Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12160 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab1BPP4b convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2011 10:56:31 -0500
Subject: Re: [PATCH 11/16] pnfs: wave 3: generic read
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <4D5BF2B5.2020502@panasas.com>
Date: Wed, 16 Feb 2011 10:56:13 -0500
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@citi.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>, Fred Isaman <iisaman@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mike Sager <sager@netapp.com>, Mingyang Guo <guomingyang@nrchpc.ac.cn>,
        Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Message-Id: <4CBB4CED-DCE5-465F-B3EF-3E5EC722B2DC@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>	 <1297711116-3139-12-git-send-email-andros@netapp.com>	 <4D5B4192.4090107@panasas.com>	 <21F5A956-5830-4BB1-8F91-92C3121510BD@netapp.com> <1297868955.6596.24.camel@heimdal.trondhjem.org> <4D5BF2B5.2020502@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 16, 2011, at 10:52 AM, Benny Halevy wrote:

> On 2011-02-16 10:09, Trond Myklebust wrote:
>> On Wed, 2011-02-16 at 09:53 -0500, Andy Adamson wrote: 
>>> On Feb 15, 2011, at 10:16 PM, Benny Halevy wrote:
>>> 
>>>> On 2011-02-14 14:18, andros@netapp.com wrote:
>>>>> From: Andy Adamson <andros@netapp.com>
>>>> 
>>>> Andy, taking into account the many contributors to this patch
>>>> the author should be "The pNFS Team" IMO.
>>> 
>>> The author can't be "The pNFS Team".  Somebody needs to be the author. I asked for volunteers and said I would be the default. Do you want to be the author?
>> 
>> Right. Patches authored by 'The pNFS Team' will be rejected, as
>> discussed in Hopkinton last autumn.
>> 
> 
> OK. I'm not the original author so I can't claim authorship for this patch.
> FWIW, The earliest record I have in my tree for the earliest versions of this code is
> authored by Andy an Mike Sager...

Thanks for looking Benny. I'll remain the author.

-->Andy

> 
> Benny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

