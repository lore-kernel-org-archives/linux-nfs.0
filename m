From: "Guzovsky, Eduard" <Edg@CROSSBEAMSYS.COM>
Subject: RE: linux 2.4.18-5 nfs/rpc problem
Date: Fri, 10 Oct 2003 20:18:16 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6FF58CD33A029D458692432F07B85AB713FBA2@newmail>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C38F8D.2A5D37BE"
Cc: nfs@lists.sourceforge.net, "Pariseau, Luc"
	 <LPariseau@CROSSBEAMSYS.COM>, "A.K. Srikanth" <aks@CROSSBEAMSYS.COM>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A88D5-0003gN-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Oct 2003 18:06:19 -0700
Received: from [66.37.203.189] (helo=cbsvr1.crossbeamsys.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A88D4-0003J4-4s
	for nfs@lists.sourceforge.net; Fri, 10 Oct 2003 18:06:18 -0700
To: 'Trond Myklebust' <trond.myklebust@fys.uio.no>, David Jeffery
	 <david_jeffery@adaptec.com>
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C38F8D.2A5D37BE
Content-Type: text/plain;
	charset="iso-8859-1"

David, we were able to consistently reproduce the problem. 
After I made modifications Trond suggested we do not
see the problem any more. So I would say it is fixed.
Trond, will this fix make it into 2.2.24 ? 

Thank you very much for your help,

-Ed
 

 > -----Original Message-----
 > From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
 > Sent: Friday, October 10, 2003 2:58 PM
 > To: David Jeffery
 > Cc: Guzovsky, Eduard; nfs@lists.sourceforge.net
 > Subject: Re: [NFS] linux 2.4.18-5 nfs/rpc problem
 > 
 > 
 > >>>>> " " == David Jeffery <david_jeffery@adaptec.com> writes:
 > 
 >      > Eduard, I have also seen this problem with both Red Hat and
 >      > stock kernels.  I've got some patches That I'm testing to try
 >      > and fix the problem for me, but it takes a while for my setup
 >      > to reproduce the problem.  How easy is it for you to trigger?
 > 
 >      > I've attached two patches for 2.4.22 that I'm currently
 >      > testing.  The first (nfsiput.patch) is to fix the deadlocked
 >      > processes you see by moving the iput() call to happen 
 > after the
 >      > waited on request is unlocked.
 > 
 > I take it you're assuming that the problem is a deadlock due to
 > clear_inode() hanging on our page lock? That does indeed appear to be
 > a possible source of contention.
 > 
 > Instead of your 2 patches, though, how about just ensuring that
 > anybody calling nfs_wait_on_requests() already has a reference to the
 > inode?
 > 
 > There is indeed one case where this is not being done: in
 > page_launder() you only have a lock on the page. This means that you
 > may end up calling nfs_wait_on_request() in order to flush out a page
 > only to discover that it called iput() from beneath you and is now
 > waiting in clear_inode() on your page lock.
 > 
 > Cheers,
 >   Trond
 > 
 > --- linux-2.4.23-pre5/fs/nfs/write.c.orig	2003-07-09 
 > 14:11:04.000000000 -0400
 > +++ linux-2.4.23-pre5/fs/nfs/write.c	2003-10-10 
 > 14:54:16.000000000 -0400
 > @@ -225,8 +225,19 @@
 >  	struct inode *inode = page->mapping->host;
 >  	unsigned long end_index;
 >  	unsigned offset = PAGE_CACHE_SIZE;
 > +	int inode_referenced = 0;
 >  	int err;
 >  
 > +	/*
 > +	 * Note: We need to ensure that we have a reference to the inode
 > +	 *       if we are to do asynchronous writes. If not, waiting
 > +	 *       in nfs_wait_on_request() may deadlock with 
 > clear_inode().
 > +	 *
 > +	 *       If igrab() fails here, then it is in any case safe to
 > +	 *       call nfs_wb_page(), since there will be no 
 > pending writes.
 > +	 */
 > +	if (igrab(inode) != 0)
 > +		inode_referenced = 1;
 >  	end_index = inode->i_size >> PAGE_CACHE_SHIFT;
 >  
 >  	/* Ensure we've flushed out any previous writes */
 > @@ -244,7 +255,8 @@
 >  		goto out;
 >  do_it:
 >  	lock_kernel();
 > -	if (NFS_SERVER(inode)->wsize >= PAGE_CACHE_SIZE && 
 > !IS_SYNC(inode)) {
 > +	if (NFS_SERVER(inode)->wsize >= PAGE_CACHE_SIZE && 
 > !IS_SYNC(inode) &&
 > +			inode_referenced) {
 >  		err = nfs_writepage_async(NULL, inode, page, 0, offset);
 >  		if (err >= 0)
 >  			err = 0;
 > @@ -256,7 +268,9 @@
 >  	unlock_kernel();
 >  out:
 >  	UnlockPage(page);
 > -	return err; 
 > +	if (inode_referenced)
 > +		iput(inode);
 > +	return err;
 >  }
 >  
 >  /*
 > 

------_=_NextPart_001_01C38F8D.2A5D37BE
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-1">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2653.12">
<TITLE>RE: [NFS] linux 2.4.18-5 nfs/rpc problem</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=3D2>David, we were able to consistently reproduce the =
problem. </FONT>
<BR><FONT SIZE=3D2>After I made modifications Trond suggested we do =
not</FONT>
<BR><FONT SIZE=3D2>see the problem any more. So I would say it is =
fixed.</FONT>
<BR><FONT SIZE=3D2>Trond, will this fix make it into 2.2.24 ? </FONT>
</P>

<P><FONT SIZE=3D2>Thank you very much for your help,</FONT>
</P>

<P><FONT SIZE=3D2>-Ed</FONT>
<BR><FONT SIZE=3D2>&nbsp;</FONT>
</P>

<P><FONT SIZE=3D2>&nbsp;&gt; -----Original Message-----</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; From: Trond Myklebust [<A =
HREF=3D"mailto:trond.myklebust@fys.uio.no">mailto:trond.myklebust@fys.ui=
o.no</A>]</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; Sent: Friday, October 10, 2003 2:58 =
PM</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; To: David Jeffery</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; Cc: Guzovsky, Eduard; =
nfs@lists.sourceforge.net</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; Subject: Re: [NFS] linux 2.4.18-5 nfs/rpc =
problem</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; &gt;&gt;&gt;&gt;&gt; &quot; &quot; =3D=3D =
David Jeffery &lt;david_jeffery@adaptec.com&gt; writes:</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; =
Eduard, I have also seen this problem with both Red Hat and</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; stock =
kernels.&nbsp; I've got some patches That I'm testing to try</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; and =
fix the problem for me, but it takes a while for my setup</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; to =
reproduce the problem.&nbsp; How easy is it for you to trigger?</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; I've =
attached two patches for 2.4.22 that I'm currently</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; =
testing.&nbsp; The first (nfsiput.patch) is to fix the =
deadlocked</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; =
processes you see by moving the iput() call to happen </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; after the</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &gt; waited =
on request is unlocked.</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; I take it you're assuming that the =
problem is a deadlock due to</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; clear_inode() hanging on our page lock? =
That does indeed appear to be</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; a possible source of contention.</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; Instead of your 2 patches, though, how =
about just ensuring that</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; anybody calling nfs_wait_on_requests() =
already has a reference to the</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; inode?</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; There is indeed one case where this is =
not being done: in</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; page_launder() you only have a lock on =
the page. This means that you</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; may end up calling nfs_wait_on_request() =
in order to flush out a page</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; only to discover that it called iput() =
from beneath you and is now</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; waiting in clear_inode() on your page =
lock.</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; Cheers,</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp;&nbsp; Trond</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; --- =
linux-2.4.23-pre5/fs/nfs/write.c.orig&nbsp;&nbsp;&nbsp; 2003-07-09 =
</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; 14:11:04.000000000 -0400</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +++ linux-2.4.23-pre5/fs/nfs/write.c =
2003-10-10 </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; 14:54:16.000000000 -0400</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; @@ -225,8 +225,19 @@</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; struct inode =
*inode =3D page-&gt;mapping-&gt;host;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; unsigned long =
end_index;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; unsigned offset =
=3D PAGE_CACHE_SIZE;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; int inode_referenced =
=3D 0;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; int err;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; /*</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp;&nbsp; * Note: We need =
to ensure that we have a reference to the inode</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp;&nbsp; =
*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if we are to do asynchronous =
writes. If not, waiting</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp;&nbsp; =
*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; in nfs_wait_on_request() may =
deadlock with </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; clear_inode().</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp;&nbsp; *</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp;&nbsp; =
*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; If igrab() fails here, then it is =
in any case safe to</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp;&nbsp; =
*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; call nfs_wb_page(), since there =
will be no </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; pending writes.</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp;&nbsp; */</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; if (igrab(inode) !=3D =
0)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inode_referenced =3D =
1;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; end_index =3D =
inode-&gt;i_size &gt;&gt; PAGE_CACHE_SHIFT;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; /* Ensure we've =
flushed out any previous writes */</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; @@ -244,7 +255,8 @@</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto out;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; do_it:</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; =
lock_kernel();</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; -&nbsp;&nbsp;&nbsp; if =
(NFS_SERVER(inode)-&gt;wsize &gt;=3D PAGE_CACHE_SIZE &amp;&amp; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; !IS_SYNC(inode)) {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; if =
(NFS_SERVER(inode)-&gt;wsize &gt;=3D PAGE_CACHE_SIZE &amp;&amp; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; !IS_SYNC(inode) &amp;&amp;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inode_referenced) {</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; err =3D =
nfs_writepage_async(NULL, inode, page, 0, offset);</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (err &gt;=3D 0)</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; err =3D 0;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; @@ -256,7 +268,9 @@</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; =
unlock_kernel();</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; out:</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; &nbsp;&nbsp;&nbsp; =
UnlockPage(page);</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; -&nbsp;&nbsp;&nbsp; return err; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; if (inode_referenced)<=
/FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; iput(inode);</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; +&nbsp;&nbsp;&nbsp; return err;</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; }</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; </FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt;&nbsp; /*</FONT>
<BR><FONT SIZE=3D2>&nbsp;&gt; </FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C38F8D.2A5D37BE--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
