From: Neil Horman <nhorman@redhat.com>
Subject: Re: Help needed in understanding allocation of ports in NFS
Date: Fri, 18 Feb 2005 07:12:02 -0500
Message-ID: <4215DB92.30006@redhat.com>
References: <20050216100402.57E0721AFF9@ws5-6.us4.outblaze.com> <1108678086.5897.62.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: naveen a <naveen2005@india.com>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D26zQ-0003ro-S2
	for nfs@lists.sourceforge.net; Fri, 18 Feb 2005 04:12:08 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D26zQ-0007KW-CP
	for nfs@lists.sourceforge.net; Fri, 18 Feb 2005 04:12:08 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1108678086.5897.62.camel@seki.nac.uci.edu>
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

Dan Stromberg wrote:
> Generally speaking, being RPC services, the portmapper (portmap or
> rpcbind) are free to allocate whatever ports to these services they feel
> like, and then client programs will contact the portmapper, give it the
> RPC program number, protocol and version, and then the portmapper will
> tell the client program which port to use.
> 
> However, I've gotten the impression that some NFS-related rpc services
> always come up on the same ports in practice.
> 
> Still, if you want to combine NFS with a firewall, you likely either
> want to allow anything from a list of hosts, or configure NFS to use
> specific ports...
> 
Some firewalls are available on the market (I think the cisco pix is 
one) that snoop for portmap dump and getport transactions, and use the 
information in them to dynamically open ports for services you wish to 
allow.  You can also use the ip_queue target in iptables to write some 
extra intellegence into your linux firewall to do the same thing.
Neil

> On Wed, 2005-02-16 at 18:04 +0800, naveen a wrote:
> 
>>Hi,
>>
>>I wanted some info related to port selection in NFS.
>>
>>What happens when the port number is not specified in the command line switch or configuration 
>>file for mountd and statd?
>>
>>In man pages it is mentioned as statd/mountd will select the port from portmapper. 
>>
>>Can you please let me know how a port is allotted and the code path in source.
>>
>>What is the criteria for allocation of ports by portmapper ?
>>
>>Please educate me on this.
>>
>>Thanks
>>Naveen


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
