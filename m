From: Ian Kent <raven@themaw.net>
Subject: Re: nfs bindresvport: Address already in use
Date: Thu, 17 Feb 2005 09:37:03 +0800 (WST)
Message-ID: <Pine.LNX.4.58.0502170929560.19755@wombat.indigo.net.au>
References: <slrncvqs9p.evp.sba@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mlist-nfs-valinux@nntp-server.caltech.edu
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1aYq-0000O6-CV
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 17:34:32 -0800
Received: from naig.caltech.edu ([131.215.49.17])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1aYq-0007dK-0v
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 17:34:32 -0800
To: Stuart Anderson <sba@srl.caltech.edu>
In-Reply-To: <slrncvqs9p.evp.sba@localhost.localdomain>
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

On Sun, 30 Jan 2005, Stuart Anderson wrote:

> 
> I get the following error on the a Linux (FC3) client machine when I issue
> more than 53 NFS mount requests in less than ~1 minute:
> 
> Jan 30 10:40:22 beowulf automount[22882]: >> nfs bindresvport:
> 	Address already in use
> Jan 30 10:40:22 beowulf automount[22882]: mount(nfs): nfs:
> 	mount failure node54:/usr1 on /data/node54
> Jan 30 10:40:22 beowulf automount[22882]: failed to mount /data/node54
> 
> If I wait ~1 minute, I can mount another set of ~50 filesystems.
> The NFS servers are also running FC3.
> 
> I repeatedly get this problem whether I manually issue the mount requests
> with /bin/mount or use the automounter.

One way to work around this is to rebuild the util-linux package without 
the offending patch.

The patch that is causing you grief is against mount. Last time I tried to 
locate it, it was fairly obvious. It does RPC probes to the servers it 
expects to mount. This causes around 6 or more reserved ports to be used 
for each attempted mount. Possibly more in your case or maybe you have a 
bunch off mounts which fail. Last time I exersised this I was able to get 
just over 120 mounts before the pear took shape.

Ian



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
