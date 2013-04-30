Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760692Ab3D3Rcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 13:32:36 -0400
Message-ID: <5180002D.4070002@RedHat.com>
Date: Tue, 30 Apr 2013 13:32:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/17] lnfs: 3.9-rc8 release (take 2)
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>  <20130430155740.GX17268@fieldses.org> <1367338308.4260.18.camel@leira.trondhjem.org>
In-Reply-To: <1367338308.4260.18.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 30/04/13 12:11, Myklebust, Trond wrote:
> On Tue, 2013-04-30 at 11:57 -0400, J. Bruce Fields wrote:
>> On Mon, Apr 29, 2013 at 08:57:02AM -0400, Steve Dickson wrote:
>>> From: Steve Dickson <steved@redhat.com>
>>>
>>> Here is an updated 3.9-rc8 release of
>>> the label NFS patches. 
>>
>> The nfsd patches look mergeable to me (with a few one-line fixes).
>>
>> I'm missing ACKs from Trond and security folks.
>>
>> The merge window is already open, which is late to be queueing up a
>> significant new feature.
>>
>> It might be reasonable if we could get the needed ACKs now, but more
>> likely it looks like 3.11 to me.
> 
> I'm not going to add another 1000 lines of code to the NFS client during
> a merge window. Both Linus and Stephen (Rothwell) would throttle me if I
> did.
> 
> Let's spend this week on reviewing and making sure that all the issues
> that were reported are fixed. I'll cut a new nfs-for-next client branch
> as soon as I'm sure that is the case.
> 
Thanks for the cycles!

steved.
