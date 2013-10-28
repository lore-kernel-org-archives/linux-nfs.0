Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:16429 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab3J1VFR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 17:05:17 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [nfsv4] XATTRs in NFS?
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131028210247.GM31322@fieldses.org>
Date: Mon, 28 Oct 2013 17:04:57 -0400
Cc: "Haynes, Tom" <Tom.Haynes@netapp.com>, Marc Eshel <eshel@us.ibm.com>,
        Spencer Shepler <spencer.shepler@gmail.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Steve Dickson <SteveD@redhat.com>,
        "nfsv4@ietf.org nfsv4@ietf.org" <nfsv4@ietf.org>,
        Ric Wheeler <ric.wheeler@usenix.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>
Message-Id: <6AB20096-3993-47DD-AB58-2CD25F8A75D8@oracle.com>
References: <1382920068.6932.46.camel@heisenberg.scientia.net> <2E672741-FE4F-4287-8D00-B7634A71709E@netapp.com> <526E8562.3040809@redhat.com> <1382976943.8774.10.camel@heisenberg.scientia.net> <FD29488A-348B-48BA-9B1D-4ACF997BC794@netapp.com> <526EA65A.7010209@redhat.com> <20131028180838.GG31322@fieldses.org> <526EAD86.6090507@redhat.com> <OFA4C7B613.86F16AC7-ON88257C12.006FE486-88257C12.0071EE79@us.ibm.com> <C2C70C2E-100E-40BD-A919-A4F649077059@netapp.com> <20131028210247.GM31322@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2013, at 5:02 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Oct 28, 2013 at 08:55:06PM +0000, Haynes, Tom wrote:
>> 
>> On Oct 28, 2013, at 1:44 PM, Marc Eshel <eshel@us.ibm.com> wrote:
>> 
>>> Hi Spencer, 
>>> Is it still possible to get on the agenda fir IETF 88, I just got approval 
>>> to travel. We can use about 15 minutes, or what ever is available to 
>>> discussion the future of named attributes in NFS. The two main questions 
>>> that we need answer are: 
>>> 1. Do we need them? what applications use them and how. 
>>> 2. Can we have a more simple model that handles just user attributes.
>>> 
>>> Input is welcome to help me make the case at the meeting.
>>> 
>>> Thanks, Marc.
>>> 
>> 
>> 
>> Be sure to call out why they currently do or do not work.
> 
> And we also need to keep clear the distinctions between:
> 
> 	- NFSv4 named attributes/streams/forks and "extended attributes"
> 	  as implemented in Linux and elsewhere.
> 	- user.* xattrs and "back-door ioctls".
> 
> (Your description above seems to confuse named attributes and Linux
> extended attributes.)

I wonder if we will have a balanced discussion next week.  The people who seem to know the most about these issues on Linux will not be attending.  Perhaps it would be better to start this discussion on the mailing list instead.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



