From: "Wendy Cheng" <wendy.cheng@falconstor.com>
Subject: fh_lock again
Date: Mon, 17 Feb 2003 14:44:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <007a01c2d6bd$08739230$c5e31a42@tamarac>
Reply-To: "Wendy Cheng" <wendy.cheng@falconstor.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0077_01C2D693.1D3A6CE0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.105.142.2] (helo=falconstorex.falconstor.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18krCq-0001A1-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 11:45:36 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.

------=_NextPart_000_0077_01C2D693.1D3A6CE0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset="iso-8859-1"

On 2.4.19 kernel within nfsd_create():

there is a check to see whether the response file=20
handle has been verified:

if (!resfph->fh_dentry) {
    fh_lock(fhp);
    ....
}

The inode semaphore withing the fh_lock() hangs one of
the nfsds while running a failover test (we're trying out a=20
high availability file server design). The client is doing a=20
"mkdir" request. Similar problems are also found in=20
"remove" and "rmdir" requests. All runs are under NFS
version 3.

Unlike the remove and rmdir where we added "fh_put"=20
after the nfsd_unlink() calls to make the hang go away,
the hang within the nfsd_create() makes me a little bit
uneasy. Not sure whether we do something wrong in
the failover logic or it is just simply a linux nfsd coding
oversight - could some nfsd gurus take a look (linux/open
source is a new thing to me). My question is, in simple
words, where should this inode semaphore (inode->i_sem)
get released ? Is this a nfs v3 coding oversight or the=20
semaphore is released somewhere in nfsd path that I don't=20
know about (found a fh_put in nfssvc_release_fhandle()
within nfsxdr.c but with xdr's extensive use of function pointers,
it is hard to figure out who uses it).

Any help would be greatly appreciated.

Wendy

------=_NextPart_000_0077_01C2D693.1D3A6CE0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1141" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>On 2.4.19 kernel within =
nfsd_create():</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>there is a check to see whether the =
response file=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>handle has been verified:</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>if (!resfph-&gt;fh_dentry) =
{</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; =
fh_lock(fhp);</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>&nbsp;&nbsp;&nbsp; ....</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>}</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>The inode semaphore withing the =
fh_lock() hangs one=20
of</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the nfsds while running a failover test =
(we're=20
trying out a </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>high </FONT><FONT face=3DArial =
size=3D2>availability=20
file server design). The client is doing a </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>"mkdir" request. Similar problems are =
also found in=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>"remove" and "rmdir" requests. All runs =
are under=20
NFS</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>version 3.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Unlike the remove and rmdir where we =
added "fh_put"=20
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>after the nfsd_unlink() calls to make =
the hang go=20
away,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the hang within the =
nfsd_create()&nbsp;makes me a=20
little bit</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>uneasy. Not sure whether we do =
something wrong=20
in</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>the failover&nbsp;logic or it is just =
simply a=20
linux nfsd coding</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>oversight - could some nfsd gurus take =
a look=20
(linux/open</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>source is a new thing to me). My =
question is, in=20
simple</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>words, where should this inode =
semaphore=20
(inode-&gt;i_sem)</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>get released ? Is this a nfs v3 coding =
oversight or=20
the </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>semaphore is released somewhere in nfsd =
path that I=20
don't </FONT></DIV>
<DIV><FONT face=3DArial size=3D2>know about (found a fh_put in=20
nfssvc_release_fhandle()</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>within nfsxdr.c but with xdr's =
extensive use of=20
function pointers,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>it is hard to figure out who uses =
it).</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Any help would be greatly =
appreciated.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>Wendy</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV></BODY></HTML>

------=_NextPart_000_0077_01C2D693.1D3A6CE0--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
