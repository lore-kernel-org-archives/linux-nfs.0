From: Chris Worley <cworley@lnxi.com>
Subject: Re: Stopping NFS, ip address take over, zero-copy NFS for
	2.4.21, and misc
Date: 18 Sep 2003 19:11:01 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063933860.8026.11376.camel@localhost.localdomain>
References: <1063900790.8031.9644.camel@localhost.localdomain>
	 <3F6A21E1.9090404@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A09qg-0004cJ-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 18:14:14 -0700
Received: from [208.177.141.226] (helo=localhost.lnxi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A09qf-0002cH-K8
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 18:14:13 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3F6A21E1.9090404@moving-picture.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

James,

Can I just "cat" fake entries into rmtab... or does client really need
to mount it once.

When is rmtab flushed (deleted of old/defunct entries)?

Thanks!

Chris
On Thu, 2003-09-18 at 15:21, James Pearson wrote:
> Chris Worley wrote:
> >
> > 2) IP address takeover between NFS servers.
> > 
> > With NFS stateless, and not running lock servers, I thought a simple IP
> > address takeover scheme (when an I/O server goes down, another just adds
> > the failed server's IP address as a virtual interface) would allow
> > clients to immediately renegotiate with the same IP address pointing to
> > another NFS server (serving the same partitions).  The take-over is
> > successful: the clients can communicate with the new I/O server, but I
> > get "permission denied" (as root or otherwise) on the NFS mounted
> > partitions most of the time (sometimes it works).
> > 
> > What am I missing?
> 
> I don't know a lot about NFS fail over, but I guess unless the take-over 
> server has a copy (or the same copy) of /var/lib/nfs/rmtab, then you 
> will get "permission denied" - the server needs an entry for each 
> client. I guess it works some of the time as the take-over server has a 
> 'valid' entry in its rmtab file for that client.
> 
> James Pearson
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
