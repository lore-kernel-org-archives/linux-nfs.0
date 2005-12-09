From: Peter Staubach <staubach@redhat.com>
Subject: Re: mtime not updated in client cache?
Date: Fri, 09 Dec 2005 09:24:48 -0500
Message-ID: <439993B0.90801@redhat.com>
References: <438B9C44.4030305@google.com>	 <1133225130.12178.9.camel@lade.trondhjem.org> <438E4CA7.2050405@google.com>	 <1133399727.8267.11.camel@lade.trondhjem.org> <43978AD2.8020000@google.com>	 <1134013082.8002.8.camel@lade.trondhjem.org> <43998F4C.6010902@redhat.com> <1134137783.8007.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Vince Busam <vbusam@google.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkjB8-0008RW-6w
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 06:24:54 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EkjB7-0004PE-Si
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 06:24:54 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134137783.8007.24.camel@lade.trondhjem.org>
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

>On Fri, 2005-12-09 at 09:06 -0500, Peter Staubach wrote:
>  
>
>>Trond Myklebust wrote:
>>
>>    
>>
>>><looks at code>
>>>
>>>Yep. Your code contains a wrong assumption: fflush() is not guaranteed
>>>to immediately update mtime/ctime since it does not sync data to disk.
>>>The same is true of the posix "write()" function.
>>>
>>>If you add the line fsync(fileno(fp)) after the call to fflush(), then
>>>the mtime will be correctly updated.
>>>
>>>      
>>>
>>Perhaps I am missing something, but fsync(2) should not cause the 
>>mtime/ctime
>>to change.  The write(2) call should.  Sequences such as 
>>stat(&a)/write()/stat(&b)
>>should result b.st_mtime != a.st_mtime.
>>    
>>
>
>If you are caching the write on the client, then the server will not
>update the mtime on the file.
>
>OTOH, I do not like the idea of updating mtime on the client, since
>there is no guarantee that the client and server are synchronised (you
>can easily end up with the mtime jumping forwards and backwards).
>
>One alternative would be to flush dirty data to the server on every call
>to stat(), but that would slow it down considerably.
>

Yes, to this last, but this is how most NFS implementations that I have seen
conform to the requirment that write(2) cause the mtime to be updated.  The
use of UNSTABLE NFSv3/NFSv4 writes can help as well as limiting the amount
of dirty data that the client allows to be cached.

The client should _definitely_ not be setting the mtime itself.  The 
file times
are always managed by the server.

    Thanx...

       ps


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
