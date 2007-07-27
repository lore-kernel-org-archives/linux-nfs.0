From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Status of mount.nfs
Date: Fri, 27 Jul 2007 11:00:46 -0400
Message-ID: <46AA089E.50503@RedHat.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
	<46A96032.7080503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IERJJ-0003nt-KG
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 08:00:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IERJN-0000pF-12
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 08:01:01 -0700
In-Reply-To: <46A96032.7080503@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Chuck Lever wrote:
> 
> And umount.nfs always uses TCP for the mountd request.  I have a patch 
> that fixes that to behave more like mount.nfs does, which I will forward 
> in the next day or two.
thats a bug... umount should use the protocol the mount did...
I thought I had fixed that... :-\

> 
> I notice some problems if a share is mounted with TCP, but the server 
> later disables TCP -- umount.nfs hiccups on that when it tries to umount 
> using the same protocol as listed in /etc/mtab.  Perhaps relying on 
> /etc/mtab for setting the umount protocol is unnecessary.
I think I was using /proc/mounts...

> 
> We have three requests that need to be made:
> 
> 1.  GETPORT -- I think this should UDP all the time unless proto=tcp is 
> explicitly specified;
Some people have asked that we first try UDP all the time... which
I have resisted but it might make sense...

> 
> 2.  MNT -- likewise, UDP unless proto=tcp is specified or GETPORT says 
> UDP is not supported;
> 
> 3.  NFS -- this should be TCP all the time unless proto=udp is specified 
> or GETPORT says TCP is not supported.
What about rollbacks... meaning if tcp is not supported do we try udp?
if v4 is not supported to we try v3 and the v2 or just fail the mount?

> 
> Even better would be to use RPCB_DUMP instead of RPCB_GETPORT.  That way 
> we only need a single rpcbind call for both protocols, and can get 
> transport protocol information as well, and make an "informed" choice.
Good point... but note, a while back I got a request to use GETPORT
instead of DUMP because some Cisco router actually use the GETPORTs
to punch wholes in their firewalls.
> 
> Also, can we get rid of the clnt_ping()?  If not, can we document why it 
> is there?  It adds two extra round trips to the whole process.  If error 
> reporting is the problem, maybe we can try the pings only if the kernel 
> part of the mount process fails?
How do we avoid hang down deep in RPC land (governed by
uncontrollable timeout) when either mountd or nfsd  are not up?

That was the main reason for the ping. Since neither portmapper or
rpcbind ping their services before they hand out the ports, there
is really no way of telling where the server is up? So to avoid
the hang, we ping them... Sure its costly network wise, but
hanging during a boot because a server is not responding is
a bit more costly... imho...

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
