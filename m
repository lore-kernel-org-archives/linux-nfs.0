From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFSSTAT QUESTION.
Date: Mon, 18 Mar 2002 06:58:14 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CDEA@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C1CE8D.549BC5D0"
Cc: nfs@lists.sourceforge.net
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16myai-0004nN-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Mar 2002 06:58:28 -0800
To: "'Matt Heaton'" <admin@0catch.com>
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


This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C1CE8D.549BC5D0
Content-Type: text/plain;
	charset="iso-8859-1"

as your workload and performance issue may be fairly common, let me reply on
the list.
 
the Linux NFS client uses LOOKUP operations to verify cached filehandles.
the number of exported
directories may have nothing to do with how many on-the-wire lookup
operations you see.
 
since your workload is mostly reads, try Trond's CTO patch, with the "nocto"
mount option, and let us know the results.
 

-----Original Message-----
From: Matt Heaton [mailto:admin@0catch.com]
Sent: Tuesday, March 19, 2002 12:27 AM
To: nfs@lists.sourceforge.net
Subject: [NFS] NFSSTAT QUESTION.


I have a HUGE directory structure on my NFS server.  I host free websites
and have literally 390K directories on my NFS server.  Below is output from
my NFS box.  It shows 99% of the clients time is taken by lookups (I believe
going through the directories).  I have heard there is a way through the
kernal or some other method to increase the cache associated with the
DIRECTORY LOOKUPS so that I didn't have to hit the drive everytime to get
the directory.  I have 1 GIG in the this machine and can easily upgrade it
to 4 GIG to give it a huge directory lookup cache if someone can point me in
the right direction.  My clients and my servers are both using kernal
2.4.7-10 (Redhat 7.2).
 
Thanks,
Matt Heaton
 
calls      badcalls   badauth    badclnt    xdrcall
73765732   0          0          0          0       
Server nfs v2:
null       getattr    setattr    root       lookup     readlink   
0       0% 48449   0% 77378   0% 0       0% 5527260 51% 0       0% 
read       wrcache    write      create     remove     rename     
3050391 28% 0       0% 1793260 16% 83335   0% 49376   0% 9001    0% 
link       symlink    mkdir      rmdir      readdir    fsstat     
0       0% 0       0% 13721   0% 2258    0% 153840  1% 3       0% 
 
Server nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 535201  0% 267339  0% 42856622 68% 167774  0% 0       0% 
read       write      create     mkdir      symlink    mknod      
13981454 22% 2907986  4% 340093  0% 10591   0% 0       0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
153574  0% 5102    0% 189901  0% 0       0% 272374  0% 0       0% 
fsstat     fsinfo     pathconf   commit     
42      0% 42      0% 0       0% 1269365  2% 
 
Client rpc stats:
calls      retrans    authrefrsh
2043779    0          0       
Client nfs v2:
null       getattr    setattr    root       lookup     readlink   
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
read       wrcache    write      create     remove     rename     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
link       symlink    mkdir      rmdir      readdir    fsstat     
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
 
Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 26      0% 0       0% 2043741 99% 0       0% 0       0% 
read       write      create     mkdir      symlink    mknod      
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
fsstat     fsinfo     pathconf   commit     
6       0% 6       0% 0       0% 0       0% 
 


------_=_NextPart_001_01C1CE8D.549BC5D0
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">


<META content="MSHTML 5.50.4912.300" name=GENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=#ffffff>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff size=2>as 
your workload and performance issue may be fairly common, let me reply on the 
list.</FONT></SPAN></DIV>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff size=2>the 
Linux NFS client uses LOOKUP operations to verify cached filehandles.&nbsp; the 
number of exported</FONT></SPAN></DIV>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff 
size=2>directories </FONT></SPAN><SPAN class=148295214-18032002><FONT face=Arial 
color=#0000ff size=2>may have nothing to do with how many on-the-wire lookup 
operations you see.</FONT></SPAN></DIV>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff size=2>since 
your workload is mostly reads, try Trond's CTO patch, with the 
"nocto"</FONT></SPAN></DIV>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff size=2>mount 
option, and let us know the results.</FONT></SPAN></DIV>
<DIV><SPAN class=148295214-18032002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<BLOCKQUOTE dir=ltr 
style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px solid; MARGIN-RIGHT: 0px">
  <DIV class=OutlookMessageHeader dir=ltr align=left><FONT face=Tahoma 
  size=2>-----Original Message-----<BR><B>From:</B> Matt Heaton 
  [mailto:admin@0catch.com]<BR><B>Sent:</B> Tuesday, March 19, 2002 12:27 
  AM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] NFSSTAT 
  QUESTION.<BR><BR></FONT></DIV>
  <DIV><FONT face=Arial size=2>I have a HUGE directory structure on my NFS 
  server.&nbsp; I host free websites and have literally 390K directories on my 
  NFS server.&nbsp; Below is output from</FONT></DIV>
  <DIV><FONT face=Arial size=2>my NFS box.&nbsp; It shows 99% of the clients 
  time is taken by lookups (I believe going through the directories).&nbsp; I 
  have heard there is a way through the</FONT></DIV>
  <DIV><FONT face=Arial size=2>kernal or some other method to increase the cache 
  associated with the DIRECTORY LOOKUPS so that I didn't have to hit the drive 
  everytime to get</FONT></DIV>
  <DIV><FONT face=Arial size=2>the directory.&nbsp; I have 1 GIG in the this 
  machine and can easily upgrade it to 4 GIG to give it a huge directory lookup 
  cache if someone can point me in</FONT></DIV>
  <DIV><FONT face=Arial size=2>the right direction.&nbsp; My clients and my 
  servers are both using kernal 2.4.7-10 (Redhat 7.2).</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Thanks,</FONT></DIV>
  <DIV><FONT face=Arial size=2>Matt Heaton</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>calls&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  badcalls&nbsp;&nbsp; badauth&nbsp;&nbsp;&nbsp; badclnt&nbsp;&nbsp;&nbsp; 
  xdrcall<BR>73765732&nbsp;&nbsp; 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <BR>Server nfs 
  v2:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; getattr&nbsp;&nbsp;&nbsp; 
  setattr&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  lookup&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp; 
  <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 48449&nbsp;&nbsp; 0% 
  77378&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 5527260 51% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  <BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wrcache&nbsp;&nbsp;&nbsp; 
  write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp; 
  remove&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp; <BR>3050391 28% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 1793260 16% 83335&nbsp;&nbsp; 0% 
  49376&nbsp;&nbsp; 0% 9001&nbsp;&nbsp;&nbsp; 0% 
  <BR>link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp; 
  mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  readdir&nbsp;&nbsp;&nbsp; fsstat&nbsp;&nbsp;&nbsp;&nbsp; 
  <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 13721&nbsp;&nbsp; 0% 
  2258&nbsp;&nbsp;&nbsp; 0% 153840&nbsp; 1% 
  3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% </FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Server nfs 
  v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; getattr&nbsp;&nbsp;&nbsp; 
  setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp; 
  access&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp; 
  <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 535201&nbsp; 0% 267339&nbsp; 0% 
  42856622 68% 167774&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  <BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp; 
  mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp; 
  mknod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <BR>13981454 22% 2907986&nbsp; 4% 
  340093&nbsp; 0% 10591&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% <BR>remove&nbsp;&nbsp;&nbsp;&nbsp; 
  rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp; 
  link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readdir&nbsp;&nbsp;&nbsp; 
  readdirplus<BR>153574&nbsp; 0% 5102&nbsp;&nbsp;&nbsp; 0% 189901&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 272374&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% <BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp; 
  fsinfo&nbsp;&nbsp;&nbsp;&nbsp; pathconf&nbsp;&nbsp; 
  commit&nbsp;&nbsp;&nbsp;&nbsp; <BR>42&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  42&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  1269365&nbsp; 2% </FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Client rpc 
  stats:<BR>calls&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retrans&nbsp;&nbsp;&nbsp; 
  authrefrsh<BR>2043779&nbsp;&nbsp;&nbsp; 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <BR>Client nfs 
  v2:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; getattr&nbsp;&nbsp;&nbsp; 
  setattr&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  lookup&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp; 
  <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% <BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; wrcache&nbsp;&nbsp;&nbsp; 
  write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp; 
  remove&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp; 
  <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% <BR>link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp; 
  mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  readdir&nbsp;&nbsp;&nbsp; fsstat&nbsp;&nbsp;&nbsp;&nbsp; 
  <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% </FONT></DIV>
  <DIV>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Client nfs 
  v3:<BR>null&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; getattr&nbsp;&nbsp;&nbsp; 
  setattr&nbsp;&nbsp;&nbsp; lookup&nbsp;&nbsp;&nbsp;&nbsp; 
  access&nbsp;&nbsp;&nbsp;&nbsp; readlink&nbsp;&nbsp; 
  <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 26&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 2043741 99% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% <BR>read&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  write&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; create&nbsp;&nbsp;&nbsp;&nbsp; 
  mkdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; symlink&nbsp;&nbsp;&nbsp; 
  mknod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% <BR>remove&nbsp;&nbsp;&nbsp;&nbsp; 
  rmdir&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; rename&nbsp;&nbsp;&nbsp;&nbsp; 
  link&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; readdir&nbsp;&nbsp;&nbsp; 
  readdirplus<BR>0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% <BR>fsstat&nbsp;&nbsp;&nbsp;&nbsp; fsinfo&nbsp;&nbsp;&nbsp;&nbsp; 
  pathconf&nbsp;&nbsp; commit&nbsp;&nbsp;&nbsp;&nbsp; 
  <BR>6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 
  6&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
  0% 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0% </FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV></BLOCKQUOTE></BODY></HTML>

------_=_NextPart_001_01C1CE8D.549BC5D0--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
