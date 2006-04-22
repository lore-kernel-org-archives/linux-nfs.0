From: hugo vanwoerkom <hugovanwoerkom@yahoo.com>
Subject: statd not binding to ports
Date: Sat, 22 Apr 2006 04:35:59 -0700 (PDT)
Message-ID: <20060422113559.98524.qmail@web53308.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FXGPK-0001Hg-0Y
	for nfs@lists.sourceforge.net; Sat, 22 Apr 2006 04:36:10 -0700
Received: from web53308.mail.yahoo.com ([206.190.49.98])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FXGPI-0002Iq-KA
	for nfs@lists.sourceforge.net; Sat, 22 Apr 2006 04:36:10 -0700
To: nfs@lists.sourceforge.net
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

Hi,

I've been through the NFS-HOWTO and have decided to
bind the rpc daemons to specified ports. I have been
successful with all but one daemon: rpc.statd.

I found a very old post in the archives that details
my problems exactly:
http://marc.theaimsgroup.com/?l=3Dlinux-nfs&m=3D103547835112190&w=3D1
but that never got answered...

I run Debian Stable with statd 1.0.6 and specified for
statd:
"-p 32765 -o 32766"

just the way the HOWTO does it. But running then
netstat -tnupl
I get:

...
tcp        0      0 0.0.0.0:865             0.0.0.0:*=20
             LISTEN     5347/rpc.statd
...
udp        0      0 0.0.0.0:859             0.0.0.0:*=20
                        5347/rpc.statd
udp        0      0 0.0.0.0:862             0.0.0.0:*=20
                        5347/rpc.statd
...

Anybody know what the solution to this is?

Thanks!

Hugo



__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam
protection around=20
http://mail.yahoo.com=20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job ea=
sier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronim=
o
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
