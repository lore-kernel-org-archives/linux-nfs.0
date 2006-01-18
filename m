From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: Stale nfs file handle - cwd without path - workaround?
Date: Wed, 18 Jan 2006 19:18:17 +0100
Message-ID: <200601181918.18475.bernd-schubert@gmx.de>
References: <1137402966.3299.251938119@webmail.messagingengine.com> <200601170043.18048.bernd-schubert@gmx.de> <1137487511.18746.252023882@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzHtG-00067V-Mw
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 10:18:38 -0800
Received: from mail.gmx.net ([213.165.64.21])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EzHtD-0004Lu-TS
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 10:18:38 -0800
To: "Wally Winchester" <wally_winchester@fastmail.fm>
In-Reply-To: <1137487511.18746.252023882@webmail.messagingengine.com>
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

Hi Wally,

sorry for the late response, but I'm very busy right now.

> The setup is two virtual machines on VMWare ESX server.
> They talk to a shared partition which is really a disk file on a SAN.
>
> Perhaps interestingly, this works:
>  cd /nfs-mount/
>  touch file
>  (failover)
>  touch file
>  (stale nfs file handle)
>  cd .
>  touch file
>  (works)
>
> $ cat /etc/exports
> /srv/nfs *(rw,no_root_squash,insecure,sync)
>
> $ ls -la /var/lib/|grep nfs
>            nfs -> /srv/nfs/nfs/
>
> $ ls /srv/nfs/nfs/
> etab rmtab sm state xtab
>
> This is a Debian Sarge install.

Which kernel version are you using? If its the debian kernel try a newer on=
e=20
(on the client and on the server). Rather probably its not related, but you=
=20
should also add an fsid entry to your exports.
Sorry, can't help more, since I'm absolutely not familar with your virtual=
=20
machine + SAN setup.

Cheers,
	Bernd


=2D-=20
Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
