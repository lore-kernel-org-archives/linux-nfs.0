From: Riccardo Tritto <riccardo.tritto@gmail.com>
Subject: Permission issues
Date: Sat, 10 Jul 2010 21:34:55 +0200
Message-ID: <AANLkTimNfc_NFfsdj1wApWzyIfsU5O2k4uoFEUCRx5Gq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56534 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab0GJTfS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Jul 2010 15:35:18 -0400
Received: by wyf23 with SMTP id 23so2504930wyf.19
        for <linux-nfs@vger.kernel.org>; Sat, 10 Jul 2010 12:35:17 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi everyone,

I'm having some headache configuring nfs on my nas on which I've
installed Debian Lenny.

Basically it works, but I can access the shares of my nas only if
their permissions allow everyone. Having the right "group" permissions
is not enough, and I get a "Permission denied" when I try to access
directories where I should have "group" access.

Of course usernames, uids and gids are the same between the machines,
and my user is in the right groups.

Here are some more details:


root@nas ~ # cat /etc/exports
/home 192.168.0.1(rw,sync,no_subtree_check)

root@nas ~ # cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/home   192.168.0.1
(rw,root_squash,sync,wdelay,no_subtree_check,uuid=aaff1cde:08674ab9:97d5909a:214f393a)

rk@alfa ~ $ grep nfs /etc/fstab
nas:/home /mnt/nas nfs noauto,rw,hard,intr 0 0

rk@alfa ~ $ grep nfs /proc/mounts
rpc_pipefs /var/lib/nfs/rpc_pipefs rpc_pipefs rw,relatime 0 0
nfsd /proc/fs/nfsd nfsd rw,relatime 0 0
nas:/home /mnt/nas nfs
rw,relatime,vers=3,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.0.101,mountvers=3,mountport=34015,mountproto=udp,addr=192.168.0.101
0 0

root@nas ~ # ls -ld /home/test
drwxr-x--- 2 root doc 4.0K Jul  3 20:39 /home/test

rk@alfa ~ $ ls -ld /mnt/nas/test
drwxr-x--- 2 root doc 4,0K  3 lug 20.39 /mnt/nas/test

rk@nas ~ $ ls -la /home/test/
total 8.0K
drwxr-x---  2 root doc  4.0K Jul  3 21:25 ./
drwxr-xr-x 19 root root 4.0K Jul  3 20:56 ../
-rw-r-----  1 root doc     0 Jul  3 21:25 testfile.txt

rk@alfa ~ $ LC_ALL=POSIX ls /mnt/nas/test/
ls: cannot open directory /mnt/nas/test/: Permission denied

rk@alfa ~ $ LC_ALL=POSIX id | grep doc
uid=500(rk) gid=500(rk)
groups=500(rk),4(adm),6(disk),7(lp),8(mail),9(news),20(dialout),21(fax),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),34(backup),40(src),44(video),46(plugdev),60(games),100(users),108(powerdev),109(scanner),120(polkituser),124(vboxusers),200(wheel),510(rknet),511(contab),512(ppp),513(inst),514(mount),515(rsync),516(software),517(film),518(modem),520(wine),521(mp3),523(log),525(kernel),527(rep),528(htman),529(cdsearch),530(foto),531(samba),532(firewire),535(sd),536(sm),537(cf),538(ms),539(mmread),540(pen0),541(pen1),542(pen2),543(pen3),544(pen4),545(pen5),546(pen6),547(pen7),549(win),550(doc),552(dos),553(xwin),554(cdrw),555(dvdrw),556(dvd),557(checkinstall),558(ipod),559(roms),561(alfa),562(beta),563(gamma),564(delta),565(sat),566(media),567(nas),571(usb30),572(usb40),573(usb200)

rk@nas ~ $ id | grep doc
uid=500(rk) gid=500(rk)
groups=4(adm),6(disk),7(lp),8(mail),9(news),20(dialout),21(fax),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),34(backup),40(src),44(video),46(plugdev),60(games),100(users),104(powerdev),500(rk),510(rknet),511(contab),512(ppp),513(inst),514(mount),515(rsync),516(software),517(film),518(modem),520(wine),521(mp3),523(log),525(kernel),527(rep),528(htman),529(cdsearch),530(foto),531(samba),532(firewire),535(sd),536(sm),537(cf),538(ms),539(mmread),540(pen0),541(pen1),542(pen2),543(pen3),544(pen4),545(pen5),546(pen6),547(pen7),549(win),550(doc),552(dos),553(xwin),554(cdrw),555(dvdrw),556(dvd),557(checkinstall),558(ipod),559(roms),561(alfa),562(beta),563(gamma),564(delta),565(sat),566(media),571(usb30),572(usb40),573(usb200)

It seems an "ordinary" permission problem, but "ordinary" solutions
don't seem to work...

I've read all the man pages about nfs, nfsd, exports, etc., particularly here:
http://nfs.sourceforge.net/nfs-howto/ar01s07.html#pemission_issues
and the NFS-HOWTO, searched with Google, etc. etc., but I still
haven't found any
solution.

Thank you in advance for your answers.
