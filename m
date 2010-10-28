Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756450Ab0J1QED (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 12:04:03 -0400
Message-ID: <4CC99EF1.1040503@RedHat.com>
Date: Thu, 28 Oct 2010 12:04:01 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs-utils: add nfs.idmap
References: <4CC6CE30.90105@netapp.com> <4CC70D34.1060600@netapp.com>	 <4CC99463.9000108@RedHat.com>  <4CC9966B.1050103@netapp.com>	 <1288280405.3194.44.camel@heimdal.trondhjem.org>	 <4CC99A9D.10908@RedHat.com> <1288281101.3194.48.camel@heimdal.trondhjem.org>
In-Reply-To: <1288281101.3194.48.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/28/2010 11:51 AM, Trond Myklebust wrote:
> On Thu, 2010-10-28 at 11:45 -0400, Steve Dickson wrote:
>>
>> On 10/28/2010 11:40 AM, Trond Myklebust wrote:
>>>
>>> Let's wait with this until an actual nfs-utils release is available, so
>>> we can also update the 'Documentation/Changes' file with the new minimal
>>> release version number.
>> Just to be clear... the kernel changes will be in the 2.6.37 kernel, correct?
> 
> Yes. They have already been merged into Linus' git tree.
Cool..

> 
> So FWIW, the name nfs.idmap is consistent with the apparent convention
> in /etc/request-key.conf for the cifs.upcall and David's proposal for a
> dns.upcall.
Well those don't live in nfs-utils.. ;-)

steved.
