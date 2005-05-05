From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: export loopback mounted .iso`s failed
Date: Thu, 05 May 2005 19:03:02 -0400
Message-ID: <1115334182.12780.141.camel@lade.trondhjem.org>
References: <31436.1114712840@www27.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: for_spam@gmx.de
In-Reply-To: <31436.1114712840@www27.gmx.net>
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

to den 28.04.2005 Klokka 20:27 (+0200) skreiv for_spam@gmx.de:
> Hello !
> I have a cdrom-server based on SuSE 9.1 (kernel 2.6.4) wich exports all it
> cd-roms via nfs, too.

Are these stored as ISO-files or are they really cdroms in some jukebox
type device?

> All CD-Roms (>50 so far) are loopback mounted on the server and exported to
> the public as a single nfs-share "server:/cdroms"
> 
> this works perfectly so far - but now i realize that this doesn`t seem to
> work under suse 9.3 (kernel 2.6.11) anymore, because of (kernel based)
> nfsV4. I just don`t see the contents of the loopback mounted iso`s - just
> empty shares.

Why do you think NFSv4 would matter?

Anyhow, exports of loopback mounted iso-files works fine for me both
with and without NFSv4 support:

lade:~# uname -a
Linux lade.trondhjem.org 2.6.12-rc3-up #1 Mon Apr 25 08:59:39 EDT 2005 i686 GNU/Linux
lade:~# mount -ro,loop=/dev/loop/0 /home/linux/Ubuntu/ubuntu-5.04-live-i386.iso /mnt
lade:~# exportfs -rv
exportfs: /etc/exports [6]: No 'sync' or 'async' option specified for export "localhost:/mnt".
  Assuming default behaviour ('sync').
  NOTE: this default has changed from previous versions
exporting lade.trondhjem.org:/mnt
reexporting lade.trondhjem.org:/mnt to kernel
lade:~# mount -t nfs -oro localhost:/mnt /tmp/gnurr
lade:~# ls /tmp/gnurr/
README.diskdefines  disctree  isolinux    preseed    start.ini
autorun.inf         dists     md5sum.txt  programs   tools
bin                 doc       pics        start.bmp  ubuntu
casper              install   pool        start.exe

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
