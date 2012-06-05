Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46083 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab2FEPBm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 11:01:42 -0400
Message-ID: <4FCE1F47.7090303@panasas.com>
Date: Tue, 5 Jun 2012 18:01:27 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4.1 do not call LAYOUTRETURN when there are no
 legs
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <4FCA9B0E.5070304@panasas.com> <AAE6059A-E7A5-4377-A68A-AC6CB90C1666@netapp.com>
In-Reply-To: <AAE6059A-E7A5-4377-A68A-AC6CB90C1666@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2012 04:36 PM, Adamson, Andy wrote:

> 
> On Jun 2, 2012, at 7:00 PM, Boaz Harrosh wrote:
> 
>> On 06/01/2012 08:19 PM, andros@netapp.com wrote:
>>
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>
>>
>> I wish you would send your patches preceded with a [PATCHSET 0/x]
>> That gives us a short summery and a little background on its motivation.
> 

> I often do. These patches actually stand alone so I didn't this
> time.
> 
> This patch is totally explained by the patch title, patch comments,
> and in-line comments. With out this patch, we can end up sending a
> LAYOUTRETURN with no layout segments that need to be returned! Why?
> because as noted in the patch comments, mark_matching_lsegs_invalid
> does not indicate when the plh_segs list is empty…etc. When? well, as
> noted in the in-line code comments, when the pnfs_layout_hdr has an
> empty plh_segs which an occur when a LAYOUTGET fails, or when
> LAYOUTGET succeeded, but the deviceid is marked invalid
> 


Yes I noticed that the comment was very good. The in-code comment does
not replace the commit title/message. I would prefer it repeated also
in the patch text and/or in the cover-letter. Just to ease on the threshold
to entry.

> What else is there to say?!
> 
> I guess I can add the --cover-letter to the git format-patch and
> cut/paste to it.
> 


I'm not sure what you meant. But yes exactly ;-)

> -->Andy
> 
>>


Thanks
Boaz
