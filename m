From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount in a changing network
Date: Fri, 17 Feb 2006 13:36:07 -0500
Message-ID: <1140201367.7879.4.camel@lade.trondhjem.org>
References: <200602151716.18601.strieder@informatik.uni-kl.de>
	 <200602161116.24884.strieder@informatik.uni-kl.de>
	 <1140192487.3612.23.camel@lade.trondhjem.org>
	 <200602171755.33419.bernd.schubert@pci.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
	Bernd Strieder <strieder@informatik.uni-kl.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FAASr-0002VZ-JT
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 10:36:21 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FAASp-00085B-Px
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 10:36:21 -0800
To: bernd-schubert@gmx.de
In-Reply-To: <200602171755.33419.bernd.schubert@pci.uni-heidelberg.de>
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

On Fri, 2006-02-17 at 17:55 +0100, Bernd Schubert wrote:
> > The basic rule of thumb follows directly from 1:
> >
> >         If you have clients that have mounted a given partition, then do
> >         _not_ bring up the server until you have set up all the exports.
> >
> > IOW: if you want to move the clients from one server to another, then
> > the sequence is
> >
> >  1) Kill nfsd on _both_ servers
> >  2) Move the IP address from server 1 to server 2
> >  3) Add the exports for the clients from server 1 to /etc/exports on
> > server 2 (and possibly run exportfs)
> >  4) Now bring nfsd up on server 2.
> >
> 
> We also always set fsid entries in the exports, to prevent problems if device 
> names accidentely change.
> 
> 
> Btw, information like this should be managed in a wiki, recently I found 
> http://wiki.linux-nfs.org, but it seems mainly related to NFSv4. Does 
> somebody mind if I would do some modifications there?

Feel free. I don't think we need to limit the subject matter to NFSv4 in
that wiki.

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
