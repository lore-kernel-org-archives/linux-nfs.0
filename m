From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Millions of files and directory caching.
Date: Mon, 21 Oct 2002 07:59:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54FA5@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C27912.6C69F210"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183e1j-0006LE-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Oct 2002 07:59:31 -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C27912.6C69F210
Content-Type: text/plain;
	charset="iso-8859-1"

the way to increase the client-side cache is to add RAM.  the client will
make appropriate use
of the new memory automatically.  you should try to find out how large your
active file set is,
and increase your client caches to fit.  that will greatly reduce the amount
of cache turnover
there is on the NFS clients.  however, since the actual data bandwidth on
your servers is
fairly low, i'd say you have already reached that point.
 
NFS clients do a lot of lookups and getattrs by nature.  the only way you
can tell if the clients
are overloading the servers is if lookup and getattr requests take longer
than a few milliseconds.
a brief network trace during a period of heavy load might help.  if your
servers take a long time
to respond, try adding more RAM to the servers, or increase the number of
server threads.
 
adding more RAM won't reduce the rate at which the client tries to
revalidate the parts of the
directory structure it has already cached.  the client may have all of it
cached, but you need
to lengthen the attribute cache timeout to reduce the revalidation
frequency.  since you don't
run 2.4.19, you won't need the "nocto" mount option to take advantage of
this.

-----Original Message-----
From: Matt Heaton [mailto:admin@0catch.com]
Sent: Sunday, October 20, 2002 11:06 PM
To: nfs@lists.sourceforge.net
Subject: [NFS] Millions of files and directory caching.


I run a hosting service that hosts about 700,000 websites.  We have 2 NFS
servers running Redhat 7.2 (2.4.18 custom kernal, no
nfs patches).  The servers are 850 GIGS each (IDE RAID 5). THe clients are
all 7.2 Redhat with custom 2.4.18 kernels on them.  My question is this.  I
believe lookups/attribs on the files and directories are slowing down
performance considerably because we literally have 4-5 million files on each
nfs server that we export.  One of the NFS servers is running EXT3 and the
other is XFS.  Both work ok, but under heavy loads the clients die because
the server can't export stuff fast enough.  The total bandwidth out of each
NFS server is LESS than 10 Mbit.  The trouble is that I am serving a bunch
of SMALL files.  Either I am running out of seek time on my boxes (IDE Raid
850 GIGS per server), or it is taking forever to find the files. 
 
Here are my questions.
 
1) Can I increase the cache on the client side to hold the entire directory
structure of both NFS servers?
 
2) How can I tell if I am just maxing the seek time out on my NFS server?
 
3) Each NFS server serves about 60-100 files per second.  Is this too many
per second?  Could I possibly be maxing
out seek time on the NFS servers?  My IDE Raid card is the 3ware 750 with 8
individual IDE ports on it.
 
4) Is there anything like cachefs being developed for linux??  Any other
suggestions for persistent client caching for NFS?
Free or commercial is fine.
 
Thanks for your answers to some or all of my questions.
 
Matt
 
 


------_=_NextPart_001_01C27912.6C69F210
Content-Type: text/html;
	charset="iso-8859-1"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">


<META content="MSHTML 6.00.2800.1106" name=GENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=#ffffff>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>the 
way to increase the client-side cache is to add RAM.&nbsp; the client will make 
appropriate use</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>of the 
new memory automatically.&nbsp; you should try to find out how large your active 
file set is,</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>and 
increase your client caches to fit.&nbsp; that will greatly reduce the amount of 
cache turnover</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>there 
is on the NFS clients.&nbsp; however, since the actual data bandwidth on your 
servers is</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002>fairly low, i'd say you have already reached 
that point.</SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>NFS clients do a lot of lookups and getattrs by 
nature.&nbsp; the only way you can tell if the clients</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>are 
overloading the servers is if </FONT></SPAN><SPAN class=887304014-21102002><FONT 
face=Arial color=#0000ff size=2>lookup and getattr requests take longer than a 
few milliseconds.</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>a 
brief network trace during&nbsp;a period of heavy load might help.&nbsp; 
</FONT></SPAN><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff 
size=2>if your servers take a long time</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>to 
respond, try adding more RAM to the servers, or increase </FONT></SPAN><SPAN 
class=887304014-21102002><FONT face=Arial color=#0000ff size=2>the number of 
server threads.</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>adding 
more RAM won't reduce the rate at which the client tries to revalidate the parts 
of the</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff 
size=2>directory structure it has already cached.&nbsp;&nbsp;the client&nbsp;may 
have all of it cached, but you need</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>to 
lengthen </FONT></SPAN><SPAN class=887304014-21102002><FONT face=Arial 
color=#0000ff size=2>the attribute cache timeout to reduce the revalidation 
frequency.&nbsp; since you don't</FONT></SPAN></DIV>
<DIV><SPAN class=887304014-21102002><FONT face=Arial color=#0000ff size=2>run 
2.4.19, </FONT></SPAN><SPAN class=887304014-21102002><FONT face=Arial 
color=#0000ff size=2>you won't need the "nocto" mount option to take advantage 
of this.</FONT></SPAN></DIV>
<BLOCKQUOTE dir=ltr 
style="PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px solid; MARGIN-RIGHT: 0px">
  <DIV class=OutlookMessageHeader dir=ltr align=left><FONT face=Tahoma 
  size=2>-----Original Message-----<BR><B>From:</B> Matt Heaton 
  [mailto:admin@0catch.com]<BR><B>Sent:</B> Sunday, October 20, 2002 11:06 
  PM<BR><B>To:</B> nfs@lists.sourceforge.net<BR><B>Subject:</B> [NFS] Millions 
  of files and directory caching.<BR><BR></FONT></DIV>
  <DIV><FONT face=Arial size=2>I run a hosting service that hosts about 700,000 
  websites.&nbsp; We have 2 NFS servers running Redhat 7.2 (2.4.18 custom 
  kernal, no</FONT></DIV>
  <DIV><FONT face=Arial size=2>nfs patches).&nbsp; The servers are 850 GIGS each 
  (IDE RAID 5). THe clients are all 7.2 Redhat with custom 2.4.18 kernels on 
  them.&nbsp; My question is this.&nbsp; I believe lookups/attribs on the 
  </FONT><FONT face=Arial size=2>files and directories are slowing down 
  performance considerably because we literally have 4-5 million files on each 
  nfs server that we export.&nbsp; One of the NFS servers is running EXT3 and 
  the other is XFS.&nbsp; Both work ok, but under heavy loads the clients die 
  because the server can't export stuff fast enough.&nbsp; The total bandwidth 
  out of each NFS server is LESS than 10 Mbit.&nbsp; The trouble is that I am 
  serving a bunch of SMALL files.&nbsp; Either I am running out of seek time on 
  my boxes (IDE Raid 850 GIGS per server), or it is taking forever to find the 
  files. </FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Here are my questions.</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>1) Can I increase the cache on the client side to 
  hold the entire directory structure of both NFS servers?</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>2) How can I tell if I am just maxing the seek 
  time out on my NFS server?</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>3) Each NFS server serves about 60-100 files per 
  second.&nbsp; Is this too many per second?&nbsp; Could I possibly be 
  maxing</FONT></DIV>
  <DIV><FONT face=Arial size=2>out seek time on the NFS servers?&nbsp; My IDE 
  Raid card is the 3ware 750 with 8 individual IDE ports on it.</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>4) Is there anything like cachefs being developed 
  for linux??&nbsp; Any other suggestions for persistent client caching for 
  NFS?</FONT></DIV>
  <DIV><FONT face=Arial size=2>Free or commercial is fine.</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Thanks for your answers to some or all of my 
  questions.</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2>Matt</FONT></DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>
  <DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV></BLOCKQUOTE></BODY></HTML>

------_=_NextPart_001_01C27912.6C69F210--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
