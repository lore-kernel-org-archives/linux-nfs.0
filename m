From: Ion Badulescu <ionut@badula.org>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Wed, 19 Feb 2003 10:47:21 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302191034310.29393-100000@guppy.limebrokerage.com>
References: <Pine.GSO.4.40.0302191520180.29315-100000@bodoni>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ip64-48-93-2.z93-48-64.customer.algx.net ([64.48.93.2] helo=ns1.limegroup.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lWRb-0006BK-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 07:47:35 -0800
To: Fabrizio Nesti <nesti@medialab.sissa.it>
In-Reply-To: <Pine.GSO.4.40.0302191520180.29315-100000@bodoni>
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

On Wed, 19 Feb 2003, Fabrizio Nesti wrote:

> Yes we exported it async :) as confirmed by the snoop that I reported
> earlier. See it also below. But nothing changed.

The snoop would not show anything, actually, since it's the server that 
chooses to ignore the COMMIT call or not. The WRITE's will be async anyway
for NFSv3 (unlike for v2) precisely because the COMMIT call exists in v3.

> > The other thing to remember is that "cto"...
> > ...
> 
> On the solaris client? It is not in the man mount_nfs, but it
> worked. However there was no performance upgrade.

Yes, solaris definitely supports nocto since at least sol2.6, it is option 
0x2000 in its flags field in the NFS mount structure.

> Also, I can't recognize it in the old traffic snoop..
> I report below some of it during the write of one file from tar.

If you could get timestamps for that snoop (or tcpdump) output, it would 
be great. We could at least see who is taking too much time.

> A clue seems this now: the "tar" process itself on solaris uses 4% cpu while
> writing on a local disk, and 40% and over while writing to the nfs disk...
> (not using -z gzip:) Also, mounting nfs2 seems 30% faster.. But we do not
> understanf the reason.

So perhaps the Solaris client is inefficient? Maybe it's something in 
the way the Linux NFS server replies that triggers a bug in the client? 
Who knows...

Have you tried looking a two capture outputs, one with a Linux server and 
one with a Solaris server, to see what the differences are?

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.





-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
