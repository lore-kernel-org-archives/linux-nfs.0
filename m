From: Marc Eshel <eshel@almaden.ibm.com>
Subject: lockd GRANT_MSG RPC callback
Date: Wed, 8 Sep 2004 10:33:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFECAABC86.319E8CA4-ON88256F09.005FC378-88256F09.00606C10@us.ibm.com>
References: <OFAF6A9C4E.27A9BF20-ON88256EFB.00020035-88256EFB.0002DABA@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <OFAF6A9C4E.27A9BF20-ON88256EFB.00020035-88256EFB.0002DABA@LocalDomain>
To: NFS@lists.sourceforge.net
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





Hi,
My server sends the async GRANT_MSG RPC to the client for a blocked lock
but the client either ignoring it or not receiving it. The client wait for
30 seconds and than tries to get the locks again. Can someone explain what
might cause this problem ?
Thanks, Marc.




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
