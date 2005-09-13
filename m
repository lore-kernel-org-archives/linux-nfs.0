From: Stefan Wuerthner <trash.wuerthner@gmx.de>
Subject: Sporadic timeout problems during streaming to nfs server
Date: Wed, 14 Sep 2005 01:41:18 +0200
Message-ID: <d853fca94d.stefan@wuerthner.dyndns.org>
References: <twig.1074096221.40393@mail.uni-tuebingen.de> <20040114161124.GD31464@gw.netwinder.org> <756bb8704c.stefan@wuerthner.dyndns.org>
 <20040114171148.GA761@gw.netwinder.org>
Reply-To: stefan.wuerthner@uni-tuebingen.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFKP6-0002xm-LI
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 16:41:32 -0700
Received: from pop.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EFKP5-0003TW-1N
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 16:41:32 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040114171148.GA761@gw.netwinder.org>
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

- I have the following setup:

DBox (DVB-C receiver, 10BaseT) connected to
100MBit-Switch connected over 10m TP to
100MBit-Switch connected over 5m TP to
Netwinder (Linux server, 100BaseT)

- Export options on the Netwinder (Kernel 2.4.19-rmk7-nw1):

dbox2(rw,insecure,all_squash)

- Mount options on the DBox (Kernel 2.4.31-dbox2) to stream the DVB-TS:

rw,soft,udp,nolock,rsize=8192,wsize=8192

- This results in:

192.168.24.50:/home/wuerthne on /mnt/filme type nfs (rw,v3,rsize=8192,
wsize=8192,soft,udp,nolock,addr=192.168.24.50)


Unfortunately, I sometimes get a timeout error in the serial logfile of my
DBox:

[Tue Sep 13 19:15:49 2005]nfs: server 192.168.24.50 not responding, timed out
[Tue Sep 13 19:15:49 2005][stream2file]: error in write: Input/output error
[Tue Sep 13 19:15:51 2005][stream2file] pthreads exit code: 4294967293
[Tue Sep 13 19:15:56 2005][neutrino.cpp] executing /var/tuxbox/config/recording.start.
[Tue Sep 13 19:15:57 2005]Record channel_id: 44d00016dcd epg: 44d00016dcda60c, apids  mode 1
[Tue Sep 13 19:46:43 2005]nfs: server 192.168.24.50 not responding, timed out
[Tue Sep 13 19:46:43 2005][stream2file]: error in write: Input/output error
[Tue Sep 13 19:46:44 2005][stream2file] pthreads exit code: 4294967293
[Tue Sep 13 19:46:49 2005][neutrino.cpp] executing /var/tuxbox/config/recording.start.

E.g. the client recognizes a timeout and restarts the recording. This
results in two ore more fragments which is not desirable.

For some time now, I played with different NFS options, changed switches and
so on but to no avail. Sometimes I can stream 5GB without problems,
sometimes the timeout occurs after a short period of time.


Any ideas what I can change or how I can diagnose this problem further to
avoid the timeouts?


Stefan

-- 
-----------------------------------------------------------------------------
Stefan Wuerthner                             web  http://wuerthner.dyndns.org
-----------------------------------------------------------------------------


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
