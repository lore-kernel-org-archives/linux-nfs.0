From: Brian R Cowan <brcowan@us.ibm.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Fri, 29 May 2009 14:25:25 -0400
Message-ID: <OF90E0E597.708E76E7-ON852575C5.0062D815-852575C5.00653465@us.ibm.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>
	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com> <1243618968.7155.60.camel@heimdal.trondhjem.org> <4A2020AA.6050906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42644 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbZE2SZZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 14:25:25 -0400
In-Reply-To: <4A2020AA.6050906@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter, this is my point. The application/client-side end result is that 
we're making a read wait for a write. We already have the data we need in 
the cache, since the application is what put it in there to begin with. 

I think this is a classic "unintended consequence" that is being observed 
on SuSE 10, Red hat 5, and I'm sure others. 

But since people using my product have only just started moving to Red hat 
5, we're seeing more of these... There aren't too many people who build 
across NFS, not when local storage is relatively cheap, and much faster. 
But there are companies that do this so the build results are available 
even if the build host has been turned off, gone to standby/hibernate, or 
is even a virtual machine that no longer exists. The biggest problem here 
that the unavoidable extra filesystem cache load that build auditing 
creates appears to trigger the flushing. For whatever reason, those 
flushes happen in such a way to trigger the STABLE writes instead of the 
faster UNSTABLE ones. 

=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Customer Advocacy Group (CAG)
Rational Software
IBM Software Group
81 Hartwell Ave
Lexington, MA
 
Phone: 1.781.372.3580
Web: http://www.ibm.com/software/rational/support/
 

Please be sure to update your PMR using ESR at 
http://www-306.ibm.com/software/support/probsub.html or cc all 
correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
case I am not available.



From:
Peter Staubach <staubach@redhat.com>
To:
Trond Myklebust <trond.myklebust@fys.uio.no>
Cc:
Brian R Cowan/Cupertino/IBM@IBMUS, Chuck Lever <chuck.lever@oracle.com>, 
linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org
Date:
05/29/2009 01:51 PM
Subject:
Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing



Trond Myklebust wrote:
> On Fri, 2009-05-29 at 13:38 -0400, Brian R Cowan wrote:
> 
>>> You may have a misunderstanding about what exactly "async" does.  The 
>>> "sync" / "async" mount options control only whether the application 
>>> waits for the data to be flushed to permanent storage.  They have no 
>>> effect on any file system I know of _how_ specifically the data is 
>>> moved from the page cache to permanent storage.
>>> 
>> The problem is that the client change seems to cause the application to 

>> stop until this stable write completes... What is interesting is that 
it's 
>> not always a write operation that the linker gets stuck on. Our best 
>> hypothesis -- from correlating times in strace and tcpdump traces -- is 

>> that the FILE_SYNC'ed write NFS RPCs are in fact triggered by *read()* 
>> system calls on the output file (that is opened for read/write). We 
THINK 
>> the read call triggers a FILE_SYNC write if the page is dirty...and 
that 
>> is why the read calls are taking so long. Seeing writes happening when 
the 
>> app is waiting for a read is odd to say the least... (In my test, there 
is 
>> nothing else running on the Virtual machines, so the only thing that 
could 
>> be triggering the filesystem activity is the build test...)
>> 
>
> Yes. If the page is dirty, but not up to date, then it needs to be
> cleaned before you can overwrite the contents with the results of a
> fresh read.
> That means flushing the data to disk... Which again means doing either a
> stable write or an unstable write+commit. The former is more efficient
> that the latter, 'cos it accomplishes the exact same work in a single
> RPC call.

In the normal case, we aren't overwriting the contents with the
results of a fresh read.  We are going to simply return the
current contents of the page.  Given this, then why is the normal
data cache consistency mechanism, based on the attribute cache,
not sufficient?

    Thanx...

       ps



