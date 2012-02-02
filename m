Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43676 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755409Ab2BBTAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Feb 2012 14:00:44 -0500
Message-ID: <4F2ADD58.9080000@netapp.com>
Date: Thu, 02 Feb 2012 14:00:40 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: dont allow minorversion= opt when vers != 4
References: <1328123201-894-1-git-send-email-dros@netapp.com> <4F29C04B.8020703@panasas.com> <BD47F92C-6031-4F3F-A715-8275C7399717@netapp.com> <4F2A94FA.30603@netapp.com> <F797D932-12F4-4063-B46D-0410385A911F@netapp.com>
In-Reply-To: <F797D932-12F4-4063-B46D-0410385A911F@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/02/12 12:03, Adamson, Dros wrote:

> 
> On Feb 2, 2012, at 8:51 AM, Bryan Schumaker wrote:
> 
>> On 02/01/12 18:07, Adamson, Dros wrote:
>>
>>> On Feb 1, 2012, at 5:44 PM, Boaz Harrosh wrote:
>>>
>>>> On 02/01/2012 09:06 PM, Weston Andros Adamson wrote:
>>>>> Don't allow invalid 'vers' and 'minorversion' combinations in mount options,
>>>>> such as "vers=3,minorversion=1".
>>>>>
>>>>
>>>> Just my $0.017 I don't see the point in this. 
>>>>
>>>> If vers==3 then minorversion is ignored, just like today.
>>>> What kind  of extra protection does it buy us?
>>>
>>> No, minorversion is not ignored when vers=3.  
>>
>>
>> But after mounting, does setting vers=3, minorversion=1 cause any change in NFS v3 behavior?
>>
> 
> No it doesn't.  Past the parsing of options, minorversion is ignored for versions other than 4.
> 
> I just don't understand how anyone can have problem with this patch.  Why would we want to validate minorversion in some cases, but not all cases?  How would this patch be a bad thing?
> 

I don't have a problem with the patch, it makes sense that we shouldn't confuse developers or users.  I was just curious if there was a spot where we had "if minor_version == 1: do_something()" without checking for major_version == 4.

- Bryan

> It's about usability -- if this can confuse NFS developers, how are end users going to handle it?
> 
> -dros


