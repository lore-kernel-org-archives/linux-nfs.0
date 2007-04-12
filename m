From: AK <amithl_prem@yahoo.com>
Subject: Re: POSIX I/O on NFS with noac option
Date: Thu, 12 Apr 2007 10:42:48 -0700 (PDT)
Message-ID: <757173.20715.qm@web56601.mail.re3.yahoo.com>
References: <1176397807.6664.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1739886279=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc3Js-0002JP-Oz
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:42:53 -0700
Received: from web56601.mail.re3.yahoo.com ([66.196.97.45])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Hc3Ju-0002Y6-O6
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 10:42:55 -0700
In-Reply-To: <1176397807.6664.9.camel@heimdal.trondhjem.org>
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

--===============1739886279==
Content-Type: multipart/alternative; boundary="0-3497556-1176399768=:20715"
Content-Transfer-Encoding: 7bit

--0-3497556-1176399768=:20715
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Thank you Trond for your reply ...=20
  =20
  >>1) Why would you need the 'noac' flag if you are using locking?
part of the requirement for MPI-IO to work correctly on NFS mounts.
 =20
>>2) Have you checked that the portmapper, rpc.statd and rpc.lockd are
>>accessible from the client? You can probe that using the commands
  =20
  On Client I have checked that portmap(rpc) rpc.statd(rpcuser) and lockd=
(root) is running but not rpc.lockd
  =20
  On server, there is no portmap, rpc.statd, rpc.lock nor lockd running.=20
  =20
  Upon the following probes on CLIENT I get the following
>>
>>rpcinfo -t status
>>and
>>rpcinfo -t nlockmgr
>>
  # rpcinfo -t <myserver> status
rpcinfo: RPC: Program not registered
program 100024 is not available
  =20
  # rpcinfo -t <myserver> nlockmgr
rpcinfo: RPC: Program not registered
program 100021 is not available
 =20
>>if you are using UDP mounts, you might want to use
>>
>>rpcinfo -u status
>>and
>>rpcinfo -u nlockmgr

  # rpcinfo -u <myserver> status
rpcinfo: RPC: Program not registered
program 100024 is not available
  =20
  # rpcinfo -u <myserver> nlockmgr
rpcinfo: RPC: Program not registered
program 100021 is not available
 =20
>>instead...

  Some info from SERVER=20
  # rpcinfo -u localhost nfs
program 100003 version 2 ready and waiting
program 100003 version 3 ready and waiting
  =20
  # rpcinfo -p | grep nfs
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100227    2   tcp   2049  nfs_acl
    100227    3   tcp   2049  nfs_acl
  # modinfo | egrep "nfs|lock"
 42 7828855a   1d3e  87   1  todds1287 (ds1287 clock driver 1.8)
156 78428000  2b018 106   1  nfs (NFS syscall, client, and common)
156 78428000  2b018 106   1  nfs (NFS syscall, client, and common)
156 78428000  2b018  16   1  nfs (network filesystem)
156 78428000  2b018   7   1  nfs (network filesystem version 2)
156 78428000  2b018  17   1  nfs (network filesystem version 3)
159 78458000  12881   -   1  nfssrv (NFS server module)
 =20
>>Trond
Form the above outputs it doesn't look like they are running. Is this req=
uired, if yes, then=20
  how do I turn them ON. And Why didn't we requires it for general purpos=
e NFS use ?? We have been running this server for about 2 years now.=20
  =20
  ~thanks -ak



      =20
---------------------------------
Sucker-punch spam with award-winning protection.
 Try the free Yahoo! Mail Beta.
--0-3497556-1176399768=:20715
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<DIV>Thank you Trond for your reply ... </DIV>  <DIV>&nbsp;</DIV>  <DIV>&=
gt;&gt;1) Why would you need the 'noac' flag if you are using locking?<BR=
>part of the requirement for MPI-IO to work correctly on NFS mounts.</DIV=
>  <DIV><BR>&gt;&gt;2) Have you checked that the portmapper, rpc.statd an=
d rpc.lockd are<BR>&gt;&gt;accessible from the client? You can probe that=
 using the commands</DIV>  <DIV>&nbsp;</DIV>  <DIV>On Client I have check=
ed that portmap(rpc)&nbsp;rpc.statd(rpcuser)&nbsp;and lockd(root)&nbsp;is=
 running but not rpc.lockd</DIV>  <DIV>&nbsp;</DIV>  <DIV>On server, ther=
e is no portmap, rpc.statd, rpc.lock&nbsp;nor lockd running. </DIV>  <DIV=
>&nbsp;</DIV>  <DIV>Upon the following probes on CLIENT I get the followi=
ng<BR>&gt;&gt;<BR>&gt;&gt;rpcinfo -t <SERVERNAME>status<BR>&gt;&gt;and<BR=
>&gt;&gt;rpcinfo -t <SERVERNAME>nlockmgr<BR>&gt;&gt;</DIV>  <DIV># rpcinf=
o -t&nbsp;&lt;myserver&gt; status<BR>rpcinfo: RPC: Program not registered=
<BR>program 100024 is not
 available</DIV>  <DIV>&nbsp;</DIV>  <DIV># rpcinfo -t&nbsp;&lt;myserver&=
gt; nlockmgr<BR>rpcinfo: RPC: Program not registered<BR>program 100021 is=
 not available</DIV>  <DIV><BR>&gt;&gt;if you are using UDP mounts, you m=
ight want to use<BR>&gt;&gt;<BR>&gt;&gt;rpcinfo -u <SERVERNAME>status<BR>=
&gt;&gt;and<BR>&gt;&gt;rpcinfo -u <SERVERNAME>nlockmgr<BR></DIV>  <DIV># =
rpcinfo -u&nbsp;&lt;myserver&gt; status<BR>rpcinfo: RPC: Program not regi=
stered<BR>program 100024 is not available</DIV>  <DIV>&nbsp;</DIV>  <DIV>=
# rpcinfo -u&nbsp;&lt;myserver&gt; nlockmgr<BR>rpcinfo: RPC: Program not =
registered<BR>program 100021 is not available</DIV>  <DIV><BR>&gt;&gt;ins=
tead...<BR></DIV>  <DIV>Some info from&nbsp;SERVER </DIV>  <DIV># rpcinfo=
 -u localhost nfs<BR>program 100003 version 2 ready and waiting<BR>progra=
m 100003 version 3 ready and waiting</DIV>  <DIV>&nbsp;</DIV>  <DIV># rpc=
info -p | grep nfs<BR>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; 2&nbsp;=
&nbsp; udp&nbsp;&nbsp; 2049&nbsp;
 nfs<BR>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbs=
p;&nbsp; 2049&nbsp; nfs<BR>&nbsp;&nbsp;&nbsp; 100227&nbsp;&nbsp;&nbsp; 2&=
nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; nfs_acl<BR>&nbsp;&nbsp;&nbsp; 1002=
27&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; udp&nbsp;&nbsp; 2049&nbsp; nfs_acl<BR>=
&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp;=
 2049&nbsp; nfs<BR>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nb=
sp; tcp&nbsp;&nbsp; 2049&nbsp; nfs<BR>&nbsp;&nbsp;&nbsp; 100227&nbsp;&nbs=
p;&nbsp; 2&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; nfs_acl<BR>&nbsp;&nbsp;=
&nbsp; 100227&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp; tcp&nbsp;&nbsp; 2049&nbsp; =
nfs_acl</DIV>  <DIV># modinfo | egrep "nfs|lock"<BR>&nbsp;42 7828855a&nbs=
p;&nbsp; 1d3e&nbsp; 87&nbsp;&nbsp; 1&nbsp; todds1287 (ds1287 clock driver=
 1.8)<BR>156 78428000&nbsp; 2b018 106&nbsp;&nbsp; 1&nbsp; nfs (NFS syscal=
l, client, and common)<BR>156 78428000&nbsp; 2b018 106&nbsp;&nbsp; 1&nbsp=
; nfs (NFS syscall, client, and
 common)<BR>156 78428000&nbsp; 2b018&nbsp; 16&nbsp;&nbsp; 1&nbsp; nfs (ne=
twork filesystem)<BR>156 78428000&nbsp; 2b018&nbsp;&nbsp; 7&nbsp;&nbsp; 1=
&nbsp; nfs (network filesystem version 2)<BR>156 78428000&nbsp; 2b018&nbs=
p; 17&nbsp;&nbsp; 1&nbsp; nfs (network filesystem version 3)<BR>159 78458=
000&nbsp; 12881&nbsp;&nbsp; -&nbsp;&nbsp; 1&nbsp; nfssrv (NFS server modu=
le)</DIV>  <DIV><BR>&gt;&gt;Trond<BR>Form the&nbsp;above outputs it doesn=
't look like they are running. Is this required, if yes, then </DIV>  <DI=
V>how do I turn them ON. And Why didn't we requires it for general purpos=
e NFS use ?? We have been running this server for about 2 years now. </DI=
V>  <DIV>&nbsp;</DIV>  <DIV>~thanks -ak<BR><BR></DIV><p>&#32;
      <hr size=3D1><a href=3D"
http://us.rd.yahoo.com/evt=3D49981/*http://advision.webevents.yahoo.com/m=
ailbeta/features_spam.html">Sucker-punch spam</a> with award-winning prot=
ection.<br> Try the <a href=3D"
http://us.rd.yahoo.com/evt=3D49981/*http://advision.webevents.yahoo.com/m=
ailbeta/features_spam.html">free Yahoo! Mail Beta.</a>
--0-3497556-1176399768=:20715--


--===============1739886279==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1739886279==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1739886279==--
