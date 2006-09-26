From: Stephane Doyon <sdoyon@max-t.com>
Subject: Re: Long sleep with i_mutex in xfs_flush_device(),
 affects NFS service
Date: Tue, 26 Sep 2006 16:05:41 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609261531430.10642@madrid.max-t.internal>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<1159297579.5492.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, xfs@oss.sgi.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSJE9-0004Ua-OR
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 13:08:25 -0700
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]
	helo=mail.max-t.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSJE9-0007Lq-1M
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 13:08:26 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1159297579.5492.21.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 26 Sep 2006, Trond Myklebust wrote:

[...]
>> When the file system becomes nearly full, we eventually call down to
>> xfs_flush_device(), which sleeps for 0.5seconds, waiting for xfssyncd to
>> do some work.
>>
>> xfs_flush_space()does
>>          xfs_iunlock(ip, XFS_ILOCK_EXCL);
>> before calling xfs_flush_device(), but i_mutex is still held, at least
>> when we're being called from under xfs_write(). It seems like a fairly
>> long time to hold a mutex. And I wonder whether it's really necessary to
>> keep going through that again and again for every new request after we've
>> hit NOSPC.
>>
>> In particular this can cause a pileup when several threads are writing
>> concurrently to the same file. Some specialized apps might do that, and
>> nfsd threads do it all the time.
[...]
>> The linux NFS client typically sends bunches of 16 requests, and so if the
>> client is writing a single file, some NFS requests are therefore delayed
>> by up to 8seconds, which is kind of long for NFS.
>
> Why? The file is still open, and so the standard close-to-open rules
> state that you are not guaranteed that the cache will be flushed unless
> the VM happens to want to reclaim memory.

I mean there will be a delay on the server, in responding to the requests. 
Sorry for the confusion.

When the NFS client does flush its cache, each request will take an extra 
0.5s to execute on the server, and the i_mutex will prevent their parallel 
execution on the server.

>> What's worse, when my linux NFS client writes out a file's pages, it does
>> not react immediately on receiving a NOSPC error. It will remember and
>> report the error later on close(), but it still tries and issues write
>> requests for each page of the file. So even if there isn't a pileup on the
>> i_mutex on the server, the NFS client still waits 0.5s for each 32K
>> (typically) request. So on an NFS client on a gigabit network, on an
>> already full filesystem, if I open and write a 10M file and close() it, it
>> takes 2m40.083s for it to issue all the requests, get an NOSPC for each,
>> and finally have my close() call return ENOSPC. That can stretch to
>> several hours for gigabyte-sized files, which is how I noticed the
>> problem.
>>
>> I'm not too familiar with the NFS client code, but would it not be
>> possible for it to give up when it encounters NOSPC? Or is there some
>> reason why this wouldn't be desirable?
>
> How would it then detect that you have fixed the problem on the server?

I suppose it has to try again at some point. Yet when flushing a file, if 
even one write requests gets an error response like ENOSPC, we know some 
part of the data has not been written on the server, and close() will 
return the appropriate error to the program on the client. If a single 
write error is enough to cause close() to return an error, why bother 
sending all the other write requests for that file? If we get an error 
while flushing, couldn't that one flushing operation bail out early? As I 
said I'm not too familiar with the code, but AFAICT nfs_wb_all() will keep 
flushing everything, and afterwards nfs_file_flush() wil check ctx->error. 
Perhaps ctx->error could be checked at some lower level, maybe in 
nfs_sync_inode_wait...

I suppose it's not technically wrong to try to flush all the pages of the 
file, but if the server file system is full then it will be at its worse. 
Also if you happened to be on a slower link and have a big cache to flush, 
you're waiting around for very little gain.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
