From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: nfs performance: read only/gigE/nolock/1Tb per day
Date: Tue, 23 Apr 2002 20:16:06 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204232001271.31993-100000@kenzo.iwr.uni-heidelberg.de>
References: <shsznzubcdv.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, <netdev@oss.sgi.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1704pr-0001vI-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 11:16:15 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsznzubcdv.fsf@charged.uio.no>
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


[ cc-ed to netdev; the discussion was about receiving bursts of ICMP Time 
Exceeded messages after some large NFS datagrams could not be reassembled; 
sometimes down/up the interface on the receiver/reassembly side cures it ]

On 23 Apr 2002, Trond Myklebust wrote:

>      > How big are the datagrams compared with the MTU ? With 32K
>      > datagrams over Ethernet, you're talking about roughly a full Rx
>      > ring worth of packets (32 is common for the Rx ring size)...
> 
> It has been a while ago (I've since mothballed the machine) but I saw
> it on a Pentium 90 with only 8k write sizes. 4k was fine, 8k gave
> avalanches.

IMHO you can't comletely eliminate hardware related problems: apart from 
having a slow CPU, some early PCI implementations were buggy (although you 
don't say if it's PCI or ISA and what's the link speed).

>      > Does the other side sees these messages ?
> 
> IIRC, yes, and the server was resending the datagrams. From the code,
> it looks as if there is no attempt to stop loopback situations
> occurring when this goes on:
> i.e. resending an ICMP when the server resends a datagram which times
> out again appears to be possible. This might be what was happening...

That's why I cc-ed netdev. My knowledge above the driver level is close to 
non-existant...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
