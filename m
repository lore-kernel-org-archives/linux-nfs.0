From: "Randy Paries" <paries@knology.net>
Subject: NFS causing kernel panics
Date: Fri, 30 Apr 2004 13:17:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BJca7-0004Xp-Jp@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_00FB_01C42EB5.87A0FF10"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJca8-0003fM-Bt
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 11:17:52 -0700
Received: from smtp.knology.net ([24.214.63.101] helo=smtp5.knology.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BJca7-0004Xp-Jp
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 11:17:51 -0700
To: <nfs@lists.sourceforge.net>
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

------=_NextPart_000_00FB_01C42EB5.87A0FF10
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,
 
I have a machine that is a nfs client. It keeps having kernel panics
 
i have included some from the log file
 
Both the client and server are very busy
 
I am not sure how to debug and i am looking for some direction
Thanks
----------------------------------------------------------------------------
----------------------------------------------------------------------------
------------------------------------
 
Apr 30 11:27:47 krusty kernel: nfs: server local.flanders not responding,
still trying
Apr 30 11:27:53 krusty kernel: nfs: server local.flanders OK
Apr 30 11:35:04 krusty kernel: divide error: 0000
Apr 30 11:35:04 krusty kernel: autofs nfs lockd sunrpc e100 e1000 keybdev
mousedev hid input usb-uhci usbcore ext3 jbd raid1 dpt_i2o aic7xxx sd_mod
scsi_mod
Apr 30 11:35:04 krusty kernel: CPU:    0
Apr 30 11:35:04 krusty kernel: EIP:    0060:[<c012db94>]    Not tainted
Apr 30 11:35:04 krusty kernel: EFLAGS: 00010246
Apr 30 11:35:04 krusty kernel:
Apr 30 11:35:04 krusty kernel: EIP is at schedule_timeout [kernel] 0x64
(2.4.20-31.9smp)
Apr 30 11:35:04 krusty kernel: eax: 00000000   ebx: 000299af   ecx: f1408b80
edx: 00000000
Apr 30 11:35:04 krusty kernel: esi: e8273f1c   edi: 00000000   ebp: 00000000
esp: e8273f10
Apr 30 11:35:04 krusty kernel: ds: 0068   es: 0068   ss: 0068
Apr 30 11:35:04 krusty kernel: Process httpd (pid: 4397, stackpage=e8273000)
Apr 30 11:35:04 krusty kernel: Stack: e8273f1c c02080fc 00000000 e8e7f968
e8de3f1c 000299af e8272000 c012db20
Apr 30 11:35:04 krusty kernel:        e8273fa8 00000000 bfffe7c0 00000000
bfffe7c0 c0166ba6 00000001 eb554000
Apr 30 11:35:04 krusty kernel:        e8273f60 e8273f64 e8272000 e8272000
00000000 00000000 000005dd bfffe7c0
Apr 30 11:35:04 krusty kernel: Call Trace:   [<c02080fc>] sock_poll [kernel]
0x2c (0xe8273f14))
Apr 30 11:35:04 krusty kernel: [<c012db20>] process_timeout [kernel] 0x0
(0xe8273f2c))
Apr 30 11:35:04 krusty kernel: [<c0166ba6>] do_pollfd [kernel] 0x166
(0xe8273f44))
Apr 30 11:35:04 krusty kernel: [<c0166d7b>] sys_poll [kernel] 0x17b
(0xe8273f78))
Apr 30 11:35:04 krusty kernel: [<c01098cf>] system_call [kernel] 0x33
(0xe8273fc0))
Apr 30 11:35:04 krusty kernel:
Apr 30 11:35:04 krusty kernel:
Apr 30 11:35:04 krusty kernel: Code: f7 ff ff a1 64 a9 3f c0 29 c6 31 c0 85
f6 8b 5c 24 2c 0f 49
Apr 30 12:07:24 krusty syslogd 1.4.1: restart.
Apr 30 12:07:24 krusty syslog: syslogd startup succeeded
Apr 30 12:07:24 krusty kernel: klogd 1.4.1, log source = /proc/kmsg started.
Apr 30 12:07:24 krusty kernel: Linux version 2.4.20-31.9smp
(bhcompile@daffy.perf.redhat.com) (gcc version 3.2.2 20030222 (Red Hat Linux
3.2.2-5)) #1 SMP Tue Apr 13 17:40:10 EDT 2004
A

------=_NextPart_000_00FB_01C42EB5.87A0FF10
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1400" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2>Hello,</FONT></SPAN></DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial size=3D2>I have =
a machine=20
that is a nfs client. It keeps having kernel panics</FONT></SPAN></DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial size=3D2>i have =
included some=20
from the log file</FONT></SPAN></DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial size=3D2>Both =
the client and=20
server are very busy</FONT></SPAN></DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial size=3D2>I am =
not sure how to=20
debug and i am looking for some direction</FONT></SPAN></DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2>Thanks</FONT></SPAN></DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2>----------------------------------------------------------------=
-------------------------------------------------------------------------=
---------------------------------------------------</FONT></SPAN></DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial=20
size=3D2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=3D953461518-30042004><FONT face=3DArial size=3D2>Apr 30 =
11:27:47=20
krusty kernel: nfs: server local.flanders not responding, still =
trying<BR>Apr 30=20
11:27:53 krusty kernel: nfs: server local.flanders OK<BR>Apr 30 11:35:04 =
krusty=20
kernel: divide error: 0000<BR>Apr 30 11:35:04 krusty kernel: autofs nfs =
lockd=20
sunrpc e100 e1000 keybdev mousedev hid input usb-uhci usbcore ext3 jbd =
raid1=20
dpt_i2o aic7xxx sd_mod scsi_mod<BR>Apr 30 11:35:04 krusty kernel:=20
CPU:&nbsp;&nbsp;&nbsp; 0<BR>Apr 30 11:35:04 krusty kernel:=20
EIP:&nbsp;&nbsp;&nbsp; 0060:[&lt;c012db94&gt;]&nbsp;&nbsp;&nbsp; Not=20
tainted<BR>Apr 30 11:35:04 krusty kernel: EFLAGS: 00010246<BR>Apr 30 =
11:35:04=20
krusty kernel:<BR>Apr 30 11:35:04 krusty kernel: EIP is at =
schedule_timeout=20
[kernel] 0x64 (2.4.20-31.9smp)<BR>Apr 30 11:35:04 krusty kernel: eax:=20
00000000&nbsp;&nbsp; ebx: 000299af&nbsp;&nbsp; ecx: f1408b80&nbsp;&nbsp; =
edx:=20
00000000<BR>Apr 30 11:35:04 krusty kernel: esi: e8273f1c&nbsp;&nbsp; =
edi:=20
00000000&nbsp;&nbsp; ebp: 00000000&nbsp;&nbsp; esp: e8273f10<BR>Apr 30 =
11:35:04=20
krusty kernel: ds: 0068&nbsp;&nbsp; es: 0068&nbsp;&nbsp; ss: 0068<BR>Apr =
30=20
11:35:04 krusty kernel: Process httpd (pid: 4397, =
stackpage=3De8273000)<BR>Apr 30=20
11:35:04 krusty kernel: Stack: e8273f1c c02080fc 00000000 e8e7f968 =
e8de3f1c=20
000299af e8272000 c012db20<BR>Apr 30 11:35:04 krusty=20
kernel:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; e8273fa8 00000000 =
bfffe7c0=20
00000000 bfffe7c0 c0166ba6 00000001 eb554000<BR>Apr 30 11:35:04 krusty=20
kernel:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; e8273f60 e8273f64 =
e8272000=20
e8272000 00000000 00000000 000005dd bfffe7c0<BR>Apr 30 11:35:04 krusty =
kernel:=20
Call Trace:&nbsp;&nbsp; [&lt;c02080fc&gt;] sock_poll [kernel] 0x2c=20
(0xe8273f14))<BR>Apr 30 11:35:04 krusty kernel: [&lt;c012db20&gt;]=20
process_timeout [kernel] 0x0 (0xe8273f2c))<BR>Apr 30 11:35:04 krusty =
kernel:=20
[&lt;c0166ba6&gt;] do_pollfd [kernel] 0x166 (0xe8273f44))<BR>Apr 30 =
11:35:04=20
krusty kernel: [&lt;c0166d7b&gt;] sys_poll [kernel] 0x17b =
(0xe8273f78))<BR>Apr=20
30 11:35:04 krusty kernel: [&lt;c01098cf&gt;] system_call [kernel] 0x33=20
(0xe8273fc0))<BR>Apr 30 11:35:04 krusty kernel:<BR>Apr 30 11:35:04 =
krusty=20
kernel:<BR>Apr 30 11:35:04 krusty kernel: Code: f7 ff ff a1 64 a9 3f c0 =
29 c6 31=20
c0 85 f6 8b 5c 24 2c 0f 49<BR>Apr 30 12:07:24 krusty syslogd 1.4.1:=20
restart.<BR>Apr 30 12:07:24 krusty syslog: syslogd startup =
succeeded<BR>Apr 30=20
12:07:24 krusty kernel: klogd 1.4.1, log source =3D /proc/kmsg =
started.<BR>Apr 30=20
12:07:24 krusty kernel: Linux version 2.4.20-31.9smp (<A=20
href=3D"mailto:bhcompile@daffy.perf.redhat.com">bhcompile@daffy.perf.redh=
at.com</A>)=20
(gcc version 3.2.2 20030222 (Red Hat Linux 3.2.2-5)) #1 SMP Tue Apr 13 =
17:40:10=20
EDT 2004<BR>A</FONT></SPAN></DIV></BODY></HTML>

------=_NextPart_000_00FB_01C42EB5.87A0FF10--




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
