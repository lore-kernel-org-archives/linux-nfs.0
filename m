From: Olaf Kirch <okir@suse.de>
Subject: Re: auto-discovery of exports?
Date: Thu, 8 Apr 2004 08:54:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040408065413.GA19702@suse.de>
References: <41089CB27BD8D24E8385C8003EDAF7AB084850@karl.alexa.com> <4074B2BD.7936CF93@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Guolin Cheng <guolin@alexa.com>, Ian Kent <raven@themaw.net>,
	Michael <mogmios@mlug.missouri.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBTQX-0004aQ-Eo
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 23:54:17 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BBTQX-0007j5-8N
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 23:54:17 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <4074B2BD.7936CF93@melbourne.sgi.com>
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

On Thu, Apr 08, 2004 at 12:02:37PM +1000, Greg Banks wrote:
> You shouldn't rely on port 2049 for pre-v4 NFS.  To enumerate NFS servers
> try doing a broadcast RPC of a NULL call to RPC program 100003.

No, that won't help. Many portmappers are quite restrictive in what
they forward via PMAP_CALL. NFS and MOUNT calls are not among them for
security reasons (because by bouncing your request off portmap, the NFS
server will see a request from 127.0.0.1 - and may grant you more rights
than you would get ordinarily).

Some portmaps may actually allow calls to the NFS NULL procedure, but
many don't.

Broadcasts to 2049 may not work either if the daemon binds to all interface
addresses rather than INADDR_ANY.

I wrote a tool for enumerating NFS servers a long time back, and found
the only way to go about it is to enumerate all hosts first, then do a
pmap_getport(100005), and then call each mountd i turn.

Alternatively you could set up an SLP directory, and change your nfsd startup
scripts to register all nfsd's via SLP.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
