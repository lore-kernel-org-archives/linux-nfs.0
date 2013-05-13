Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642Ab3EMRbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 May 2013 13:31:08 -0400
Message-ID: <51912356.4080100@RedHat.com>
Date: Mon, 13 May 2013 13:31:02 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.11 patches
References: <20130513152312.GB1931@fieldses.org> <1368458889.3563.7.camel@leira.trondhjem.org>
In-Reply-To: <1368458889.3563.7.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 13/05/13 11:28, Myklebust, Trond wrote:
> On Mon, 2013-05-13 at 11:23 -0400, J. Bruce Fields wrote:
>> I've added a labeled-nfs-common branch at
>>
>> 	git://linux-nfs.org/~bfields/linux.git labeled-nfs-common
>>
>> with 3.10-rc1 + the one labeled NFS patch shared by client and server
>> (with just some protocol constants).
>>
>> So we can all work on top of that if we want.
> 
> OK. I've pushed out a 'labeled-nfs' branch for the client side that is
> based upon the above branch.
Momentary I will be posting the  3.10-rc1 forward port.

> 
> Has James added the security patches to a public branch that we can pull
> yet?
> 
No and he does not plan to... because "It won't be functional without the security 
subsystem patches, so they should all be in his tree." Meaning your tree...

steved.
