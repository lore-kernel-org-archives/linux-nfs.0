From: Raphael Clifford <cliffor@rockefeller.edu>
Subject: Re: jumbo frames and performance
Date: Mon, 17 Jun 2002 15:48:21 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D0E3D05.3010108@rockefeller.edu>
References: <E17K1pY-00014i-00@usw-sf-list2.sourceforge.net> <3D0E3491.10309@rockefeller.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.rockefeller.edu ([129.85.1.21])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17K2U9-0008RC-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Jun 2002 12:48:21 -0700
Received: from rockefeller.edu (willa.rockefeller.edu [129.85.52.204])
	by mail.rockefeller.edu (8.11.6/8.11.6) with ESMTP id g5HJmIo04956
	for <nfs@lists.sourceforge.net>; Mon, 17 Jun 2002 15:48:18 -0400 (EDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>
>
>>   
>>
>>> It also looks like you are not using jumbo frames, which Trond has 
>>> mentioned as a big performance boost for tcp in 100 baseT full 
>>> duplex environments.
>>>     
>>
>
> as far as i know, jumbo frames are supported only on gigabit.
>

That's what I thought too.

>
>  
>
>>> Also, since you're using 0.3.3 utils, I assume you are using sync 
>>> exports; otherwise there are costs at the server which are hidden 
>>> from the benchmark data.
>>>     
>>
>
> if you use "sync" the server behaves like all other NFS servers
> and pushes data to disk when the client asks it to.  if you
> use "async" the server ignores the client, and pushes data to
> disk when it feels like it.
>
> so, if you benchmark with "async" you get artificially good
> write results because the server responds "OK" to write requests
> before it has really written them to disk.  "async" is not
> an option you would ever use in a production environment,
> naturally.
>
> this is explained somewhere in the performance chapter, near
> the end.
>  
>

Right, performance from the client perspective is explained in the faq 
(actually its not really presented from any particular perspective, but 
its closest to the client perspective) but I thought the point being 
made above was that the server suffers from a large overhead too.  So 
there are two perspectives. The first is that async is faster for the 
client and corrupts your data and the second is whether or not it 
reduces the load for the server.  This is not explained explicitly in 
the HOWTO.

Cheers,
Raphael



_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
