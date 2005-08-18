From: Michael <oldmoonster@gmail.com>
Subject: Re: can anyone explain this state?
Date: Thu, 18 Aug 2005 21:41:03 +0800
Message-ID: <43048FEF.5020402@gmail.com>
References: <bc57270905081704131c4b23d4@mail.gmail.com>	 <1124280174.23245.4.camel@lade.trondhjem.org> <43032CF2.3070908@redhat.com>	 <1124282392.23245.26.camel@lade.trondhjem.org>	 <20050817235136.GA12262@sgi.com> <1124324316.8347.79.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Greg Banks <gnb@sgi.com>, Peter Staubach <staubach@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5pJu-0006J4-MG
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 11:40:54 -0700
Received: from zproxy.gmail.com ([64.233.162.195])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E5pJ3-0004fU-OY
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 11:40:54 -0700
Received: by zproxy.gmail.com with SMTP id 9so303056nzo
        for <nfs@lists.sourceforge.net>; Thu, 18 Aug 2005 11:39:55 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1124324316.8347.79.camel@lade.trondhjem.org>
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

>to den 18.08.2005 Klokka 09:51 (+1000) skreiv Greg Banks:
>
>  
>
>>Trond, your comments also apply for READs with rsize<PAGE_SIZE; 2.4
>>will do sync reads on the wire in this case.  The performance drop
>>is not as dramatic as with writes because the server is doing its own
>>local readahead, which can't happen for writes, but there's still
>>a performance drop due to lack of parallelism on the wire.
>>    
>>
>
>Yes, however that only affects the first time the file is read.
>The rather dramatic increase in performance between the first read and
>subsequent attempts may almost certainly be attributed to caching, as
>Peter pointed out.
>
>Note: readahead too may cause an extra performance hit when the reads
>are synchronous: if the kernel schedules more readahead than your
>process actually wants to use, this may force your process to wait for
>_all_ those reads to complete (since said process is responsible for
>actually putting each synchronous read on the wire).
>In the large rsize case, when doing asynchronous reads, this is not the
>case. Your process will wait only on those pages it actually uses.
>
>Cheers,
>  Trond
>
>
>  
>
Sorry, Trond and all, I don't know how can your answer solve my 
problem... As I am newbie, could you explain directly against my question?

========================================================================
Yes, I know it should be cache related, but you can see it took me
more than 1 minute at the first time copy 100Mfile from nfs server,
but suddenly the second time took 4 second.
How can the cache result to this? NFS client cache ability? ok, if it
is, that means NFS client could cache at least 90M data of 100M, then,
how to explain the last 2 copies?  with rsize=8k,first time copy 100M
file took 9 seconds, but the second time took 7 seconds, if cache work
as great as rsize=1k, why not the second time copy take less than 1
second?
========================================================================

Thanks again!

Michael



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
