From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: Re: Can someone explain me what this error means?
Date: Thu, 17 Mar 2005 16:16:44 +0000
Message-ID: <4239AD6C.3080605@framestore-cfc.com>
References: <4239A9A3.5000109@framestore-cfc.com> <1111075730.13215.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBxhQ-00056K-Oi
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:18:16 -0800
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DBxhP-0001j9-OB
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:18:16 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1111075730.13215.19.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> to den 17.03.2005 Klokka 16:00 (+0000) skreiv Johan van den Dorpe:
> 
>>Mar 16 12:25:55 nyserv1 kernel: rpc-srv/tcp: nfsd: sent only 5160 bytes 
>>of 8324 - shutting down socket
>>
>>We get this just before the machine becomes inaccessable from the network.
> 
> 
> Is this an error from the kernel nfs daemon? If so, which kernel are you
> running, 'cos there is no such error message in Linux-2.6.11.

The kernel is 2.4.20. I also get this message just before:

Mar 17 10:33:10 nyserv1 kernel: RPC svc_write_space: some sleeping on 
f63c5280

-- 
Johan van den Dorpe


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
