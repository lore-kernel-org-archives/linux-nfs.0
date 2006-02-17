From: "asha  yr" <asha_yr@rediffmail.com>
Subject: Re: Re: NFS lock reclaiming not working on SLES9 SP2
Date: 17 Feb 2006 10:48:42 -0000
Message-ID: <20060217104842.5424.qmail@webmail24.rediffmail.com>
Reply-To: "asha  yr" <asha_yr@rediffmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="Next_1140173320---0-203.199.83.146-5200"
Cc: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>,
	"Olaf Kirch" <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA3As-0006El-Qi
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 02:49:18 -0800
Received: from [203.199.83.146] (helo=rediffmail.com)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FA3Ao-0006U6-RX
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 02:49:19 -0800
To: "Greg Banks" <gnb@melbourne.sgi.com>
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


--Next_1140173320---0-203.199.83.146-5200
Content-type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,=0A=0AI am comparing the working of NFS lock recovery feature on differe=
nt updates of SLES9 and Redhat4. So I dont want to test the feature by appl=
ying any patch. Anyway, thanks for the patch.=0A=0AI tried mounting NFS fil=
e system using hostname on client. After sending notifications, sm-notify c=
lears sm directory. Then the sm directory should get updated freshly with t=
he client information. This is not happening.=0A=0AThe debugging messages o=
f lockd on server and client are:=0A=0Aon client side=0AFeb 17 16:10:07 sgm=
lx2 kernel: NFS lockd/statd started (ver 0.5).=0AFeb 17 16:10:23 sgmlx2 ker=
nel: lockd: request from 0f46bfac=0AFeb 17 16:10:23 sgmlx2 kernel: lockd: n=
lm_host_rebooted("sgmlx1")=0AFeb 17 16:10:30 sgmlx2 kernel: lockd: nlm_look=
up_host(0f46bfac, p=3D6, v=3D4, my role=3Dclient, name=3Dsgmlx1)=0AFeb 17 1=
6:10:30 sgmlx2 kernel: lockd: host garbage collection=0AFeb 17 16:10:30 sgm=
lx2 kernel: lockd: nlmsvc_mark_resources=0AFeb 17 16:10:30 sgmlx2 kernel: l=
ockd: nlm_bind_host(0f46bfac)=0AFeb 17 16:11:00 sgmlx2 last message repeate=
d 3 times=0AFeb 17 16:11:00 sgmlx2 kernel: lockd: release host sgmlx1=0AFeb=
 17 16:11:00 sgmlx2 kernel: lockd: get host sgmlx1=0AFeb 17 16:11:48 sgmlx2=
 kernel: lockd: request from 0f46bfac=0AFeb 17 16:11:48 sgmlx2 kernel: lock=
d: nlm_host_rebooted("sgmlx1")=0AFeb 17 16:11:48 sgmlx2 kernel: lockd: rebi=
nd host sgmlx1=0AFeb 17 16:11:48 sgmlx2 kernel: lockd: get host sgmlx1=0AFe=
b 17 16:11:48 sgmlx2 kernel: lockd: release host sgmlx1=0AFeb 17 16:11:48 s=
gmlx2 kernel: nlmsvc_retry_blocked(00000000, when=3D0)=0AFeb 17 16:11:48 sg=
mlx2 kernel: lockd: nlm_bind_host(0f46bfac)=0AFeb 17 16:11:48 sgmlx2 kernel=
: lockd: release host sgmlx1=0A=0A=0Aon server side=0AFeb 17 21:47:34 sgmlx=
1 kernel: NFS lockd/statd started (ver 0.5).=0AFeb 17 21:47:52 sgmlx1 rpc.m=
ountd: authenticated mount request from sgmlx2.india.hp.com:970 for /test (=
/test)=0AFeb 17 21:48:15 sgmlx1 kernel: lockd: request from 0f46bfad=0AFeb =
17 21:48:30 sgmlx1 kernel: lockd: request from 0f46bfad=0AFeb 17 21:48:30 s=
gmlx1 kernel: nlmsvc_retry_blocked(00000000, when=3D0)=0AFeb 17 21:48:45 sg=
mlx1 kernel: lockd: request from 0f46bfad=0AFeb 17 21:48:45 sgmlx1 kernel: =
lockd: nlm_lookup_host(0f46bfad, p=3D6, v=3D4, my role=3Dserver, name=3Dsgm=
lx2)=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: host garbage collection=0AFeb =
17 21:48:45 sgmlx1 kernel: lockd: nlmsvc_mark_resources=0AFeb 17 21:48:45 s=
gmlx1 kernel: lockd: nlm_file_lookup(06000001 01006800 00025489 00012f4e 00=
025489 0002da54)=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: creating file for =
(06000001 01006800 00025489 00012f4e 00025489 0002da54)=0AFeb 17 21:48:45 s=
gmlx1 kernel: lockd: found file f5070e00 (count 0)=0AFeb 17 21:48:45 sgmlx1=
 kernel: lockd: nlmsvc_lock(cciss/c0d0p1/77646, ty=3D1, pi=3D6733, 0-922337=
2036854775807, bl=3D0)=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: nlmsvc_looku=
p_block f=3Df5070e00 pd=3D6733 0-9223372036854775807 ty=3D1=0AFeb 17 21:48:=
45 sgmlx1 kernel: lockd: posix_lock_file returned 0=0AFeb 17 21:48:45 sgmlx=
1 kernel: lockd: release host sgmlx2=0AFeb 17 21:48:45 sgmlx1 kernel: lockd=
: nlm_release_file(f5070e00, ct =3D 1)=0AFeb 17 21:48:45 sgmlx1 kernel: nlm=
svc_retry_blocked(00000000, when=3D0)=0AFeb 17 21:48:45 sgmlx1 kernel: nlms=
vc_retry_blocked(00000000, when=3D0)=0AFeb 17 21:49:27 sgmlx1 kernel: lockd=
: nlmsvc_free_host_resources=0AFeb 17 21:49:27 sgmlx1 kernel: lockd: releas=
e host sgmlx2=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: request from 0f46bfad=
=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: nlm_lookup_host(0f46bfad, p=3D6, v=
=3D4, my role=3Dserver, name=3Dsgmlx2)=0AFeb 17 21:49:33 sgmlx1 kernel: loc=
kd: nlm_file_lookup(06000001 01006800 00025489 00012f4e 00025489 0002da54)=
=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: creating file for (06000001 010068=
00 00025489 00012f4e 00025489 0002da54)=0AFeb 17 21:49:33 sgmlx1 kernel: lo=
ckd: found file f5070000 (count 0)=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: =
nlmsvc_lock(cciss/c0d0p1/77646, ty=3D1, pi=3D6733, 0-9223372036854775807, b=
l=3D0)=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: nlmsvc_lookup_block f=3Df507=
0000 pd=3D6733 0-9223372036854775807 ty=3D1=0AFeb 17 21:49:33 sgmlx1 kernel=
: lockd: posix_lock_file returned 0=0AFeb 17 21:49:33 sgmlx1 kernel: lockd:=
 release host sgmlx2=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: nlm_release_fi=
le(f5070000, ct =3D 1)=0A=0ARegards,=0AAsha=0A=0AOn Fri, 17 Feb 2006 Greg B=
anks wrote :=0A>On Fri, 2006-02-17 at 20:56, Olaf Kirch wrote:=0A> > It see=
ms the problem is that we're now using hostnames to identify lockd=0A> > pe=
ers, but you mounted the file system using the ipaddr:/path.=0A>=0A>Indeed,=
 well caught.  I missed the significance of name=3D...=0A>=0A>Greg.=0A>--=
=0A>Greg Banks, R&D Software Engineer, SGI Australian Software Group.=0A>I =
don't speak for SGI.=0A>=0A>=0A>=0A>=0A>-----------------------------------=
--------------------=0A>This SF.net email is sponsored by: Splunk Inc. Do y=
ou grep through log files=0A>for problems?  Stop!  Download the new AJAX se=
arch engine that makes=0A>searching your log files as easy as surfing the  =
web.  DOWNLOAD SPLUNK!=0A>http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D1=
03432&bid=3D230486&dat=3D121642=0A>________________________________________=
_______=0A>NFS maillist  -  NFS@lists.sourceforge.net=0A>https://lists.sour=
ceforge.net/lists/listinfo/nfs=0A
--Next_1140173320---0-203.199.83.146-5200
Content-type: text/html;
	charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<P>=0AHi,<BR>=0A<BR>=0AI am comparing the working of NFS lock recovery feat=
ure on different updates of SLES9 and Redhat4. So I dont want to test the f=
eature by applying any patch. Anyway, thanks for the patch.<BR>=0A<BR>=0AI =
tried mounting NFS file system using hostname on client. After sending noti=
fications, sm-notify clears sm directory. Then the sm directory should get =
updated freshly with the client information. This is not happening.<BR>=0A<=
BR>=0AThe debugging messages of lockd on server and client are:<BR>=0A<BR>=
=0Aon client side<BR>=0AFeb 17 16:10:07 sgmlx2 kernel: NFS lockd/statd star=
ted (ver 0.5).<BR>=0AFeb 17 16:10:23 sgmlx2 kernel: lockd: request from 0f4=
6bfac<BR>=0AFeb 17 16:10:23 sgmlx2 kernel: lockd: nlm_host_rebooted(&quot;s=
gmlx1&quot;)<BR>=0AFeb 17 16:10:30 sgmlx2 kernel: lockd: nlm_lookup_host(0f=
46bfac, p=3D6, v=3D4, my role=3Dclient, name=3Dsgmlx1)<BR>=0AFeb 17 16:10:3=
0 sgmlx2 kernel: lockd: host garbage collection<BR>=0AFeb 17 16:10:30 sgmlx=
2 kernel: lockd: nlmsvc_mark_resources<BR>=0AFeb 17 16:10:30 sgmlx2 kernel:=
 lockd: nlm_bind_host(0f46bfac)<BR>=0AFeb 17 16:11:00 sgmlx2 last message r=
epeated 3 times<BR>=0AFeb 17 16:11:00 sgmlx2 kernel: lockd: release host sg=
mlx1<BR>=0AFeb 17 16:11:00 sgmlx2 kernel: lockd: get host sgmlx1<BR>=0AFeb =
17 16:11:48 sgmlx2 kernel: lockd: request from 0f46bfac<BR>=0AFeb 17 16:11:=
48 sgmlx2 kernel: lockd: nlm_host_rebooted(&quot;sgmlx1&quot;)<BR>=0AFeb 17=
 16:11:48 sgmlx2 kernel: lockd: rebind host sgmlx1<BR>=0AFeb 17 16:11:48 sg=
mlx2 kernel: lockd: get host sgmlx1<BR>=0AFeb 17 16:11:48 sgmlx2 kernel: lo=
ckd: release host sgmlx1<BR>=0AFeb 17 16:11:48 sgmlx2 kernel: nlmsvc_retry_=
blocked(00000000, when=3D0)<BR>=0AFeb 17 16:11:48 sgmlx2 kernel: lockd: nlm=
_bind_host(0f46bfac)<BR>=0AFeb 17 16:11:48 sgmlx2 kernel: lockd: release ho=
st sgmlx1<BR>=0A<BR>=0A<BR>=0Aon server side<BR>=0AFeb 17 21:47:34 sgmlx1 k=
ernel: NFS lockd/statd started (ver 0.5).<BR>=0AFeb 17 21:47:52 sgmlx1 rpc.=
mountd: authenticated mount request from sgmlx2.india.hp.com:970 for /test =
(/test)<BR>=0AFeb 17 21:48:15 sgmlx1 kernel: lockd: request from 0f46bfad<B=
R>=0AFeb 17 21:48:30 sgmlx1 kernel: lockd: request from 0f46bfad<BR>=0AFeb =
17 21:48:30 sgmlx1 kernel: nlmsvc_retry_blocked(00000000, when=3D0)<BR>=0AF=
eb 17 21:48:45 sgmlx1 kernel: lockd: request from 0f46bfad<BR>=0AFeb 17 21:=
48:45 sgmlx1 kernel: lockd: nlm_lookup_host(0f46bfad, p=3D6, v=3D4, my role=
=3Dserver, name=3Dsgmlx2)<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: host =
garbage collection<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: nlmsvc_mark_=
resources<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: nlm_file_lookup(06000=
001 01006800 00025489 00012f4e 00025489 0002da54)<BR>=0AFeb 17 21:48:45 sgm=
lx1 kernel: lockd: creating file for (06000001 01006800 00025489 00012f4e 0=
0025489 0002da54)<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: found file f5=
070e00 (count 0)<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: nlmsvc_lock(cc=
iss/c0d0p1/77646, ty=3D1, pi=3D6733, 0-9223372036854775807, bl=3D0)<BR>=0AF=
eb 17 21:48:45 sgmlx1 kernel: lockd: nlmsvc_lookup_block f=3Df5070e00 pd=3D=
6733 0-9223372036854775807 ty=3D1<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lock=
d: posix_lock_file returned 0<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: r=
elease host sgmlx2<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: lockd: nlm_release_=
file(f5070e00, ct =3D 1)<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: nlmsvc_retry_=
blocked(00000000, when=3D0)<BR>=0AFeb 17 21:48:45 sgmlx1 kernel: nlmsvc_ret=
ry_blocked(00000000, when=3D0)<BR>=0AFeb 17 21:49:27 sgmlx1 kernel: lockd: =
nlmsvc_free_host_resources<BR>=0AFeb 17 21:49:27 sgmlx1 kernel: lockd: rele=
ase host sgmlx2<BR>=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: request from 0f=
46bfad<BR>=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: nlm_lookup_host(0f46bfad=
, p=3D6, v=3D4, my role=3Dserver, name=3Dsgmlx2)<BR>=0AFeb 17 21:49:33 sgml=
x1 kernel: lockd: nlm_file_lookup(06000001 01006800 00025489 00012f4e 00025=
489 0002da54)<BR>=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: creating file for=
 (06000001 01006800 00025489 00012f4e 00025489 0002da54)<BR>=0AFeb 17 21:49=
:33 sgmlx1 kernel: lockd: found file f5070000 (count 0)<BR>=0AFeb 17 21:49:=
33 sgmlx1 kernel: lockd: nlmsvc_lock(cciss/c0d0p1/77646, ty=3D1, pi=3D6733,=
 0-9223372036854775807, bl=3D0)<BR>=0AFeb 17 21:49:33 sgmlx1 kernel: lockd:=
 nlmsvc_lookup_block f=3Df5070000 pd=3D6733 0-9223372036854775807 ty=3D1<BR=
>=0AFeb 17 21:49:33 sgmlx1 kernel: lockd: posix_lock_file returned 0<BR>=0A=
Feb 17 21:49:33 sgmlx1 kernel: lockd: release host sgmlx2<BR>=0AFeb 17 21:4=
9:33 sgmlx1 kernel: lockd: nlm_release_file(f5070000, ct =3D 1)<BR>=0A<BR>=
=0ARegards,<BR>=0AAsha<BR>=0A<BR>=0AOn Fri, 17 Feb 2006 Greg Banks wrote :<=
BR>=0A&gt;On Fri, 2006-02-17 at 20:56, Olaf Kirch wrote:<BR>=0A&gt; &gt; It=
 seems the problem is that we're now using hostnames to identify lockd<BR>=
=0A&gt; &gt; peers, but you mounted the file system using the ipaddr:/path.=
<BR>=0A&gt;<BR>=0A&gt;Indeed, well caught.&nbsp; I missed the significance =
of name=3D...<BR>=0A&gt;<BR>=0A&gt;Greg.<BR>=0A&gt;--<BR>=0A&gt;Greg Banks,=
 R&amp;D Software Engineer, SGI Australian Software Group.<BR>=0A&gt;I don'=
t speak for SGI.<BR>=0A&gt;<BR>=0A&gt;<BR>=0A&gt;<BR>=0A&gt;<BR>=0A&gt;----=
---------------------------------------------------<BR>=0A&gt;This SF.net e=
mail is sponsored by: Splunk Inc. Do you grep through log files<BR>=0A&gt;f=
or problems?&nbsp; Stop!&nbsp; Download the new AJAX search engine that mak=
es<BR>=0A&gt;searching your log files as easy as surfing the&nbsp; web.&nbs=
p; DOWNLOAD SPLUNK!<BR>=0A&gt;http://sel.as-us.falkag.net/sel?cmd=3Dlnk&amp=
;kid=3D103432&amp;bid=3D230486&amp;dat=3D121642<BR>=0A&gt;_________________=
______________________________<BR>=0A&gt;NFS maillist&nbsp; -&nbsp; NFS@lis=
ts.sourceforge.net<BR>=0A&gt;https://lists.sourceforge.net/lists/listinfo/n=
fs<BR>=0A=0A</P>=0A<br><br>=0A<a href=3D"http://adworks.rediff.com/cgi-bin/=
AdWorks/sigclick.cgi/www.rediff.com/signature-home.htm/1507191490@Middle5?P=
ARTNER=3D3"><IMG SRC=3D"http://adworks.rediff.com/cgi-bin/AdWorks/sigimpres=
s.cgi/www.rediff.com/signature-home.htm/1963059423@Middle5?OAS_query=3Dnull=
&PARTNER=3D3" BORDER=3D0 VSPACE=3D0 HSPACE=3D0></a>=0A
--Next_1140173320---0-203.199.83.146-5200--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
