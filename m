From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [kNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Tue, 22 Mar 2005 10:34:32 +1100
Message-ID: <16959.23048.930497.833801@cse.unsw.edu.au>
References: <423EDD43.8000209@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDWPy-0004nd-HA
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 15:34:42 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DDWPx-0004XA-SA
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 15:34:42 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Monday March 21
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

On Monday March 21, SteveD@redhat.com wrote:
> Hello,
> 
> The following patches fix the '-p port' command line
> argument to rpc.nfsd as well as adds following
> flags that control the NFS versions and transports that
> rpc.nfsd will use.

While this is all very good in principle, there are some details I'm
not comfortable with....
In particular, the kernel interface.
You have changed 
  /proc/fs/nfsd/threads
to contain not just threads information, but also port, protocol and
version information.

This is not good.

I would rather (I think) have two new files
   /proc/fs/nfsd/version
and
   /proc/fs/nfsd/ports

"version" should give a list of available versions, and which are
enabled, on read, and should enable or disable version on write.
e.g.
   # cat version
   -2 +3 -4

This means that versions 2, 3, and 4 are available. Only 3 is enabled.

   # echo +4 > version

This enables version 4 (if it is available).

"ports".... should we allow different protocols to use different
   ports?  2049 for tcp, but use 5123 for udp ???
   I think we should probably allow for distinguishing between ipv4
   and ipv6.
   And would we also want to allow binding to particular IP addresses
   ???? or multiple ports???

   Maybe a better interface is to open and bind a socket in userspace,
   and pass it down to the kernel.  Maybe not..

 How about the "ports" file contains lines:
   family:proto:address:port
 e.g.
   ipv4:udp:*:2049

 Where new entries can added one line at a time:
   echo "ipv4:tcp:*:5123" > /proc/fs/nfsd/ports
 and are all read at once.
   # cat  /proc/fs/nfsd/ports
   ipv4:udp:*:2049
   ipv4:tcp:*:2049
   #
 Initially, the only recognised address would be "*", and multiple
 ports of the same protocol would not be permitted (i.e. write(2)
 returns and error).

 A port could be disabled with
   echo "-ipv4:udp:*:2049" > /proc/fs/nfsd/ports
 maybe.
  
 When the first thread is started, if no ports are open, the default
 ports (2049 for ipv4:udp and ipv4:tcp) are openned, otherwise the
 current ports are used.

I'm happy to consider changes in syntax, but I really don't like
merging these very different concepts in the one file.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
