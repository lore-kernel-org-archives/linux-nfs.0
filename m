From: Neil Horman <nhorman@redhat.com>
Subject: Re: Help needed in understanding port allocation in NFS
Date: Wed, 16 Feb 2005 08:14:40 -0500
Message-ID: <42134740.4050700@redhat.com>
References: <20050216102547.A248323CFA@ws5-3.us4.outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1P0u-0005zb-G3
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 05:14:44 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D1P0s-0003Ai-VX
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 05:14:44 -0800
To: naveen a <naveen2005@india.com>
In-Reply-To: <20050216102547.A248323CFA@ws5-3.us4.outblaze.com>
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

naveen a wrote:
> Hi,
> 
> I wanted some info related to port selection in NFS.
> 
> What happens when the port number is not specified in the command line switch or configuration 
> 
> file for mountd and statd?
> 
> In man pages it is mentioned as statd/mountd will select the port from portmapper. 
> 
> Can you please let me know how a port is allotted and the code path in source.
> 
Thats really the entire point of the portmapper.  When userspace service 
are started up, there is not preset port which is allocated.  The new 
rpc service opens a socket and binds to a system selected port (using 
bindresvport IIRC).  That port value is then registered witht he 
portmapper.  The portmapper always listens on the sunrpc port (port 111 
I think), so that remote clients can query the portmapper daemon for 
which port to connect to to get a specific service.

HTH
Neil


-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
