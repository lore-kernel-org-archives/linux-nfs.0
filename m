From: Spencer Shepler <spencer.shepler@sun.com>
Subject: Re: Re: EJUKEBOX and nfs3_proc_read()/nfs3_proc_write()
Date: Thu, 27 Jan 2005 22:15:29 -0800
Message-ID: <20050128061529.GA944944@jurassic.eng.sun.com>
References: <20050127225911.GA24398@janus> <1106867997.7192.14.camel@lade.trondhjem.org> <20050127233831.GA24817@janus>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuPPv-0002e2-Ln
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 22:15:39 -0800
Received: from nwkea-mail-1.sun.com ([192.18.42.13])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CuPPv-0007Zk-3Z
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 22:15:39 -0800
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20050127233831.GA24817@janus>
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

On Fri, Frank van Maarseveen wrote:
> On Thu, Jan 27, 2005 at 03:19:57PM -0800, Trond Myklebust wrote:
> > to den 27.01.2005 Klokka 23:59 (+0100) skreiv Frank van Maarseveen:
> > > I think that the EJUKEBOX wrapper in fs/nfs/nfs3proc.c is not necessary
> > > for nfs3_proc_read() and nfs3_proc_write().
> > > 
> > > Can you confirm this?
> > 
> > Why do you believe that?
> 
> Because you have to open a file first. Well, as you said NFS is stateless
> so my guess is that the final lookup would return EJUKEBOX rather
> than any I/O on the file-handle. It seems unrealistic to me for a file to
> be archived _during_ I/O.
> 
> Sure the protocol has the possibility to return EJUKEBOX in the middle
> of file I/O but does it make sense?

Yes. It makes sense.  There are HSM solutions that keep the first
portion of the file on disk to be provided to things like the file
command.  If the whole file is read, then subsequent READ requests
may receive EJUKEBOX.

> 
> BTW, I didn't see EJUKEBOX handling in NFSv4.

NFS4ERR_DELAY

Spencer



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
