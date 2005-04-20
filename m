From: Neil Horman <nhorman@redhat.com>
Subject: Re: Enable NFS over TCP
Date: Wed, 20 Apr 2005 09:35:14 -0400
Message-ID: <20050420133514.GB8264@hmsendeavour.rdu.redhat.com>
References: <42554EFB.9E4@sat.dundee.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOFMR-0008Pb-Q1
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 06:35:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOFMR-00062V-9N
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 06:35:23 -0700
To: Andrew Brooks <arb@sat.dundee.ac.uk>
In-Reply-To: <42554EFB.9E4@sat.dundee.ac.uk>
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

On Thu, Apr 07, 2005 at 04:17:15PM +0100, Andrew Brooks wrote:
> Hi,
> 
> Sorry to bring up this old chestnut but I can't get my server to
> advertise the TCP service; rpcinfo shows only udp and mount -o tcp
> reports "nfs server reported service unavailable: Address already
> in use".
> 
> I've rebuilt the kernel 2.4.26 with all NFS patches and both ticked:
> CONFIG_EXPERIMENTAL and CONFIG_NFSD_TCP.
> 
> nfs-utils 1.0.7 has been installed (on the server at least).
> 
> /etc/init.d/nfs and /etc/sysconfig/nfs look ok.
> 
> Now I'm out of ideas!
> 
Try enabling /proc/sys/sunrpc/nfsd_debug and checking for errors?


> Thanks,
> 
> Andrew
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

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
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
