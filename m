From: "Matt Heaton" <admin@webmersion.com>
Subject: NFS-FH Error....
Date: Sat, 6 Jul 2002 09:27:02 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <09a101c22501$9412cbd0$6601a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_099E_01C224CF.4922C1C0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc03.attbi.com ([204.127.202.63])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17QrSs-0002ru-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Jul 2002 08:27:14 -0700
Received: from c1886657a ([12.255.25.93]) by sccrmhc03.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020706152707.MHQD903.sccrmhc03.attbi.com@c1886657a>
          for <nfs@lists.sourceforge.net>; Sat, 6 Jul 2002 15:27:07 +0000
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_099E_01C224CF.4922C1C0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi All,=20

I am running a 2.4.18 kernal on a redhat 7.2 installation (No special =
kernel enhancements EXCEPT  a modification for my 3ware RAID IDE =
Controller).
This is for my NFS server.   My NFS server is running the REISER FS file =
system on my data partition that is exported.
In my var log messages I am constantly getting these NFSD-FH erros.   I =
am getting a couple per minute at this point afterwhich my NFS server =
finally
dies with a kernel paging error that I will show below.  This nfs-fh =
error isn't only for that file shown below that is just an example one.
If you have ANY idea what might cause this I would get VERY VERY =
grateful.

nfsd-fh: found a name that I didn't expect: =
sinthongs.bravepages.com/wood

KERNEL ERROR I Finally get...

Jul  6 08:19:19 titan2 kernel: Unable to handle kernel paging request at =
virtual address 81b74c28
Jul  6 08:19:19 titan2 kernel:  printing eip:
Jul  6 08:19:19 titan2 kernel: c013eeca
Jul  6 08:19:19 titan2 kernel: *pde =3D 00000000
Jul  6 08:19:19 titan2 kernel: Oops: 0000
Jul  6 08:19:19 titan2 kernel: CPU:    0
Jul  6 08:19:19 titan2 kernel: EIP:    0010:[<c013eeca>]    Not tainted
Jul  6 08:19:19 titan2 kernel: EFLAGS: 00010297
Jul  6 08:19:19 titan2 kernel: eax: c018ecf0   ebx: 81b74c00   ecx: =
0000ffff   edx: ca3e5e64
Jul  6 08:19:19 titan2 kernel: esi: 81b74c00   edi: 00248ec9   ebp: =
c1ef6828   esp: ca3e5e08
Jul  6 08:19:19 titan2 kernel: ds: 0018   es: 0018   ss: 0018
Jul  6 08:19:19 titan2 kernel: Process nfsd (pid: 991, =
stackpage=3Dca3e5000)
Jul  6 08:19:19 titan2 kernel: Stack: 00000003 c1ef6828 00248ec9 =
f70acc00 c013f2b5 f70acc00 00248ec9 c1ef6828=20
Jul  6 08:19:19 titan2 kernel:        c018ecf0 ca3e5e64 00000001 =
00000000 00000000 cf184dc0 00000003 ca3e5e7c=20
Jul  6 08:19:19 titan2 kernel:        ca3f1a14 00000000 c018ed34 =
f70acc00 00248ec9 c018ecf0 ca3e5e64 0000118f=20
Jul  6 08:19:19 titan2 kernel: Call Trace: [<c013f2b5>] [<c018ecf0>] =
[<c018ed34>] [<c018ecf0>] [<c018edee>]=20
Jul  6 08:19:19 titan2 kernel:    [<c017599e>] [<c0173c18>] [<c0173fde>] =
[<c01744ca>] [<c017a997>] [<c01723d7>]=20
Jul  6 08:19:19 titan2 kernel:    [<c027c6c3>] [<c01721e7>] [<c0105516>] =
[<c0172020>]=20
Jul  6 08:19:19 titan2 kernel:=20
Jul  6 08:19:19 titan2 kernel: Code: 39 7e 28 75 f1 8b 44 24 14 39 86 98 =
00 00 00 75 e5 8b 54 24=20
Jul  6 08:53:37 titan2 sshd(pam_unix)[821]: session opened for user root =
by (uid=3D0)
Jul  6 08:57:02 titan2 sshd(pam_unix)[910]: session opened for user root =
by (uid=3D0)
Jul  6 08:58:48 titan2 rpc.mountd: Caught signal 15, un-registering and =
exiting.=20

Another interesting point is that when I do a vmstat 1 on the box I get =
HIGH values sometimes in the 'w' column  show below

 procs                      memory    swap          io     system        =
 cpu
r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  =
sy  id
0  0 57      0 542624 137696 174972   0   0   244     0  729   693   0   =
6  94

Check out the 57 in w?  The very next time it goes to 0 and 0 and then =
maybe a 25 then 0 then like 38!?!?!?  I have 4 NFS servers with =
different hardware.  This is
the only one where w every goes above 10?  If you have any ideas on that =
one too PLEASE let me know... This is KILLING ME!

Matt


------=_NextPart_000_099E_01C224CF.4922C1C0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2716.2200" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi All, </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I am running a 2.4.18 kernal on a =
redhat 7.2=20
installation (No special kernel enhancements EXCEPT&nbsp; a modification =
for my=20
3ware RAID IDE Controller).</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>This is for my NFS server.&nbsp;&nbsp; =
My NFS=20
server is running the REISER FS file system on my data partition that is =

exported.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>In my var log messages I am constantly =
getting=20
these NFSD-FH erros.&nbsp;&nbsp; I am getting a couple per minute at =
this point=20
afterwhich my NFS server finally</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>dies with a kernel paging error that I =
will show=20
below.&nbsp; This nfs-fh error isn't only for that file shown below that =
is just=20
an example one.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>If you have ANY idea what might cause =
this I would=20
get VERY VERY grateful.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>nfsd-fh: found a name that I didn't =
expect:=20
sinthongs.bravepages.com/wood</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>KERNEL ERROR I Finally =
get...</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Jul&nbsp; 6 08:19:19 titan2 kernel: =
Unable to=20
handle kernel paging request at virtual address 81b74c28<BR>Jul&nbsp; 6 =
08:19:19=20
titan2 kernel:&nbsp; printing eip:<BR>Jul&nbsp; 6 08:19:19 titan2 =
kernel:=20
c013eeca<BR>Jul&nbsp; 6 08:19:19 titan2 kernel: *pde =3D =
00000000<BR>Jul&nbsp; 6=20
08:19:19 titan2 kernel: Oops: 0000<BR>Jul&nbsp; 6 08:19:19 titan2 =
kernel:=20
CPU:&nbsp;&nbsp;&nbsp; 0<BR>Jul&nbsp; 6 08:19:19 titan2 kernel:=20
EIP:&nbsp;&nbsp;&nbsp; 0010:[&lt;c013eeca&gt;]&nbsp;&nbsp;&nbsp; Not=20
tainted<BR>Jul&nbsp; 6 08:19:19 titan2 kernel: EFLAGS: =
00010297<BR>Jul&nbsp; 6=20
08:19:19 titan2 kernel: eax: c018ecf0&nbsp;&nbsp; ebx: =
81b74c00&nbsp;&nbsp; ecx:=20
0000ffff&nbsp;&nbsp; edx: ca3e5e64<BR>Jul&nbsp; 6 08:19:19 titan2 =
kernel: esi:=20
81b74c00&nbsp;&nbsp; edi: 00248ec9&nbsp;&nbsp; ebp: c1ef6828&nbsp;&nbsp; =
esp:=20
ca3e5e08<BR>Jul&nbsp; 6 08:19:19 titan2 kernel: ds: 0018&nbsp;&nbsp; es: =

0018&nbsp;&nbsp; ss: 0018<BR>Jul&nbsp; 6 08:19:19 titan2 kernel: Process =
nfsd=20
(pid: 991, stackpage=3Dca3e5000)<BR>Jul&nbsp; 6 08:19:19 titan2 kernel: =
Stack:=20
00000003 c1ef6828 00248ec9 f70acc00 c013f2b5 f70acc00 00248ec9 c1ef6828=20
<BR>Jul&nbsp; 6 08:19:19 titan2=20
kernel:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; c018ecf0 ca3e5e64 =
00000001=20
00000000 00000000 cf184dc0 00000003 ca3e5e7c <BR>Jul&nbsp; 6 08:19:19 =
titan2=20
kernel:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ca3f1a14 00000000 =
c018ed34=20
f70acc00 00248ec9 c018ecf0 ca3e5e64 0000118f <BR>Jul&nbsp; 6 08:19:19 =
titan2=20
kernel: Call Trace: [&lt;c013f2b5&gt;] [&lt;c018ecf0&gt;] =
[&lt;c018ed34&gt;]=20
[&lt;c018ecf0&gt;] [&lt;c018edee&gt;] <BR>Jul&nbsp; 6 08:19:19 titan2=20
kernel:&nbsp;&nbsp;&nbsp; [&lt;c017599e&gt;] [&lt;c0173c18&gt;]=20
[&lt;c0173fde&gt;] [&lt;c01744ca&gt;] [&lt;c017a997&gt;] =
[&lt;c01723d7&gt;]=20
<BR>Jul&nbsp; 6 08:19:19 titan2 kernel:&nbsp;&nbsp;&nbsp; =
[&lt;c027c6c3&gt;]=20
[&lt;c01721e7&gt;] [&lt;c0105516&gt;] [&lt;c0172020&gt;] <BR>Jul&nbsp; 6 =

08:19:19 titan2 kernel: <BR>Jul&nbsp; 6 08:19:19 titan2 kernel: Code: 39 =
7e 28=20
75 f1 8b 44 24 14 39 86 98 00 00 00 75 e5 8b 54 24 <BR>Jul&nbsp; 6 =
08:53:37=20
titan2 sshd(pam_unix)[821]: session opened for user root by =
(uid=3D0)<BR>Jul&nbsp;=20
6 08:57:02 titan2 sshd(pam_unix)[910]: session opened for user root by=20
(uid=3D0)<BR>Jul&nbsp; 6 08:58:48 titan2 rpc.mountd: Caught signal 15,=20
un-registering and exiting. </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Another interesting point is that when =
I do a=20
vmstat 1 on the box I get HIGH values sometimes in the 'w' column&nbsp; =
show=20
below</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial=20
size=3D2>&nbsp;procs&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
=20
memory&nbsp;&nbsp;&nbsp;=20
swap&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=20
io&nbsp;&nbsp;&nbsp;&nbsp;=20
system&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; cpu<BR>r&nbsp; =
b&nbsp;=20
w&nbsp;&nbsp; swpd&nbsp;&nbsp; free&nbsp;&nbsp; buff&nbsp; cache&nbsp; =
si&nbsp;=20
so&nbsp;&nbsp;&nbsp; bi&nbsp;&nbsp;&nbsp; bo&nbsp;&nbsp; =
in&nbsp;&nbsp;&nbsp;=20
cs&nbsp; us&nbsp; sy&nbsp; id</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>0&nbsp; 0 =
57&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 542624=20
137696 174972&nbsp;&nbsp; 0&nbsp;&nbsp; 0&nbsp;&nbsp;=20
244&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp; 729&nbsp;&nbsp; 693&nbsp;&nbsp;=20
0&nbsp;&nbsp; 6&nbsp; 94</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Check out the 57 in w?&nbsp; The very =
next time it=20
goes to 0 and 0 and then maybe a 25 then 0 then like 38!?!?!?&nbsp; I =
have 4 NFS=20
servers with different hardware.&nbsp; This is</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the only one where w every goes above =
10?&nbsp; If=20
you have any ideas on that one too PLEASE let me know... This is KILLING =

ME!</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Matt</FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_099E_01C224CF.4922C1C0--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Got root? We do.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
