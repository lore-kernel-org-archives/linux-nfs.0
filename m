From: "asha  yr" <asha_yr@rediffmail.com>
Subject: NFS lock reclaiming not working on Redhat4 update3
Date: 17 Feb 2006 11:02:40 -0000
Message-ID: <20060217110240.19279.qmail@webmail33.rediffmail.com>
Reply-To: "asha  yr" <asha_yr@rediffmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="Next_1140174159---0-203.199.83.245-19236"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA3OW-00082U-Vi
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 03:03:24 -0800
Received: from [203.199.83.245] (helo=rediffmail.com)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FA3OU-0002IZ-9c
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 03:03:25 -0800
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

 This is a multipart mime message


--Next_1140174159---0-203.199.83.245-19236
Content-type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,=0A=0ANFS lock reclaiming is not working on Redhat4 Update3. I restarted=
 statd on NFS server and tried to capture lockd debugging messages on NFS c=
lient. I observe that callback on client is failing. Can you please let me =
know what it means?=0A=0ADebugging messages of lockd(/var/log/messages)=0A=
=0AFeb 10 09:47:44 sgmlx2 kernel: device eth0 entered promiscuous mode=0AFe=
b 10 09:47:48 sgmlx2 kernel: lockd: nlm_lookup_host(0f46bfac, p=3D6, v=3D4)=
=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: host garbage collection=0AFeb 10 0=
9:47:48 sgmlx2 kernel: lockd: nlmsvc_mark_resources=0AFeb 10 09:47:48 sgmlx=
2 kernel: lockd: delete host 15.70.191.172=0AFeb 10 09:47:48 sgmlx2 kernel:=
 lockd: nsm_unmonitor(15.70.191.172)=0AFeb 10 09:47:48 sgmlx2 kernel: lockd=
: creating host entry=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: nlm_bind_host=
(0f46bfac)=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: get host 15.70.191.172=
=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: nsm_monitor(15.70.191.172)=0AFeb 1=
0 09:47:48 sgmlx2 kernel: nsm: xdr_decode_stat_res status 0 state 129=0AFeb=
 10 09:47:48 sgmlx2 kernel: lockd: nlm_bind_host(0f46bfac)=0AFeb 10 09:47:4=
8 sgmlx2 kernel: lockd: release host 15.70.191.172=0AFeb 10 09:48:01 sgmlx2=
 kernel: lockd: request from 7f000001=0AFeb 10 09:48:01 sgmlx2 kernel: nlms=
vc_retry_blocked(00000000, when=3D0)=0AFeb 10 09:48:01 sgmlx2 kernel: nlmsv=
c_retry_blocked(00000000, when=3D0)=0AFeb 10 09:48:01 sgmlx2 rpc.statd[2292=
]: recv_rply: [127.0.0.1] RPC status 1=0AFeb 10 09:48:07 sgmlx2 kernel: loc=
kd: request from 7f000001=0AFeb 10 09:48:07 sgmlx2 kernel: nlmsvc_retry_blo=
cked(00000000, when=3D0)=0AFeb 10 09:48:07 sgmlx2 kernel: nlmsvc_retry_bloc=
ked(00000000, when=3D0)=0AFeb 10 09:48:07 sgmlx2 rpc.statd[2292]: recv_rply=
: [127.0.0.1] RPC status 1=0AFeb 10 09:48:13 sgmlx2 kernel: lockd: request =
from 7f000001=0AFeb 10 09:48:13 sgmlx2 kernel: nlmsvc_retry_blocked(0000000=
0, when=3D0)=0AFeb 10 09:48:13 sgmlx2 kernel: nlmsvc_retry_blocked(00000000=
, when=3D0)=0AFeb 10 09:48:13 sgmlx2 rpc.statd[2292]: recv_rply: [127.0.0.1=
] RPC status 1=0AFeb 10 09:48:19 sgmlx2 kernel: lockd: request from 7f00000=
1=0AFeb 10 09:48:19 sgmlx2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)=
=0AFeb 10 09:48:19 sgmlx2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)=
=0AFeb 10 09:48:19 sgmlx2 rpc.statd[2292]: recv_rply: [127.0.0.1] RPC statu=
s 1=0AFeb 10 09:48:25 sgmlx2 rpc.statd[2292]: Can't callback 127.0.0.1 (100=
021,4), giving up.=0A=0A=0AThanks and Regards,=0AAsha=0A
--Next_1140174159---0-203.199.83.245-19236
Content-type: text/html;
	charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<P>=0AHi,<BR>=0A<BR>=0ANFS lock reclaiming is not working on Redhat4 Update=
3. I restarted statd on NFS server and tried to capture lockd debugging mes=
sages on NFS client. I observe that callback on client is failing. Can you =
please let me know what it means?<BR>=0A<BR>=0ADebugging messages of lockd(=
/var/log/messages)<BR>=0A<BR>=0AFeb 10 09:47:44 sgmlx2 kernel: device eth0 =
entered promiscuous mode<BR>=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: nlm_lo=
okup_host(0f46bfac, p=3D6, v=3D4)<BR>=0AFeb 10 09:47:48 sgmlx2 kernel: lock=
d: host garbage collection<BR>=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: nlms=
vc_mark_resources<BR>=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: delete host 1=
5.70.191.172<BR>=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: nsm_unmonitor(15.7=
0.191.172)<BR>=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: creating host entry<=
BR>=0AFeb 10 09:47:48 sgmlx2 kernel: lockd: nlm_bind_host(0f46bfac)<BR>=0AF=
eb 10 09:47:48 sgmlx2 kernel: lockd: get host 15.70.191.172<BR>=0AFeb 10 09=
:47:48 sgmlx2 kernel: lockd: nsm_monitor(15.70.191.172)<BR>=0AFeb 10 09:47:=
48 sgmlx2 kernel: nsm: xdr_decode_stat_res status 0 state 129<BR>=0AFeb 10 =
09:47:48 sgmlx2 kernel: lockd: nlm_bind_host(0f46bfac)<BR>=0AFeb 10 09:47:4=
8 sgmlx2 kernel: lockd: release host 15.70.191.172<BR>=0AFeb 10 09:48:01 sg=
mlx2 kernel: lockd: request from 7f000001<BR>=0AFeb 10 09:48:01 sgmlx2 kern=
el: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09:48:01 sgmlx2 k=
ernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09:48:01 sgmlx=
2 rpc.statd[2292]: recv_rply: [127.0.0.1] RPC status 1<BR>=0AFeb 10 09:48:0=
7 sgmlx2 kernel: lockd: request from 7f000001<BR>=0AFeb 10 09:48:07 sgmlx2 =
kernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09:48:07 sgml=
x2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09:48:07 s=
gmlx2 rpc.statd[2292]: recv_rply: [127.0.0.1] RPC status 1<BR>=0AFeb 10 09:=
48:13 sgmlx2 kernel: lockd: request from 7f000001<BR>=0AFeb 10 09:48:13 sgm=
lx2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09:48:13 =
sgmlx2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09:48:=
13 sgmlx2 rpc.statd[2292]: recv_rply: [127.0.0.1] RPC status 1<BR>=0AFeb 10=
 09:48:19 sgmlx2 kernel: lockd: request from 7f000001<BR>=0AFeb 10 09:48:19=
 sgmlx2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09:48=
:19 sgmlx2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AFeb 10 09=
:48:19 sgmlx2 rpc.statd[2292]: recv_rply: [127.0.0.1] RPC status 1<BR>=0AFe=
b 10 09:48:25 sgmlx2 rpc.statd[2292]: Can't callback 127.0.0.1 (100021,4), =
giving up.<BR>=0A<BR>=0A<BR>=0AThanks and Regards,<BR>=0AAsha<BR>=0A=0A</P>=
=0A<br><br>=0A<a href=3D"http://adworks.rediff.com/cgi-bin/AdWorks/sigclick=
.cgi/www.rediff.com/signature-home.htm/1507191490@Middle5?PARTNER=3D3"><IMG=
 SRC=3D"http://adworks.rediff.com/cgi-bin/AdWorks/sigimpress.cgi/www.rediff=
.com/signature-home.htm/1963059423@Middle5?OAS_query=3Dnull&PARTNER=3D3" BO=
RDER=3D0 VSPACE=3D0 HSPACE=3D0></a>=0A
--Next_1140174159---0-203.199.83.245-19236--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
