From: Jordi Prats <jprats@cesca.es>
Subject: Re: reply cache
Date: Mon, 15 Oct 2007 20:28:32 +0200
Message-ID: <4713B150.2050607@cesca.es>
References: <47139B20.7070805@cesca.es> <47139BEC.8030400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@ORACLE.COM, Thomas.Talpey@netapp.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhUZ8-0005kc-Hv
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:21:22 -0700
Received: from carlit.cesca.es ([84.88.0.2])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IhUZA-0006yp-HU
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:21:27 -0700
In-Reply-To: <47139BEC.8030400@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Thank you!

I miss understood the reply cache, I was thinking it as a way it caches 
the answer to a question like "which are the attributes of that file?"

Now I'm happy with my zero hits ;)

Jordi

Chuck Lever wrote:
> Jordi Prats wrote:
>> According to the file fs/nfsd/nfscache.c (line 30 on 2.6.23), reply 
>> cache is fixed size. Why is this a fixed size cache? Shouldn't be 
>> relative to the number of nfsd threads? I've a server with this 
>> statistics:
>>
>> rc 0 959398 336415498
>>
>> By what I've been researching this means: 0 hits, 959398 misses (I 
>> supose that means something like "recently deleted") and 336415498 not 
>> in cache (and never has been). Is that right?
> 
> A DRC hit implies the client is retransmitting.  Not having any hits is 
> a good thing -- it means your server is able to handle all your clients 
> without much sweat.
> 
>> Modifying the CACHESIZE to a bigger size do you think it could enhance 
>> NFS performance by getting some hits on the reply cache?
> 
> The server's DRC is not a performance feature.  It's a way for the 
> server to detect replayed requests from the client.  In a perfect world, 
> servers wouldn't even have one.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
