From: "george drossos" <drossos21@hotmail.com>
Subject: nfs problem
Date: Tue, 13 Aug 2002 11:44:10 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F118hBAgKR7ANimhYOj0000f31f@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f118.law11.hotmail.com ([64.4.17.118] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ea62-0004xC-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 04:44:22 -0700
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



I'm a student in South Bank University London and i,m working on a project 
"distibuted and parallel processing in Linux".
I tried to set up NFS(i have 1 server and 2 clients).
My kernel version is 2.4.18-3 and i installed red.hat 7.3.I didn't install 
any other operation system.
I check that nfs is running on the server(all the daemons as start-up 
scripts)and i ckeck that nfs is running on the clients as well.
I edit /etc/exports i wrote the directory that i want to export and the 
destination hosts.
About the clients,the mount version is 2.10n,nfs daemons are running.
I red the file /proc/filesystems if nfs was there,it wasn't but appeared by 
typing insmod nfs.I check again the services by typing rpcinf -p and 
everything was ok.
When i try to mount the remote directory i have error message:
    mount:RPC:Port mapper failure-RPC:Unable to receive

I checked again that NFS was running in three machines and afterwards i 
typed on each client:
                      rpcinfo -p servername
the error message was:
  rpcinfo:can't contact portmapper:RPC remote system error:Connection   
refused

Also i want to say in the case that there is a routing problem,i ping the 
machines and everything is ok.The only problem that i have until now is that 
i cannot connect the clients with the university's network.When i ping the 
default gateway (from the clients) says Network is unreachable.In the case 
of server(has 2 network cards) i ping everything and the university network 
is reachable.

I would really appreciate replying and i'm really looking forward your 
suggestions and advices.

                       George Drossos


_________________________________________________________________
Join the world’s largest e-mail service with MSN Hotmail. 
http://www.hotmail.com



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
