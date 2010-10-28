Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758467Ab0J1Ppf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 11:45:35 -0400
Message-ID: <4CC99A9D.10908@RedHat.com>
Date: Thu, 28 Oct 2010 11:45:33 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-utils: add nfs.idmap
References: <4CC6CE30.90105@netapp.com> <4CC70D34.1060600@netapp.com>	 <4CC99463.9000108@RedHat.com>  <4CC9966B.1050103@netapp.com> <1288280405.3194.44.camel@heimdal.trondhjem.org>
In-Reply-To: <1288280405.3194.44.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/28/2010 11:40 AM, Trond Myklebust wrote:
> On Thu, 2010-10-28 at 11:27 -0400, Bryan Schumaker wrote:
>> On 10/28/2010 11:18 AM, Steve Dickson wrote:
>>> Hey Bryan,
>>>
>>> A couple nits.... which I will be more than willing to take of... 
>>>
>>> 1) I would like to change the binary name from nfs.idmap to nfsidmap
>>>    which is consistent with how the rest of the binaries are named.
>>>    (i.e. binary names generally don't have any '.' or '-' in them)
>>>    
>>> 2) Change the source directory from utils/nfs.idmap to 
>>>    utils/idmap which again makes it consistent with what
>>>    is already there. 
>>
>> These both sounds reasonable to me.  I'll make a patch to modify the kernel documentation to reflect this.
>>>
> 
> We just sent in one patch to change the name in the kernel docs, now the
> name is changing again?
I'll take the blame for that... I should have gotten into the 
conversation  earlier... sorry about that...

> 
> Let's wait with this until an actual nfs-utils release is available, so
> we can also update the 'Documentation/Changes' file with the new minimal
> release version number.
Just to be clear... the kernel changes will be in the 2.6.37 kernel, correct?

steved.
