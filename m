From: Andrew Ryan <andrewr@nam-shub.com>
Subject: 2.4.20-NFS-ALL slower than 2.4.20-vanilla on TCP
Date: Tue, 3 Dec 2002 23:45:37 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.40.0212032324560.3012-200000@bolt.sonic.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-909110542-38205399-1038987631=:3012"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from a.smtp-out.sonic.net ([208.201.224.38])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JUDx-00056M-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Dec 2002 23:45:37 -0800
Received: from newbolt (bolt [208.201.242.18])
	by tempest.sonic.net (8.11.6/8.8.5) with ESMTP id gB47jb927577
	for <nfs@lists.sourceforge.net>; Tue, 3 Dec 2002 23:45:37 -0800
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---909110542-38205399-1038987631=:3012
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.40.0212032343261.3012@bolt.sonic.net>

This weekend I built 2.4.20 kernels with and without the NFS-ALL patch
set, and ran some of my standard IO tests on them using TCP mounts.

Good news, they are both stable, and dbench and tiotest numbers are both
very close. What is odd is that the bonnie++ results for the NFS-ALL
patchset are not so good, relative to 2.4.20-vanilla. It looks like there
is a real performance hit, on the order of 2-3x slowness, for the file
creation/listing/deletion test under NFS-ALL. All other operations seem to
be a bit slower as well, although it could be measurement error or bad
luck.

I'm not sure where the bug is, in which patch, so I'm posting to the list
in hopes that someone, probably one of the patch authors, can help me
narrow this down. It's not a huge deal, since 2.4.20-vanilla seems to be
stable and my applications are not dependent on super fast creation times,
but still, this should be fixed.

Results are attached.

My setup:
Client: 2x1.4GHz PIII, 4096MB RAM, 2.4.20 vanilla and NFS-ALL kernels,
100Mbit
Mount: rw,tcp,nfsvers=3,rsize=32768,wsize=32768,intr,hard
Server: Netapp F820, ONTAP 6.2R2, 1000Mbit


thanks,
andrew

---909110542-38205399-1038987631=:3012
Content-Type: TEXT/HTML; NAME="bonresults-ml.html"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.40.0212032340310.3012@bolt.sonic.net>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="bonresults-ml.html"

PCFET0NUWVBFIEhUTUwgUFVCTElDICItLy9XM0MvL0RURCBIVE1MIDQuMC8v
RU4iICJodHRwOi8vd3d3LnczLm9yZy9UUi9SRUMtaHRtbDQwL3N0cmljdC5k
dGQiPg0KPEhUTUw+DQo8SEVBRD48VElUTEU+Qm9ubmllKysgVjEuMDJhIEJl
bmNobWFyayByZXN1bHRzPC9USVRMRT4NCjxTVFlMRSB0eXBlPSJ0ZXh0L2Nz
cyI+DQpURC5oZWFkZXIge3RleHQtYWxpZ246IGNlbnRlcjsgYmFja2dyb3Vu
ZGNvbG9yOiAiI0NDRkZGRiIgfQ0KVEQucm93aGVhZGVyIHt0ZXh0LWFsaWdu
OiBjZW50ZXI7IGJhY2tncm91bmRjb2xvcjogIiNDQ0NGRkYiIH0NClRELnNp
emUge3RleHQtYWxpZ246IGNlbnRlcjsgYmFja2dyb3VuZGNvbG9yOiAiI0ND
Q0ZGRiIgfQ0KVEQua3NlYyB7dGV4dC1hbGlnbjogY2VudGVyOyBmb250c3R5
bGU6IGl0YWxpYyB9DQo8L1NUWUxFPg0KPEJPRFk+DQo8aDE+Qm9ubmllKysg
VjEuMDJhIEJlbmNobWFyayByZXN1bHRzPC9oMT4NCjxocj4NCjxUQUJMRSBB
TElHTj1jZW50ZXIgQk9SREVSPTMgQ0VMTFBBRERJTkc9MiBDRUxMU1BBQ0lO
Rz0xPg0KPFRSPjxURCBDT0xTUEFOPTIgY2xhc3M9ImhlYWRlciI+PC9URD4N
CjxURCBDT0xTUEFOPTYgY2xhc3M9ImhlYWRlciI+PEZPTlQgU0laRT0rMj48
Qj5TZXF1ZW50aWFsIE91dHB1dDwvQj48L0ZPTlQ+PC9URD4NCjxURCBDT0xT
UEFOPTQgY2xhc3M9ImhlYWRlciI+PEZPTlQgU0laRT0rMj48Qj5TZXF1ZW50
aWFsIElucHV0PC9CPjwvRk9OVD48L1REPg0KPFREIENPTFNQQU49MiBST1dT
UEFOPTIgY2xhc3M9ImhlYWRlciI+PEZPTlQgU0laRT0rMj48Qj5SYW5kb208
QlI+U2Vla3M8L0I+PC9GT05UPjwvVEQ+DQo8VEQgQ09MU1BBTj0xIGNsYXNz
PSJoZWFkZXIiPjwvVEQ+DQo8VEQgQ09MU1BBTj02IGNsYXNzPSJoZWFkZXIi
PjxGT05UIFNJWkU9KzI+PEI+U2VxdWVudGlhbCBDcmVhdGU8L0I+PC9GT05U
PjwvVEQ+DQo8VEQgQ09MU1BBTj02IGNsYXNzPSJoZWFkZXIiPjxGT05UIFNJ
WkU9KzI+PEI+UmFuZG9tIENyZWF0ZTwvQj48L0ZPTlQ+PC9URD4NCjwvdHI+
DQo8VFI+PFREPjwvVEQ+PFREPlNpemU6Q2h1bmsgU2l6ZTwvVEQ+PFREIENP
TFNQQU49Mj5QZXIgQ2hhcjwvVEQ+PFREIENPTFNQQU49Mj5CbG9jazwvVEQ+
PFREIENPTFNQQU49Mj5SZXdyaXRlPC9URD48VEQgQ09MU1BBTj0yPlBlciBD
aGFyPC9URD48VEQgQ09MU1BBTj0yPkJsb2NrPC9URD48VEQ+TnVtIEZpbGVz
PC9URD48VEQgQ09MU1BBTj0yPkNyZWF0ZTwvVEQ+PFREIENPTFNQQU49Mj5S
ZWFkPC9URD48VEQgQ09MU1BBTj0yPkRlbGV0ZTwvVEQ+PFREIENPTFNQQU49
Mj5DcmVhdGU8L1REPjxURCBDT0xTUEFOPTI+UmVhZDwvVEQ+PFREIENPTFNQ
QU49Mj5EZWxldGU8L1REPjwvVFI+PFRSPjxURCBDT0xTUEFOPTI+PC9URD48
VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+Sy9zZWM8L0ZPTlQ+PC9U
RD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+JSBDUFU8L0ZPTlQ+
PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+Sy9zZWM8L0ZP
TlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+JSBDUFU8
L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+Sy9z
ZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+
JSBDUFU8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9
LTI+Sy9zZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJ
WkU9LTI+JSBDUFU8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05U
IFNJWkU9LTI+Sy9zZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxG
T05UIFNJWkU9LTI+JSBDUFU8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMi
PjxGT05UIFNJWkU9LTI+LyBzZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9Imtz
ZWMiPjxGT05UIFNJWkU9LTI+JSBDUFU8L0ZPTlQ+PC9URD48VEQ+PC9URD48
VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+LyBzZWM8L0ZPTlQ+PC9U
RD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+JSBDUFU8L0ZPTlQ+
PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+LyBzZWM8L0ZP
TlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+JSBDUFU8
L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+LyBz
ZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9LTI+
JSBDUFU8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJWkU9
LTI+LyBzZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05UIFNJ
WkU9LTI+JSBDUFU8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxGT05U
IFNJWkU9LTI+LyBzZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMiPjxG
T05UIFNJWkU9LTI+JSBDUFU8L0ZPTlQ+PC9URD48VEQgY2xhc3M9ImtzZWMi
PjxGT05UIFNJWkU9LTI+LyBzZWM8L0ZPTlQ+PC9URD48VEQgY2xhc3M9Imtz
ZWMiPjxGT05UIFNJWkU9LTI+JSBDUFU8L0ZPTlQ+PC9URD48L1RSPg0KPFRS
PjxURCBjbGFzcz0icm93aGVhZGVyIj48Rk9OVCBTSVpFPSsxPjxCPjIuNC4y
MC1ORlNfQUxMLTIwMDIxMjAzMTc1ODQyLW5vbG9jazwvQj48L0ZPTlQ+PC9U
RD48VEQgY2xhc3M9InNpemUiPjhHPC9URD48VEQgY2xhc3M9InNpemUiPjwv
VEQ+PFREIGNsYXNzPSJzaXplIj48L1REPjxURCBjbGFzcz0ic2l6ZSI+MTEw
NjI8L1REPjxURCBjbGFzcz0ic2l6ZSI+NDwvVEQ+PFREIGNsYXNzPSJzaXpl
Ij44NzQ5PC9URD48VEQgY2xhc3M9InNpemUiPjY8L1REPjxURCBjbGFzcz0i
c2l6ZSI+PC9URD48VEQgY2xhc3M9InNpemUiPjwvVEQ+PFREIGNsYXNzPSJz
aXplIj4xMjc1NzwvVEQ+PFREIGNsYXNzPSJzaXplIj40PC9URD48VEQgY2xh
c3M9InNpemUiPjIzNC41PC9URD48VEQgY2xhc3M9InNpemUiPjE8L1REPjxU
RCBjbGFzcz0ic2l6ZSI+MTY8L1REPjxURCBjbGFzcz0ic2l6ZSI+MTg0PC9U
RD48VEQgY2xhc3M9InNpemUiPjE8L1REPjxURCBjbGFzcz0ic2l6ZSI+NTI5
PC9URD48VEQgY2xhc3M9InNpemUiPjEzPC9URD48VEQgY2xhc3M9InNpemUi
PjExPC9URD48VEQgY2xhc3M9InNpemUiPjE8L1REPjxURCBjbGFzcz0ic2l6
ZSI+MjAyPC9URD48VEQgY2xhc3M9InNpemUiPjE8L1REPjxURCBjbGFzcz0i
c2l6ZSI+NjU4PC9URD48VEQgY2xhc3M9InNpemUiPjE8L1REPjxURCBjbGFz
cz0ic2l6ZSI+MjkxPC9URD48VEQgY2xhc3M9InNpemUiPjE8L1REPjwvVFI+
DQo8VFI+PFREIGNsYXNzPSJyb3doZWFkZXIiPjxGT05UIFNJWkU9KzE+PEI+
Mi40LjIwLXZhbmlsbGEtMjAwMjEyMDMyMjIwNDAtbm9sb2NrPC9CPjwvRk9O
VD48L1REPjxURCBjbGFzcz0ic2l6ZSI+OEc8L1REPjxURCBjbGFzcz0ic2l6
ZSI+PC9URD48VEQgY2xhc3M9InNpemUiPjwvVEQ+PFREIGNsYXNzPSJzaXpl
Ij4xMTE1NjwvVEQ+PFREIGNsYXNzPSJzaXplIj40PC9URD48VEQgY2xhc3M9
InNpemUiPjg5MTc8L1REPjxURCBjbGFzcz0ic2l6ZSI+NjwvVEQ+PFREIGNs
YXNzPSJzaXplIj48L1REPjxURCBjbGFzcz0ic2l6ZSI+PC9URD48VEQgY2xh
c3M9InNpemUiPjEyODI4PC9URD48VEQgY2xhc3M9InNpemUiPjQ8L1REPjxU
RCBjbGFzcz0ic2l6ZSI+MjQxLjc8L1REPjxURCBjbGFzcz0ic2l6ZSI+MTwv
VEQ+PFREIGNsYXNzPSJzaXplIj4xNjwvVEQ+PFREIGNsYXNzPSJzaXplIj41
Mjg8L1REPjxURCBjbGFzcz0ic2l6ZSI+MjwvVEQ+PFREIGNsYXNzPSJzaXpl
Ij4xMzIxPC9URD48VEQgY2xhc3M9InNpemUiPjM8L1REPjxURCBjbGFzcz0i
c2l6ZSI+NTU5PC9URD48VEQgY2xhc3M9InNpemUiPjI8L1REPjxURCBjbGFz
cz0ic2l6ZSI+NTUzPC9URD48VEQgY2xhc3M9InNpemUiPjI8L1REPjxURCBj
bGFzcz0ic2l6ZSI+MTM1MjwvVEQ+PFREIGNsYXNzPSJzaXplIj4yPC9URD48
VEQgY2xhc3M9InNpemUiPjU5NjwvVEQ+PFREIGNsYXNzPSJzaXplIj4yPC9U
RD48L1RSPg0KPC9UQUJMRT4NCjxIUj4NCjxpPkF1dG8tZ2VuZXJhdGVkIGF0
IFR1ZSBEZWMgIDMgMjM6MzA6NTkgUFNUIDIwMDI8L2k+DQo8L0JPRFk+DQo8
L0hUTUw+DQo=
---909110542-38205399-1038987631=:3012--


-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
