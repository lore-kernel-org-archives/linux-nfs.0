From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale nfs file handle - cwd without path - workaround?
Date: Wed, 18 Jan 2006 16:05:49 -0500
Message-ID: <1137618350.8706.27.camel@lade.trondhjem.org>
References: <1137402966.3299.251938119@webmail.messagingengine.com>
	 <200601170043.18048.bernd-schubert@gmx.de>
	 <1137573819.15439.252122025@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bernd Schubert <bernd-schubert@gmx.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzKVc-0005yj-Vm
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:06:24 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzKVb-0008UD-Bn
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:06:24 -0800
To: Wally Winchester <wally_winchester@fastmail.fm>
In-Reply-To: <1137573819.15439.252122025@webmail.messagingengine.com>
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

On Wed, 2006-01-18 at 08:43 +0000, Wally Winchester wrote:
> > > When nfs1 dies, and nfs2 takes over, everything works - as long as the
> > > clients are writing files using the full paths.
> > > If the path is omitted, i.e. they are expecting a write to their cwd, a
> > > "stale nfs file handle" warning is issued.
> > >
> > > Is there a way around this?
> > >
> > > e.g. this works
> > > touch /nfs-mount/file
> > > (failover)
> > > touch /nfs-mount/file
> > >
> > > e.g. this doesn't work
> > > cd /nfs-mount/
> > > touch file
> > > (failover)
> > > touch file
> > > (stale nfs file handle)
> > 
> > really strange, we never had this problem. I think you have to provide
> > some 
> > more information (/etc/exports of both servers, kernel version,
> > distribution, 
> > how you handle /var/lib/nfs, drbd? configuration, etc.).
> > 
> > Cheers,
> > 	Bernd
> > 
> > 
> > 
> 
> As a follow up to my reply,
> can anyone suggest how to troubleshoot this? Is there a way of getting
> an nfs client to not cache the details of the cwd (if this is the
> problem)?
> 
> I hope someone knows!

You have never actually told anybody which kernel version you are using.
My guess, however, would be either a 2.4.x kernel, or an early 2.6.x.

IOW: this sort of thing should be fixed in more recent 2.6.x kernels.
Please upgrade, and try again.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
