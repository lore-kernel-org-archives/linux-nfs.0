From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS performance tuning
Date: Sun, 08 Jan 2006 17:09:15 -0500
Message-ID: <1136758155.7849.11.camel@lade.trondhjem.org>
References: <OFFAE75FBD.F10D10DF-ON882570F0.0073C58D-882570F0.0073FC86@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Kent <raven@themaw.net>,
	Stephen Carville <stephen@totalflood.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EvijX-0008Qs-3I
	for nfs@lists.sourceforge.net; Sun, 08 Jan 2006 14:09:51 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EvijV-00088h-9H
	for nfs@lists.sourceforge.net; Sun, 08 Jan 2006 14:09:50 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFFAE75FBD.F10D10DF-ON882570F0.0073C58D-882570F0.0073FC86@us.ibm.com>
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

On Sun, 2006-01-08 at 13:10 -0800, Marc Eshel wrote:
> nfs-admin@lists.sourceforge.net wrote on 01/08/2006 12:22:13 PM:
> 
> > On Sat, 2006-01-07 at 23:44 -0800, Blake Golliher wrote:
> > > The linux nfs client supports, at least, a 64k block transfer size.  I 
> 
> > > don't believe it's constrained by transport protocol.
> > 
> > That is a very recent feature, though. Unless you are using the NFS_ALL
> > patches, you will only get 64k block transfer sizes on the very latest
> > GIT tarball. ;-)
> > 
> > Cheers,
> >   Trond
> > 
> 
> But is still constrained by the transport protocol.
> Marc.

Yes. UDP won't allow you to use 64k read/write sizes since that would
overflow the size of a datagram. TCP has no such inherent limitation,
though.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
