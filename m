From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: client oddity
Date: Tue, 4 Jul 2006 18:21:47 +0200
Message-ID: <200607041821.48887.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FxneB-0005Jc-LS
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 09:21:11 -0700
Received: from mail.gmx.de ([213.165.64.21] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1FxneA-0002QE-8M
	for nfs@lists.sourceforge.net; Tue, 04 Jul 2006 09:21:12 -0700
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

my collegue just showed me something very strange:

bernd@zuse bernd>ll -id /home/frank/work/mctdh83
668731 drwxr-xr-x  14 frank user 560 2006-05-18 14:41 /home/frank/work/mctd=
h83

bernd@gauss bernd>ll -id /home/frank/work/mctdh83
15685682 drwxr-xr-x  14 frank user 584 2006-07-04 16:17 /home/frank/work/mc=
tdh83

bernd@hamilton1 bernd>ll -id /home/frank/work/mctdh83
15685682 drwxr-xr-x  14 frank user 584 2006-07-04 16:17 /home/frank/work/mc=
tdh83

bernd@hamilton1 bernd>ll -id /home/frank/work/mctdh83.old
668731 drwxr-xr-x  14 frank user 560 2006-05-18 14:41 /home/frank/work/mctd=
h83.old

and on zuse also for mctdh83.old:

bernd@zuse bernd>ll -id /home/frank/work/mctdh83.old
668731 drwxr-xr-x  14 frank user 560 2006-05-18 14:41 /home/frank/work/mctd=
h83.old


So on zuse mctdh83 is just like a directory hard linked to mctdh83.old


Here zuse and gauss are NFS clients of the server hamilton.

Renaming mctdh83 to mctdh83.0 will give correct results on client zuse =

(and other clients and server):

15685682 drwxr-xr-x  14 frank user 584 2006-07-04 16:17 /home/frank/work/mc=
tdh83.0
  668731 drwxr-xr-x  14 frank user 560 2006-05-18 14:41 /home/frank/work/mc=
tdh83.old

Renaming mctdh83.0 back to mctdh83 will give back the oddity on host zuse.


The inode generation numbers are also different, =


bernd@hamilton1 inode_gen>./get_igen /home/frank/work/mctdh83
/home/frank/work/mctdh83: 74340560

bernd@hamilton1 inode_gen>./get_igen /home/frank/work/mctdh83.old
/home/frank/work/mctdh83.old: 177886

I also already checked that /home/frank/work/mctdh83 is also *no* bind moun=
t.

After =

cp -a mctdh83.old  mctdh83.old.test
mv mctdh83.old.test mctdh83.old
the problems on client zuse disappeared.


Any idea whats going on here? So far I couldn't reproduce for other =

directories.

bernd@zuse bernd>uname -a
Linux zuse 2.6.16.1-tc3 #2 SMP PREEMPT Thu Mar 30 14:18:59 CEST 2006 i686 G=
NU/Linux

-tc3 is only for internal configuration purposes, this is just a vanilla ke=
rnel.

Thanks,
	Bernd

-- =

Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
