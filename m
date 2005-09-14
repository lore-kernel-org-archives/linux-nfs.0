From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Sporadic timeout problems during streaming to nfs server
Date: Wed, 14 Sep 2005 07:00:15 -0700
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E43F@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFXol-0004Lo-9i
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 07:00:55 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EFXol-0003b5-3B
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 07:00:55 -0700
To: "Stefan Wuerthner" <trash.wuerthner@gmx.de>
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

> In message=20
> <044B81DE141D7443BCE91E8F44B3C1E288E43C@exsvl02.hq.netapp.com>
>  you wrote:
>=20
> > don't use the "soft" option -- use "hard" instead.  "soft"=20
> with "udp" is
> > a sure recipe for data corruption and the very symptoms you describe
> > below.=20
> >=20
>=20
> I already tried "hard", but without success:
>=20
> The serial log tells me:
>=20
> [Fri Sep  9 11:50:20 2005]
> nfs: server 192.168.24.50 not responding, still trying
> [Fri Sep  9 12:58:53 2005]
> PANIC: not enough space in ringbuffer, available 42887, needed 93225
>=20
>=20
> E.g. the client cannot reach the server and therefore the=20
> client ringbuffer
> overflows. This results in a total lockup of the client...

a ring buffer overflow is a NIC driver problem.  the NFS timeout issues
suggest a network problem (either the link or the NICs or...).  i would
start looking closely at your client-side network (driver version,
hardware, cabling, switch, etc).

in the long run you want to use NFS over TCP rather than UDP (and don't
use "soft").

> > > -----Original Message-----
> > > From: Stefan Wuerthner [mailto:trash.wuerthner@gmx.de]=20
> > > Sent: Tuesday, September 13, 2005 8:02 PM
> > > To: nfs@lists.sourceforge.net
> > > Subject: [NFS] Sporadic timeout problems during streaming to=20
> > > nfs server
> > >=20
> > > - I have the following setup:
> > >=20
> > > DBox (DVB-C receiver, 10BaseT) connected to
> > > 100MBit-Switch connected over 10m TP to
> > > 100MBit-Switch connected over 5m TP to
> > > Netwinder (Linux server, 100BaseT)
> > >=20
> > > - Export options on the Netwinder (Kernel 2.4.19-rmk7-nw1):
> > >=20
> > > dbox2(rw,insecure,all_squash)
> > >=20
> > > - Mount options on the DBox (Kernel 2.4.31-dbox2) to stream=20
> > > the DVB-TS:
> > >=20
> > > rw,soft,udp,nolock,rsize=3D8192,wsize=3D8192
> > >=20
> > > - This results in:
> > >=20
> > > 192.168.24.50:/home/wuerthne on /mnt/filme type nfs=20
> (rw,v3,rsize=3D8192,
> > > wsize=3D8192,soft,udp,nolock,addr=3D192.168.24.50)
> > >=20
> > >=20
> > > Unfortunately, I sometimes get a timeout error in the serial=20
> > > logfile of my
> > > DBox:
> > >=20
> > > [Tue Sep 13 19:15:49 2005]nfs: server 192.168.24.50 not=20
> > > responding, timed out
> > > [Tue Sep 13 19:15:49 2005][stream2file]: error in write:=20
> > > Input/output error
> > > [Tue Sep 13 19:15:51 2005][stream2file] pthreads exit=20
> code: 4294967293
> > > [Tue Sep 13 19:15:56 2005][neutrino.cpp] executing=20
> > > /var/tuxbox/config/recording.start.
> > > [Tue Sep 13 19:15:57 2005]Record channel_id: 44d00016dcd epg:=20
> > > 44d00016dcda60c, apids  mode 1
> > > [Tue Sep 13 19:46:43 2005]nfs: server 192.168.24.50 not=20
> > > responding, timed out
> > > [Tue Sep 13 19:46:43 2005][stream2file]: error in write:=20
> > > Input/output error
> > > [Tue Sep 13 19:46:44 2005][stream2file] pthreads exit=20
> code: 4294967293
> > > [Tue Sep 13 19:46:49 2005][neutrino.cpp] executing=20
> > > /var/tuxbox/config/recording.start.
> > >=20
> > > E.g. the client recognizes a timeout and restarts the=20
> recording. This
> > > results in two ore more fragments which is not desirable.
> > >=20
> > > For some time now, I played with different NFS options,=20
> > > changed switches and
> > > so on but to no avail. Sometimes I can stream 5GB without=20
> problems,
> > > sometimes the timeout occurs after a short period of time.
> > >=20
> > >=20
> > > Any ideas what I can change or how I can diagnose this=20
> > > problem further to
> > > avoid the timeouts?
> > >=20
> > >=20
> > > Stefan
> > >=20
>=20
>=20
> --=20
> --------------------------------------------------------------
> ---------------
> Stefan Wuerthner                             web =20
http://wuerthner.dyndns.org
------------------------------------------------------------------------
-----


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server.=20
Download it for free - -and be entered to win a 42" plasma tv or your
very
own Sony(tm)PSP.  Click here to play:
http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
