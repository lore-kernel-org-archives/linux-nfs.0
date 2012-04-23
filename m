Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c11o148.mxlogic.net ([208.65.144.81]:54833 "EHLO
	p02c11o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab2DWRn0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 13:43:26 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: Steve Dickson <SteveD@redhat.com>, Jeff Layton <jlayton@redhat.com>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "malahal@us.ibm.com" <malahal@us.ibm.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust@fys.uio.no" <trond.myklebust@fys.uio.no>,
        "rees@umich.edu" <rees@umich.edu>
Date: Mon, 23 Apr 2012 13:43:12 -0400
Subject: RE: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E603@IT-1874.Isys.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
 <1334749927-26138-1-git-send-email-jlayton@redhat.com>
 <20120420104055.511e15bc@tlielax.poochiereds.net>
 <4F91C49D.8070908@RedHat.com>
 <20120420171300.326d6e36@corrin.poochiereds.net>
 <4F956D5C.5050801@RedHat.com>
In-Reply-To: <4F956D5C.5050801@RedHat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The test program runs and expects many, many ENOENTS to be returned.  It just doesn't expect ESTALE to be returned.  It doesn't see ESTALE from local file systems.

To answer a question asked earlier -- the test program does not mimic any particular application behavior, except in the extreme.  It is designed to create as stressful a situation as might be ever seen.

Has anyone explained why the full solution won't work from a technical viewpoint?

	Thanx...

		ps


-----Original Message-----
From: Steve Dickson [mailto:SteveD@redhat.com] 
Sent: Monday, April 23, 2012 10:55 AM
To: Jeff Layton
Cc: linux-fsdevel@vger.kernel.org; linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org; miklos@szeredi.hu; viro@ZenIV.linux.org.uk; hch@infradead.org; michael.brantley@deshaw.com; sven.breuner@itwm.fraunhofer.de; chuck.lever@oracle.com; Peter Staubach; malahal@us.ibm.com; bfields@fieldses.org; trond.myklebust@fys.uio.no; rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors from getattr call



On 04/20/2012 05:13 PM, Jeff Layton wrote:
> On Fri, 20 Apr 2012 16:18:37 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>> On 04/20/2012 10:40 AM, Jeff Layton wrote:
>>> I guess the questions at this point is:
>>>
>>> 1) How representative is Peter's mkdir_test() of a real-world workload?
>> Reading your email I had to wonder the same thing... What application 
>> removes hierarchy of directories in a loop from two different clients?
>> I would suspect not many, if any... esp over NFS... 
>>  
> 
> Peter's test just happens to demonstrate the problem well, but one 
> could envision someone removing a heirarchy of directories on the 
> server while we're trying to do other operations in it. At that point, 
> we can easily end up hitting an ESTALE twice while doing the lookup 
> and returning ESTALE back to userspace.
Just curious, what happens when you run Peter's mkdir_test() on a local file system? Any errors returned? 

I would think removing hierarchy of directories while they are being accessed has to even cause local fs some type of havoc

> 
>>>
>>> 2) if we assume that it is fairly representative of one, how can we 
>>> achieve retrying indefinitely with NFS, or at least some large 
>>> finite amount?
>> The amount of looping would be peer speculation. If the problem can 
>> not be handled by one simple retry I would say we simply pass the 
>> error up to the app... Its an application issue...
>>  
> 
> It's not an application issue. The application just asked the kernel 
> to do an operation on a pathname. The only reason you're getting an 
> ESTALE back in this situation is a shortcoming of the implementation.
> 
> We passed it a pathname after all, not a filehandle. ESTALE really has 
> no place as a return code in that situation...
We'll have to agree to disagree... I think any application that is removing hierarchies of file and directory w/out taking any precautionary locking is a shortcoming of the application implementation.
    
> 
>>>
>>> I have my doubts as to whether it would really be as big a problem 
>>> for other filesystems as Miklos and others have asserted, but I'll 
>>> take their word for it at the moment. What's the best way to contain 
>>> this behavior to just those filesystems that want to retry 
>>> indefinitely when they get an ESTALE? Would we need to go with an 
>>> entirely new ESTALERETRY after all?
>>>
>> Introducing a new errno to handle this problem would be overkill IMHO...
>>
>> If we have to go to the looping approach, I would strong suggest we 
>> make the file systems register for this type of behavior...
>>
> 
> Returning ESTALERETRY would be registering for it in a way and it is 
> somewhat cleaner than having to go all the way back up to the fstype 
> to figure out whether you want to retry it or not.
How would legacy apps handle this new errno, esp if they have logic to take care of ESTALE errors?

steved.
