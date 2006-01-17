From: "Wally Winchester" <wally_winchester@fastmail.fm>
Subject: Re: Stale nfs file handle - cwd without path - workaround?
Date: Tue, 17 Jan 2006 08:45:11 +0000
Message-ID: <1137487511.18746.252023882@webmail.messagingengine.com>
References: <1137402966.3299.251938119@webmail.messagingengine.com>
   <200601170043.18048.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EymSq-0002zR-H5
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 00:45:16 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EymSo-0004b9-CT
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 00:45:16 -0800
To: "Bernd Schubert" <bernd-schubert@gmx.de>,
	nfs@lists.sourceforge.net
In-Reply-To: <200601170043.18048.bernd-schubert@gmx.de>
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

On Tue, 17 Jan 2006 00:43:17 +0100, "Bernd Schubert"
<bernd-schubert@gmx.de> said:
> Hello Wally,
> 
> > When nfs1 dies, and nfs2 takes over, everything works - as long as the
> > clients are writing files using the full paths.
> > If the path is omitted, i.e. they are expecting a write to their cwd, a
> > "stale nfs file handle" warning is issued.
> >
> > Is there a way around this?
> >
> > e.g. this works
> > touch /nfs-mount/file
> > (failover)
> > touch /nfs-mount/file
> >
> > e.g. this doesn't work
> > cd /nfs-mount/
> > touch file
> > (failover)
> > touch file
> > (stale nfs file handle)
> 
> really strange, we never had this problem. I think you have to provide
> some 
> more information (/etc/exports of both servers, kernel version,
> distribution, 
> how you handle /var/lib/nfs, drbd? configuration, etc.).
> 
> Cheers,
> 	Bernd
> 
> 
> 

The setup is two virtual machines on VMWare ESX server.
They talk to a shared partition which is really a disk file on a SAN.

Perhaps interestingly, this works:
 cd /nfs-mount/
 touch file
 (failover)
 touch file
 (stale nfs file handle)
 cd .
 touch file
 (works)

$ cat /etc/exports
/srv/nfs *(rw,no_root_squash,insecure,sync)

$ ls -la /var/lib/|grep nfs
           nfs -> /srv/nfs/nfs/

$ ls /srv/nfs/nfs/
etab rmtab sm state xtab

This is a Debian Sarge install.
-- 
  Wally Winchester
  wally_winchester@fastmail.fm

-- 
http://www.fastmail.fm - Access all of your messages and folders
                          wherever you are



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
