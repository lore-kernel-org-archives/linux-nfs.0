From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: Re: Statd problem
Date: Wed, 30 Mar 2005 11:00:56 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C961250023B07@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGZ49-00078s-82
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 01:00:45 -0800
Received: from loewe.unit-netz.de ([212.202.148.42])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DGZ47-0007GY-4n
	for nfs@lists.sourceforge.net; Wed, 30 Mar 2005 01:00:45 -0800
To: "'mehta kiran'" <kiranmehta1981@yahoo.com>,
	"'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

The AIX clients only contain an empty file named as the server in their sm
directory.
rpcinfo -p shows nlockmgr vers 1/3/4 tcp/udp running on the server.
nfs-utils are 1.0.7.

I got a a similar problem (same messages) in past with kernel 2.2 and lockd
zombies.
All is working fine, but the messages started in march so I assumed that
there was a change between 2.6.10 and 11?!?

For the easiest answer to this question, I will do a rollback to 2.6.10 and
see.

Thanks
Daniel



----------
Hi Daniel , 
    lockd has rpc service no. 100021 . This message
means that statd is not able to talk to statd.
Are there any files on client side in /var/lib/nfs/sm
when it restarts ?

Try deleting all this files before nfs restarts on
client.

Also see that  lockd is registered with
portmapper.(use command rpcinfo -p)

regards,
 --kiran



--- Beschorner Daniel <Daniel.Beschorner@facton.com>
wrote:
> Since the first reboot of our clients (mainly AIX)
> after we updated our NFS
> server from 2.6.10 to 2.6.11 we get sporadically
> these server log entries, I
> think after each client reboot:
> 
> Mar 29 12:44:31 server rpc.statd[3201]: recv_rply:
> [127.0.0.1] RPC status 1
> Mar 29 12:44:49 server last message repeated 3 times
> Mar 29 12:44:55 server rpc.statd[3201]: Can't
> callback server (100021,4),
> giving up.
> 
> What do they mean? No further problems are seen.
> Mounts are TCP/V3.
> 
> Thanks
> Daniel
> 
> 
>
-------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT
> Products from real users.
> Discover which products truly live up to the hype.
> Start reading now.
>
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Small Business - Try our new resources site!
http://smallbusiness.yahoo.com/resources/ 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
