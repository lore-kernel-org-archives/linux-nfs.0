From: AK <amithl_prem@yahoo.com>
Subject: Re: POSIX I/O on NFS with noac option
Date: Thu, 12 Apr 2007 11:19:47 -0700 (PDT)
Message-ID: <300878.76957.qm@web56603.mail.re3.yahoo.com>
References: <1176400607.6664.31.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1129848477=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc3tg-0006Bx-2U
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 11:19:52 -0700
Received: from web56603.mail.re3.yahoo.com ([66.196.97.47])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Hc3th-0003Tx-1A
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 11:19:54 -0700
In-Reply-To: <1176400607.6664.31.camel@heimdal.trondhjem.org>
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

--===============1129848477==
Content-Type: multipart/alternative; boundary="0-1182282374-1176401987=:76957"
Content-Transfer-Encoding: 7bit

--0-1182282374-1176401987=:76957
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

 =20
If it has been running for 2 years, then I'd say you clearly haven't
been using locking over NFS against it.

Check your Solaris admin manual for details on how to turn on the
locking manager and lock status daemon.

Cheers
Trond
  =20
  =20
  ~ thanks Trond, will try that and get back!!! -al


      =20
---------------------------------
Food fight? Enjoy some healthy debate
in the Yahoo! Answers Food & Drink Q&A.
--0-1182282374-1176401987=:76957
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<BLOCKQUOTE class=3Dreplbq style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; =
BORDER-LEFT: #1010ff 2px solid">  <div><BR>If it has been running for 2 y=
ears, then I'd say you clearly haven't<BR>been using locking over NFS aga=
inst it.<BR><BR>Check your Solaris admin manual for details on how to tur=
n on the<BR>locking manager and lock status daemon.<BR><BR>Cheers<BR>Tron=
d</div>  <div>&nbsp;</div>  <div>&nbsp;</div>  <div>~ thanks Trond, will =
try that and get back!!! -al</div></BLOCKQUOTE><BR><p>&#32;
      <hr size=3D1><a href=3D"http://answers.yahoo.com/dir/index;_ylc=3DX=
3oDMTFvbGNhMGE3BF9TAzM5NjU0NTEwOARfcwMzOTY1NDUxMDMEc2VjA21haWxfdGFnbGluZQ=
RzbGsDbWFpbF90YWcx?link=3Dask&sid=3D396545367">Food fight?</a> Enjoy some=
 healthy debate<br>in the <a href=3D"http://answers.yahoo.com/dir/index;_=
ylc=3DX3oDMTFvbGNhMGE3BF9TAzM5NjU0NTEwOARfcwMzOTY1NDUxMDMEc2VjA21haWxfdGF=
nbGluZQRzbGsDbWFpbF90YWcx?link=3Dask&sid=3D396545367">Yahoo! Answers Food=
 & Drink Q&A.</a>
--0-1182282374-1176401987=:76957--


--===============1129848477==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1129848477==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1129848477==--
