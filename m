From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Fri, 29 Apr 2005 10:00:07 +0200
Message-ID: <4271E987.3070507@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	<17006.13241.129839.558300@cse.unsw.edu.au>	<1114554149.4470.5.camel@localhost.localdomain> <17006.64544.860436.620665@cse.unsw.edu.au> <4271DBB3.3090402@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000209080605010107030507"
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Kris Vassallo <kris@linuxcertified.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DRQQ3-0002Gd-5O
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 01:00:15 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DRQQ2-0000TD-3b
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 01:00:15 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <4271DBB3.3090402@bio.ifi.lmu.de>
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

This is a multi-part message in MIME format.
--------------000209080605010107030507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

while I was still trying to set up some test environments,
one of our users stepped again on two stale directories, so
I fetched all the info you mentioned. The stale NFS occured
in the users home (mounted from /export/home from the server).


Neil Brown wrote

 >>>  echo 2048 > /proc/sys/sunrpc/rpc_debug
 >>>  grep . /proc/net/rpc/*/content

This is a lot because we have 60 NFS clients. I just grepped the
lines for the client on which the stale NFS occured at that moment
which is still a lot due to the many mounts:

/proc/net/rpc/auth.unix.ip/content-# expiry=2147483647 refcnt=0
/proc/net/rpc/auth.unix.ip/content:nfsd 141.84.1.156 cauchy.bio.ifi.lmu.de
--
/proc/net/rpc/nfsd.export/content-# expiry=2147483647 refcnt=1
/proc/net/rpc/nfsd.export/content:/ 
cauchy.bio.ifi.lmu.de(ro,no_root_squash,sync,wdelay)
--
/proc/net/rpc/nfsd.export/content-# expiry=2147483647 refcnt=1
/proc/net/rpc/nfsd.export/content:/export/clientpass 
cauchy.bio.ifi.lmu.de(ro,no_root_squash,sync,wdelay)
--
/proc/net/rpc/nfsd.export/content-# expiry=2147483647 refcnt=1
/proc/net/rpc/nfsd.export/content:/export/clientroot 
cauchy.bio.ifi.lmu.de(rw,no_root_squash,sync,wdelay)
--
/proc/net/rpc/nfsd.export/content-# expiry=2147483647 refcnt=1
/proc/net/rpc/nfsd.export/content:/var  cauchy.bio.ifi.lmu.de(ro,root_squash,sync,wdelay)
--
/proc/net/rpc/nfsd.export/content-# expiry=2147483647 refcnt=1
/proc/net/rpc/nfsd.export/content:/export/diskless/141.84.1.156 
cauchy.bio.ifi.lmu.de(rw,no_root_squash,sync,wdelay)
--
/proc/net/rpc/nfsd.export/content-# expiry=2147483647 refcnt=1
/proc/net/rpc/nfsd.export/content:/export/home 
cauchy.bio.ifi.lmu.de(rw,root_squash,sync,wdelay)
--
/proc/net/rpc/nfsd.fh/content-# expiry=2147483647 refcnt=0
/proc/net/rpc/nfsd.fh/content:cauchy.bio.ifi.lmu.de 0 0x0200080000000002 /var
--
/proc/net/rpc/nfsd.fh/content-# expiry=2147483647 refcnt=0
/proc/net/rpc/nfsd.fh/content:cauchy.bio.ifi.lmu.de 0 0x0100fc0000000004 
/export/clientpass
--
/proc/net/rpc/nfsd.fh/content-# expiry=2147483647 refcnt=0
/proc/net/rpc/nfsd.fh/content:cauchy.bio.ifi.lmu.de 0 0x0100080000000002 /
--
/proc/net/rpc/nfsd.fh/content-# expiry=2147483647 refcnt=0
/proc/net/rpc/nfsd.fh/content:cauchy.bio.ifi.lmu.de 0 0x0100fc000000000b 
/export/clientroot
--
/proc/net/rpc/nfsd.fh/content-# expiry=2147483647 refcnt=0
/proc/net/rpc/nfsd.fh/content:cauchy.bio.ifi.lmu.de 0 0x0100fc0000002e4a 
/export/diskless/141.84.1.156
--
/proc/net/rpc/nfsd.fh/content-# expiry=2147483647 refcnt=0
/proc/net/rpc/nfsd.fh/content:cauchy.bio.ifi.lmu.de 0 0x0000fc0000000002 /export/home


 >>>  ls -l /proc/fs/nfsd

babbage /root/tmp# ls -l /proc/fs/nfsd
total 0
dr-xr-xr-x    2 root     root            0 Apr 29 09:44 .
dr-xr-xr-x    4 root     root            0 Apr 29 09:44 ..

? Should there be sth?


 >>>  cat /proc/fs/nfs/exports

babbage /root/tmp# cat /proc/fs/nfs/exports |grep cauchy
/       cauchy.bio.ifi.lmu.de(ro,no_root_squash,sync,wdelay)
/export/clientpass      cauchy.bio.ifi.lmu.de(ro,no_root_squash,sync,wdelay)
/export/clientroot      cauchy.bio.ifi.lmu.de(rw,no_root_squash,sync,wdelay)
/var    cauchy.bio.ifi.lmu.de(ro,root_squash,sync,wdelay)
/export/diskless/141.84.1.156   cauchy.bio.ifi.lmu.de(rw,no_root_squash,sync,wdelay)
/export/home    cauchy.bio.ifi.lmu.de(rw,root_squash,sync,wdelay)


Additionally, here are the relevant mount options on the client:

cauchy /root# mount | grep 141.84.1.131
/dev/root on / type nfs 
(rw,v3,rsize=16384,wsize=16384,hard,intr,tcp,nolock,addr=141.84.1.131)
141.84.1.131://export/diskless/141.84.1.156//etc/local on /etc/local type nfs 
(rw,v3,rsize=16384,wsize=16384,hard,intr,tcp,nolock,addr=141.84.1.131)
141.84.1.131://export/diskless/141.84.1.156//var on /var type nfs 
(rw,v3,rsize=16384,wsize=16384,hard,intr,tcp,nolock,addr=141.84.1.131)
141.84.1.131:/boot on /boot type nfs 
(ro,tcp,hard,intr,rsize=16384,wsize=16384,addr=141.84.1.131)
141.84.1.131:/var/adm on /var/adm type nfs 
(ro,tcp,hard,intr,rsize=16384,wsize=16384,addr=141.84.1.131)
141.84.1.131:/var/lib/texmf on /var/lib/texmf type nfs 
(ro,tcp,hard,intr,rsize=16384,wsize=16384,addr=141.84.1.131)
141.84.1.131:/var/lib/rpm on /var/lib/rpm type nfs 
(ro,tcp,hard,intr,rsize=16384,wsize=16384,addr=141.84.1.131)
141.84.1.131:/var/log/apache2 on /var/httpd type nfs 
(ro,tcp,hard,intr,rsize=16384,wsize=16384,addr=141.84.1.131)
141.84.1.131:/export/clientpass on /export type nfs 
(ro,tcp,hard,intr,rsize=16384,wsize=16384,addr=141.84.1.131)
141.84.1.131:/export/clientroot on /export/localhome/root type nfs 
(rw,tcp,hard,intr,rsize=16384,wsize=16384,addr=141.84.1.131)
babbage:/export/home on /home type nfs 
(rw,tcp,hard,rsize=16384,wsize=16384,addr=141.84.1.131)



 > So, when it happens again, please check that the IP address of the
 > client really is in /proc/net/rpc/auth.unix.ip/content and then

Yes, it was definitely there:
babbage /root/tmp# grep 141.84.1.156 /proc/net/rpc/auth.unix.ip/content
nfsd 141.84.1.156 cauchy.bio.ifi.lmu.de


 >
 >   echo 1023 > /proc/sys/sunrpc/nfsd_debug
 > on the server.
 > Then on the client,
 >   cd $HOME
 >   ls -l the/offending/directory

This is amazing: This ls does work, while the one in the shell
where the stale occured still don't work. So the directory
is only stale in on shell and not stale in the other shell.
I thought that the stale should would have recovered, too...

 > See if that works, and see what you get in the kernel logs.

We did the following:
1) echo 1023 > /proc/sys/sunrpc/nfsd_debug
2) the user did a ls in the stale directory, and got the stale message
    again
3) the user did a "ls <the directory>" from another shell and got
    the contents of the directory
4) the user did a ls in the stale shell and go the stale messages
    again
5) echo 0 > /proc/sys/sunrpc/nfsd_debug

So I hope that the log does not contain too much other, useless
information.


Let me know if I can provide more information!

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

--------------000209080605010107030507
Content-Type: application/x-bzip;
 name="nfsd.debug.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="nfsd.debug.bz2"

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
uzA=
--------------000209080605010107030507--


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
