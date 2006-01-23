From: "Wally Winchester" <wally_winchester@fastmail.fm>
Subject: Re: Stale nfs file handle - cwd without path - workaround?
Date: Mon, 23 Jan 2006 13:23:29 +0000
Message-ID: <1138022609.27117.252501150@webmail.messagingengine.com>
References: <1137402966.3299.251938119@webmail.messagingengine.com>   
   <200601170043.18048.bernd-schubert@gmx.de>   
   <1137487511.18746.252023882@webmail.messagingengine.com>   
   <200601181918.18475.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F11fV-0000Ut-Tk
	for nfs@lists.sourceforge.net; Mon, 23 Jan 2006 05:23:37 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F11fU-0005pZ-FX
	for nfs@lists.sourceforge.net; Mon, 23 Jan 2006 05:23:37 -0800
To: "Bernd Schubert" <bernd-schubert@gmx.de>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <200601181918.18475.bernd-schubert@gmx.de>
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

On Wed, 18 Jan 2006 19:18:17 +0100, "Bernd Schubert"
<bernd-schubert@gmx.de> said:
> Hi Wally,
>=20
> sorry for the late response, but I'm very busy right now.
>=20
> > The setup is two virtual machines on VMWare ESX server.
> > They talk to a shared partition which is really a disk file on a SAN.
> >
> > Perhaps interestingly, this works:
> >  cd /nfs-mount/
> >  touch file
> >  (failover)
> >  touch file
> >  (stale nfs file handle)
> >  cd .
> >  touch file
> >  (works)
> >
> > $ cat /etc/exports
> > /srv/nfs *(rw,no_root_squash,insecure,sync)
> >
> > $ ls -la /var/lib/|grep nfs
> >            nfs -> /srv/nfs/nfs/
> >
> > $ ls /srv/nfs/nfs/
> > etab rmtab sm state xtab
> >
> > This is a Debian Sarge install.
>=20
> Which kernel version are you using? If its the debian kernel try a newer
> one=20
> (on the client and on the server). Rather probably its not related, but
> you=20
> should also add an fsid entry to your exports.
> Sorry, can't help more, since I'm absolutely not familar with your
> virtual=20
> machine + SAN setup.
>=20
> Cheers,
> 	Bernd
>=20
>=20
> --=20
> Bernd Schubert
> PCI / Theoretische Chemie
> Universit=E4t Heidelberg
> INF 229
> 69120 Heidelberg
>=20


Hello,

Thanks very much for the replies.

The client is running 2.6.12-1.1398_FC4smp
The server is now Ubuntu, running 2.6.12-9-686.

Ubuntu seems to work better (although not as I would expect).
After the failover, it takes 10-15 minutes for a result to come back. Is
there some way of tuning this?
To make this worse, not all files written to one nfs server show on the
other after the failover.

I have tried setting the fsid, but it doesn't seem to help either.


The setup: Two virtual machines, connected by heartbeat. When heartbeat
is stopped on one machine, it shuts down nfs-kernel-server, unmounts the
shared scsi drive, and the other mounts it, and starts-nfs-server. They
also have a shared ip which works in the same way. The shared scsi disk
is really a vmware disk image which is shared using "physical" sharing
in the vmware setup.

Eck!
--=20
  Wally Winchester
  wally_winchester@fastmail.fm

--=20
http://www.fastmail.fm - The way an email service should be



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
