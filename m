Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.onthe.net.au ([203.22.196.249]:48709 "EHLO
	smtp1.onthe.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab1LAFc7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 00:32:59 -0500
Date: Thu, 1 Dec 2011 16:32:55 +1100
From: Chris Dunlop <chris@onthe.net.au>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer@onthe.net.au:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Petr Vandrovec <petr@vandrovec.name>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111201053255.GA6831@onthe.net.au>
References: <20111130071319.GA16711@onthe.net.au>
 <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
 <24960.1322643283@redhat.com>
 <20111201004709.GA26085@onthe.net.au>
 <4ED6E4EF.7050101@oracle.com>
 <20111201033346.GA1049@onthe.net.au>
 <4ED6FA2C.7010005@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ED6FA2C.7010005@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 30, 2011 at 09:53:16PM -0600, Dave Kleikamp wrote:
> On 11/30/2011 09:33 PM, Chris Dunlop wrote:
>> On Wed, Nov 30, 2011 at 08:22:39PM -0600, Dave Kleikamp wrote:
>>> On 11/30/2011 06:47 PM, Chris Dunlop wrote:
>>>>> It's also worth printing a message - this *is* a kernel bug of some description
>>>>> if it happens.
>>>>
>>>> Like the below?  This covers the d_revalidate for 9p, afs, coda,
>>>> hfs, ncpfs, proc, sysfs.
>>>>
>>>> Note:  jfs isn't susceptible to this problem, but the resolution
>>>> doesn't look like the other file systems, and from the comment
>>>> I'm not sure if the problem was really understood and if it's
>>>> doing the right thing:
>>>
>>> This code, as well as the comments, were copied from vfat. It seems
>>> reasonable for case-insensitive but case-preserving behavior (not jfs's
>>> default). The safe thing is to drop the negative dentry if we don't know
>>> the operation.
>> 
>> In that case, it looks like the thing to do might be to add the
>> "protection" to the start of jfs_ci_revaliate(), per how the
>> original has been changed in vfat:
> 
> The LOOKUP_RCU check had previously been there, but Al Viro removed it:
> 
> commit 5c0f360b083fb33d05d1bff4b138b82d715eb419
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Sat Jun 25 21:41:09 2011 -0400
> 
>     jfs_ci_revalidate() is safe from RCU mode
> 
> I'm not sure what it takes to be "safe", but this is a simple function
> that doesn't block, take locks, or do much of anything. You shouldn't
> need to do anything with jfs.
> 
> Shaggy

OK, thanks.

Chris
