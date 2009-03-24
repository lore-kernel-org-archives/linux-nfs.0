From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: Removed a number of warn_unused_result warnings
Date: Tue, 24 Mar 2009 13:36:47 -0400
Message-ID: <49C91A2F.90501@RedHat.com>
References: <49C797C6.8030102@RedHat.com> <654687AD-E743-45A4-99B1-BBBEAA5D915D@oracle.com> <49C910C3.2090700@RedHat.com> <74BEB80C-976E-48D5-B356-16534F210209@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57606 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260AbZCXRjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Mar 2009 13:39:45 -0400
In-Reply-To: <74BEB80C-976E-48D5-B356-16534F210209@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Mar 24, 2009, at 12:56 PM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>> I've actually already addressed all the cases you found under
>>> utils/statd/... my re-writes replace both nsm_log() and note() with
>>> calls to xlog(), and add return code checking to the write(2) calls.
>> Sorry about that... but I already did the commit... since I wanted to
>> get some testing asap..  so go head and send me the parts I broke
>> and I will do the forward port...
> 
> This is all only in my tree, and I haven't finished it yet, so I will
> have to do the fix-ups myself.
Again, sorry about that.. 

> 
>>> Also, note that you can use the "%m" format specifier to generate the
>>> same string you get from strerror(errno).
>> Yeah.. I knew that... but I thought there some memory corruption
>> or service denial issue with using "%m" so I've always stuck
>> with '%d (%s)'.
> 
> I use %m routinely.  What exactly are these issues?
It was a while ago... but I seem to remember there as an issue
with one of the daemons using '%m'.. I want to say a buffer overflow
but I just don't remember... It was probably some funky way '%m' 
was being used...since I sure the normal every day use of '%m" 
is fine...
 
steved.

