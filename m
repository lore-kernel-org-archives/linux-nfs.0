From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Status of mount.nfs
Date: Thu, 26 Jul 2007 08:47:09 -0400
Message-ID: <46A897CD.50201@RedHat.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE2kO-0005WO-JU
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 05:47:16 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IE2kR-0004XH-Kb
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 05:47:19 -0700
In-Reply-To: <46A7A5F8.4040204@oracle.com>
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
> I'm looking at probe_nfsport() and probe_mntport() and I see that the 
> portmapper call is avoided iff the protocol version, transport protocol, 
> and the port number are all specified in advance.
> 
> So if you specify:
> 
>    -o mountport=650,port=2049
> 
> mount will still contact the server's portmapper to determine which 
> transport protocols are available (and this breaks through a firewall 
> that doesn't pass portmapper requests).  Only if you specify:
> 
>    -o tcp,mountport=650,port=2049
> 
> or
> 
>    -o udp,mountport=650,port=2049
> 
> then the portmapper calls are avoided entirely.  For some reason 
> probe_bothports() sets the default NFS version to 3 but does not set a 
> default transport protocol.
The protocol is set by probe_port().

> 
> The transport protocols are probed differently for NFS and MNT: for MNT, 
> UDP is probed first then TCP; for NFS, the opposite is true.  The mount 
> command is supposed to try both transport protocol types both for NFS 
> and MNT, but it appears that it is failing to try the other type if the 
> first fails... I see this is also problematic for umount.nfs.
The I idea here was to using UDP to probing for both rpc.mountd and the
NFS server so as not to put (tcp) ports in TIMEWAIT, basically making
them unavailable for the actual mount. The allowed many more tcp
mounts to happen during autofs mount storms.

Note: if the protocol was explicitly specified (i.e. proto=tcp) only
that protocol was used during the probing and mounting. I have
been asked to change that as well. Meaning if when proto=tcp is
specified, they still want the udp probing to occur.

steved.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
