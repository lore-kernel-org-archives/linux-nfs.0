From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] nfs-utils: add testing infrastructure to nfs-utils (try #3)
Date: Wed, 6 Jan 2010 15:22:55 -0500
Message-ID: <77AF3FCC-A3BF-49C6-BF21-B1C38FD867AB@oracle.com>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com> <20100106191706.GE6612@fieldses.org> <20100106144247.18dc10de@tlielax.poochiereds.net> <20100106195819.GH6612@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17857 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241Ab0AFUYS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 15:24:18 -0500
In-Reply-To: <20100106195819.GH6612@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 6, 2010, at 2:58 PM, J. Bruce Fields wrote:
> On Wed, Jan 06, 2010 at 02:42:47PM -0500, Jeff Layton wrote:
>> On Wed, 6 Jan 2010 14:17:06 -0500
>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>
>>> This probably just shows I'm not reading carefully, but: are you
>>> requiring root, and messing with their existing nfs configuration at
>>> all?
>>>
>>> For the export stuff it would also be great to have some tests  
>>> that set
>>> up a few dummy exports (using tmpfs?) and tried to mount them  
>>> (just over
>>> loopback), but I'd be afraid someone would try to run "make check"  
>>> on
>>> their production server.  So I'm not sure where to put that kind of
>>> test.
>>>
>>
>> The script I have so far doesn't check for root privs, but it won't
>> work unless you have them since statd will fail to start. statd
>> currently requires root privs to start though it does drop them soon
>> afterward.
>>
>> I'm open to suggestions on changing this as I'm not crazy about that
>> either.
>
> My feeling is that it will be hard to find a realistic way to test
> everything without having root and taking over the machine to some
> degree.
>
> Just so long as the user understands whether it needs to be run as  
> root,
> whether it's safe to be run on a host connected to the network,  
> etc....
> I don't know if 'make check' is the right ui for that.

I hear your concern.  I would have some trepidation about using "make  
check" if I knew it required root, and was not familiar enough with  
the code to know exactly what it does.

My original idea was that this facility would be a set of smaller unit  
tests.  Since some of statd/sm-notify is now broken out into  
libraries, I think that makes it a little easier to craft targeted  
tests that don't require a full-blown statd running to carry out (Of  
course, that's speculation; I could be wrong, and Jeff has kindly set  
up the code for us to test this theory!).

The old code has a statd simulator that doesn't require root, and uses  
its own RPC program number.  It might be reasonable to adopt that  
approach instead of using the real statd, for some test cases.

Another way to set this up might be to use a container, or run it  
under a lightweight kvm.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



