From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: RE: Client sees delay  in io when nfs server starts after failover
Date: Tue, 26 Apr 2005 07:12:33 -0700 (PDT)
Message-ID: <20050426141233.28304.qmail@web51607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQQnp-0000Zc-22
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:12:41 -0700
Received: from web51607.mail.yahoo.com ([206.190.38.212])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DQQnn-0003Mg-HZ
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 07:12:40 -0700
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

Hi , 
      But client displays message "nfs server not 
      responding" even if following messages are 
      given by rpcinfo.
    
      #rpcinfo -u <server> 100003
       program 100003 version 2 ready and waiting
       program 100003 version 3 ready and waiting
       program 100003 version 4 ready and waiting 

      #rpcinfo -t <server> 100003
       program 100003 version 2 ready and waiting
       program 100003 version 3 ready and waiting
       program 100003 version 4 ready and waiting 

      Should rpc calls over tcp respond  if server
      is not available

thanks,
 --kiran


      
--- "Lever, Charles" <Charles.Lever@netapp.com> wrote:
> >     I am using sles9 sp1 rc5 (2.6.5-7.139 kernel)
> >     NFS server is running on a machines.
> >     Client access server and does moderate amount 
> >     of io on mounted filesystem.
> >     When nfs server switches to other machine , 
> >     nfs client has to wait for 2-3 minutes so as
> >     to continue io on new nfs server.
> >     Sometimes client sees delay of  20-30
> >     seconds only.Why is this difference seen in
> >     different runs/executions.
> >    
> >     Is this the expected behaviour ?
> 
> i'm speculating, but i expect the delay is due to
> the time it takes the
> client TCP layer to reconnect to the new server
> host.  i notice when a
> client loses a TCP connection to a server (even
> without a failover) it
> takes as long as 2-3 minutes to reconnect.  it's on
> my list of things to
> look at improving.
> 

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
