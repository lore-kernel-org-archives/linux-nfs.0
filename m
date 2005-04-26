From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: RE: Client sees delay  in io when nfs server starts after failover
Date: Tue, 26 Apr 2005 07:40:42 -0700 (PDT)
Message-ID: <20050426144042.14867.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQRFB-0002p4-HJ
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:40:57 -0700
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DQRF5-0008QA-Gh
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:40:57 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: 6667
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


--- "Lever, Charles" <Charles.Lever@netapp.com> wrote:
 
1 if the client hasn't managed to establish a new
2 connection yet, then, yes you can expect to see the 
3 rpcinfo results like the above and still
4 have a delay in response.  the RPC client can't send
5 RPC requests or receive replies until a TCP 
6 connection has been established with the
7 server.  that can take a while; SYN retries have an
8 exponential backoff.

-------
  I didnt quiet get the  line 3-8 .
  What i undestand is that connection is not 
  established but still rpc request returns info
  which should appear only if connection is existing.
  How can rpc request return success if connection
  through which it passes does not exist ?

thanks ,
 kiran

  

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
