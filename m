From: Peter Staubach <staubach@redhat.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 13:51:38 -0400
Message-ID: <4A2020AA.6050906@redhat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>	 <49FA0CE8.9090706@redhat.com>	 <1241126587.15476.62.camel@heimdal.trondhjem.org>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>	 <41044976-395B-4ED0-BBA1-153FD76BDA53@oracle.com>	 <OF1B5F174D.1ADF159F-ON852575C5.005FEEB7-852575C5.0060E305@us.ibm.com> <1243618968.7155.60.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Brian R Cowan <brcowan@us.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59694 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600AbZE2Rvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 13:51:43 -0400
In-Reply-To: <1243618968.7155.60.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
>> stop until this stable write completes... What is interesting is that it's 
>> not always a write operation that the linker gets stuck on. Our best 
>> hypothesis -- from correlating times in strace and tcpdump traces -- is 
>> that the FILE_SYNC'ed write NFS RPCs are in fact triggered by *read()* 
>> system calls on the output file (that is opened for read/write). We THINK 
>> the read call triggers a FILE_SYNC write if the page is dirty...and that 
>> is why the read calls are taking so long. Seeing writes happening when the 
>> app is waiting for a read is odd to say the least... (In my test, there is 
>> nothing else running on the Virtual machines, so the only thing that could 
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

