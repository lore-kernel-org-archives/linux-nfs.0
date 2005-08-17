From: Peter Staubach <staubach@redhat.com>
Subject: Re: can anyone explain this state?
Date: Wed, 17 Aug 2005 08:31:36 -0400
Message-ID: <43032E28.6020005@redhat.com>
References: <bc57270905081704131c4b23d4@mail.gmail.com> <1124280174.23245.4.camel@lade.trondhjem.org> <43032CF2.3070908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Michael <mikore.li@gmail.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5N6z-00087b-CK
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 05:33:41 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5N6V-0004sF-DF
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 05:33:41 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43032CF2.3070908@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Peter Staubach wrote:

> Trond Myklebust wrote:
>
>> on den 17.08.2005 Klokka 19:13 (+0800) skreiv Michael:
>>  
>>
>>> Hi,
>>> These day, I observed a strange thing when I copy a 100MB file from
>>> nfs server, both client and server is running redhat 9.0 with kernel
>>> 2.4.20-8:
>>>
>>> $ sudo mount -o
>>> rw,bg,vers=3,tcp,timeo=600,rsize=1024,wsize=1024,hard,intr,ac
>>> server1:/home/test filetest
>>>
>
>
> One last point, I would question your original timing and what the
> configuration looks like.  100M shouldn't take 66 seconds to transfer.
> Even over a 100baseT wire it should take about 10 seconds... 


Oops, sorry, glossed over the 1024 byte transfer sizes used for this 
transfer.
They will kill performance.  Don't use such small sizes unless you have no
other options for getting any connectivity.  I would recommend at least 4k,
8k is better, and 32k is better than that.

    Thanx...

       ps


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
