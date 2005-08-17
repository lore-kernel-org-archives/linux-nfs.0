From: Peter Staubach <staubach@redhat.com>
Subject: Re: can anyone explain this state?
Date: Wed, 17 Aug 2005 08:26:26 -0400
Message-ID: <43032CF2.3070908@redhat.com>
References: <bc57270905081704131c4b23d4@mail.gmail.com> <1124280174.23245.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Michael <mikore.li@gmail.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5N1S-0007u7-AE
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 05:27:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5N1R-0003k1-Ur
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 05:27:58 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1124280174.23245.4.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>on den 17.08.2005 Klokka 19:13 (+0800) skreiv Michael:
>  
>
>>Hi, 
>>
>>These day, I observed a strange thing when I copy a 100MB file from
>>nfs server, both client and server is running redhat 9.0 with kernel
>>2.4.20-8:
>>
>>$ sudo mount -o
>>rw,bg,vers=3,tcp,timeo=600,rsize=1024,wsize=1024,hard,intr,ac
>>server1:/home/test filetest
>>$ time cp ./filetest/new100m /tmp/o100m
>>
>>real    1m6.575s
>>user    0m0.040s
>>sys     0m1.430s
>>$ time cp ./filetest/new100m /tmp/o100m
>>
>>real    0m4.964s     =================> it is so different comparing
>>with above time!!
>>user    0m0.030s
>>sys     0m0.570s
>>    
>>
>
>This is done using synchronous writes. Each write will wait for the
>server to commit it to disk.
>
>  
>
>>$ sudo umount filetest
>>$ sudo mount -o
>>rw,bg,vers=3,tcp,timeo=600,rsize=102400,wsize=102400,hard,intr,ac
>>server1:/home/test filetest
>>$ time cp ./filetest/new100m /tmp/o100m
>>
>>real    0m9.075s
>>user    0m0.020s
>>sys     0m0.470s
>>$ time cp ./filetest/new100m /tmp/o100m
>>
>>real    0m7.501s    ==================>only different in 2 seconds!
>>why not less than 4.9 seconds?
>>user    0m0.000s
>>sys     0m0.520s
>>    
>>
>
>This is done using asynchronous writes. Much faster, and no need (on
>NFSv3) to wait for the disk before sending the next request.
>
>The reason is that on 2.4 kernels (and early 2.6 kernels) we could only
>do synchronous writes when you set wsize < PAGE_SIZE.
>

Maybe I am misreading the commands being run, but they look like they would
generate all NFS READ traffic.  It appears to be copying from an NFS mounted
file system to /tmp, a local file system.

I would chalk most of these differences up to caching, as in the difference
between #1 and #2, and general system dynamics for the differences between
#3 and #4.

By the way, setting rsize and wsize large like that is probably not helping.
The transfer sizes are calculated as the minimum of the transfer sizes
advertised by the server and what the client can support.  In this case,
the server would probably be limiting the transfer sizes.

One last point, I would question your original timing and what the
configuration looks like.  100M shouldn't take 66 seconds to transfer.
Even over a 100baseT wire it should take about 10 seconds...

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
