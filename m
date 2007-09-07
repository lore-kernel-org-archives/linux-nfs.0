From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: problems with lockd in 2.6.22.6
Date: Fri, 7 Sep 2007 17:49:55 +0200
Message-ID: <200709071749.55760.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hello,

we upgraded the kernel of a nfs-server from 2.6.17.11 to 2.6.22.6. Sinc=
e then we get the message

lockd: too many open TCP sockets, consider increasing the number of nfs=
d threads
lockd: last TCP connect from ^\\236^\=C9^D

1) These random characters in the second line are caused by a bug in sv=
c_tcp_accept.
I already posted this patch on netdev@vger.kernel.org:

Signed-off-by: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
--- linux-2.6.22.6/net/sunrpc/svcsock.c	2007-08-27 18:10:14.000000000 +=
0200
+++ linux-2.6.22.6w/net/sunrpc/svcsock.c	2007-09-03 18:27:30.000000000 =
+0200
@@ -1090,7 +1090,7 @@
 						   serv->sv_name);
 				printk(KERN_NOTICE
 				       "%s: last TCP connect from %s\n",
-				       serv->sv_name, buf);
+				       serv->sv_name, __svc_print_addr(sin, buf, sizeof(buf)));
 			}
 			/*
 			 * Always select the oldest socket. It's not fair,


with this patch applied one gets something like

lockd: too many open TCP sockets, consider increasing the number of nfs=
d threads
lockd: last TCP connect from 10.11.0.12, port=3D784


2) The number of nfsd threads we are running on the machine is 1024. So=
 this is not
the problem. It seems, though, that in the case of lockd svc_tcp_accept=
 does not
check the number of nfsd threads but the number of lockd threads which =
is one.
As soon as the number of open lockd sockets surpasses 80 this message g=
ets logged.
This usually happens every evening when a lot of people shutdown their =
workstation.

3) For unknown reason these sockets then remain open. In the morning wh=
en people
start their workstation again we therefor not only get a lot of these m=
essages
again but often the nfs-server does not proberly work any more. Restart=
ing the
nfs-daemon is a workaround.

Reagrds,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
