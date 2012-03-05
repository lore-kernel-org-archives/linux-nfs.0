Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756494Ab2CELzi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 06:55:38 -0500
Message-ID: <4F54A9BD.4020702@RedHat.com>
Date: Mon, 05 Mar 2012 06:55:41 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>    <4F2BC1C0.8070900@panasas.com> <20120203231623.442fefde@notabene.brown>    <20120203142945.GA31805@us.ibm.com> <4F2E620F.5090100@panasas.com>    <20120207204401.GA31752@us.ibm.com> <4F511B21.1020907@RedHat.com>    <20120302192758.GA28389@us.ibm.com> <4F513429.1050209@RedHat.com>    <20120302220108.GA17119@us.ibm.com> <4F525741.2060404@RedHat.com>   <1330801976.2781.19.camel@lade.trondhjem.org>  <4F53ED3C.2020209@RedHat.com>  <4F53F39E.9050802@RedHat.com>  <1330903600.14357.10.camel@lade.trondhjem.org>  <4F5402E4.4030506@RedHat.com> <1330913047.14357.19.camel@lade.trondhjem.org>
In-Reply-To: <1330913047.14357.19.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/04/2012 09:04 PM, Myklebust, Trond wrote:
> On Sun, 2012-03-04 at 19:03 -0500, Steve Dickson wrote:
>>
>> On 03/04/2012 06:26 PM, Myklebust, Trond wrote:
>>> On Sun, 2012-03-04 at 17:58 -0500, Steve Dickson wrote:
>>>> So to restate... this normalizing of the path names (aka striping 
>>>> multiple slashes or added the leading slash) only need to occur on 
>>>> (successful) v4 mounts... Although the former would not be an 
>>>> problem with v2/v3 mounts but its not needed....
>>>
>>> Normalising for v4 only is OK as far as I'm concerned, but as an
>>> alternative: is there any reason why you can't just grab the path from
>>> '/proc/mounts'?
>>>
>> Well in some distros /etc/mtab is symbolically linked to /proc/mounts
>> so this problem does not exist. But from what I've been told not
>> all distros do that. Plus being backward compatible with older 
>> release of distro is a good thing... IMHO...
> 
> Which is why I'm asking you if you can't copy from /proc/mounts. Distros
> which already have a symlink betweek /etc/mtab and /proc/mounts don't
> have any of these problems...
> 
Personally I think it simpler to just normalize the paths before 
writing it to the mtab verses open up and searching /proc/mounts
esp on client where there is large amount of mounts...  

steved.
