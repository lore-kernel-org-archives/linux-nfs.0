Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:23362 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755553Ab3JXP1p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 11:27:45 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Date: Thu, 24 Oct 2013 15:27:43 +0000
Message-ID: <48A37C8F-2E72-4865-A1EC-A430807F420A@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382627225.899.76.camel@willson.li.ssimo.org>
 <1382627496.6430.2.camel@leira.trondhjem.org>
 <1382627770.899.79.camel@willson.li.ssimo.org>
In-Reply-To: <1382627770.899.79.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 24, 2013, at 4:16 PM, Simo Sorce <simo@redhat.com>
 wrote:

> On Thu, 2013-10-24 at 15:11 +0000, Myklebust, Trond wrote:
>> On Thu, 2013-10-24 at 11:07 -0400, Simo Sorce wrote:
>> 
>>> Because the filesystem can do that when multiple applications are
>>> involved without having to change them all to talk to each other and
>>> invent custom protocol all the time just to keep some additional
>>> metadata associated to a file..
>>> 
>> It's still a custom protocol. The applications need to agree on a data
>> format and store it somewhere. The portable way to do this is to write
>> an application library that they can link to.
> 
> Perhaps I was unclear, you are never going to see that custom library
> linked into the 'mv' command.
> 

Why should my mv need to link into such a library?

> So your approach makes little sense if the object is to maintain data
> coherent when people need to handle files from random applications and
> scripts and general system maintenance.
> 

See the earlier admonition: store data that needs to be kept together either in the same file, or in the same directory. Use a library when different applications need to access the same data.

> The data may be relevant only to a specific application.
> 
> I am not saying you *have* to implement xattrs support, just saying that
> it is not a mere 'applications should synchronize data themselves'
> problem.

_portable_ applications do not use xattrs. They are a Linuxism that is not described by either POSIX or any other similar standard.

Trond