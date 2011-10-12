Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40217 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab1JLQBV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Oct 2011 12:01:21 -0400
Message-ID: <4E95B9B9.5020501@panasas.com>
Date: Wed, 12 Oct 2011 18:00:57 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Fred Isaman <iisaman@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH 1/1] Prevent 3.0 from crashing if it receives a partial
 layout
References: <1316544755-31845-1-git-send-email-iisaman@netapp.com> <4E79B39B.1080102@panasas.com> <CADnza47=3Q53=DO=KMdeu_snuQ-q3RV2KshfMOwXL6o+BcYaLw@mail.gmail.com>
In-Reply-To: <CADnza47=3Q53=DO=KMdeu_snuQ-q3RV2KshfMOwXL6o+BcYaLw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/21/2011 04:11 PM, Fred Isaman wrote:
>>
>> Do you know of any plans/timetables to support segments in the files-layout-driver?
>> Both objects and blocks do support it.
>> Is there some missing generic infrastructure needed or its only LD stuff?
>>
> 
> I plan on having something to test at BAT.
> 
> Fred
> 

Hi Fred

any news on the files-layout segments support? Do you have an RFC
quality code that we can play around with?

Thanks
Boaz
