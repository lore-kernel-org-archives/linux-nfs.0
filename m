From: <trond.myklebust@fys.uio.no>
Subject: Re: NFS client write performance issue ... thoughts?
Date: Thu, 8 Jan 2004 18:32:46 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35321.68.42.103.198.1073583166.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----=_20040108183246_16103"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Aee1c-0001jt-Dx
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 09:32:52 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aee1b-0001iJ-GV
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 09:32:51 -0800
To: <pausmith@nortelnetworks.com>
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

------=_20040108183246_16103
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

På to , 08/01/2004 klokka 10:26, skreiv Paul Smith:

> > View server on Linux 2.4.18-27 (zcard0pf):
> >
> >    Build time: 35.75s user 31.68s system 33% cpu 3:21.02 total RPC
> calls:     94922
> >    RPC retrans:       0
> >    NFS V3 WRITE:  63317
> >    NFS V3 COMMIT: 28916
> >    NFS V3 LOOKUP:  1067
> >    NFS V3 READ:     458
> >    NFS V3 GETATTR:  406
> >    NFS V3 ACCESS      0
> >    NFS V3 REMOVE      5
> >
> > View server on Solaris 5.8 (zcars0z4)
> >
> >    Build time:  35.50s user 32.09s system 46% cpu 2:26.36 total NFS
> calls:      3785
> >    RPC retrans:       0
> >    NFS V3 WRITE:    612
> >    NFS V3 COMMIT:     7
> >    NFS V3 LOOKUP:  1986
> >    NFS V3 READ:       0
> >    NFS V3 GETATTR:  532
> >    NFS V3 ACCESS    291
> >    NFS V3 REMOVE    291

All you are basically showing here is that our write caching sucks
badly. There's nothing there to pinpoint merging vs not merging requests
as the culprit.

3 things that will affect those numbers, and cloud the issue:

  1) Linux 2.4.x has a hard limit of 256 outstanding read+write nfs_page
struct per mountpoint in order to deal with the fact that the VM does
not have the necessary support to notify us when we are low on memory
(This limit has been removed in 2.6.x...).

  2) Linux immediately puts the write on the wire once there are more
than wsize bytes to write out. This explains why bumping wsize results
in fewer writes.

  3) There are accounting errors in Linux 2.4.18 that cause
retransmitted requests to be added to the total number of transmitted
ones. That explains why switching to TCP improves matters.


Note: Try doing this with mmap(), and you will get very different
numbers, since mmap() can cache the entire database in memory, and only
flush it out when you msync() (or when memory pressure forces it to do
so).

One further criticism: there are no READ requests on the Sun machine.
That suggests that it had the database entirely in cache when you
started you test.

Cheers,
  Trond



------=_20040108183246_16103
Content-Type: text/html; name="untitled-2"
Content-Disposition: attachment; filename="untitled-2"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.9">
</HEAD>
<BODY>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="1">P&#229; to , 08/01/2004 klokka 10:26, skreiv Paul Smith:<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>&gt; View server on Linux 2.4.18-27 (zcard0pf):
&gt; 
&gt;    Build time: 35.75s user 31.68s system 33% cpu 3:21.02 total
&gt;    RPC calls:     94922
&gt;    RPC retrans:       0
&gt;    NFS V3 WRITE:  63317
&gt;    NFS V3 COMMIT: 28916
&gt;    NFS V3 LOOKUP:  1067
&gt;    NFS V3 READ:     458
&gt;    NFS V3 GETATTR:  406
&gt;    NFS V3 ACCESS      0
&gt;    NFS V3 REMOVE      5
&gt; 
&gt; View server on Solaris 5.8 (zcars0z4)
&gt; 
&gt;    Build time:  35.50s user 32.09s system 46% cpu 2:26.36 total
&gt;    NFS calls:      3785
&gt;    RPC retrans:       0
&gt;    NFS V3 WRITE:    612
&gt;    NFS V3 COMMIT:     7
&gt;    NFS V3 LOOKUP:  1986
&gt;    NFS V3 READ:       0
&gt;    NFS V3 GETATTR:  532
&gt;    NFS V3 ACCESS    291
&gt;    NFS V3 REMOVE    291</I></FONT></PRE>
</BLOCKQUOTE>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">All you are basically showing here is that our write caching sucks badly. There's nothing there to pinpoint merging vs not merging requests as the culprit.<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">3 things that will affect those numbers, and cloud the issue:<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">&nbsp; 1) Linux 2.4.x has a hard limit of 256 outstanding read+write nfs_page struct per mountpoint in order to deal with the fact that the VM does not have the necessary support to notify us when we are low on memory (This limit has been removed in 2.6.x...).<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">&nbsp; 2) Linux immediately puts the write on the wire once there are more than wsize bytes to write out. This explains why bumping wsize results in fewer writes.<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">&nbsp; 3) There are accounting errors in Linux 2.4.18 that cause retransmitted requests to be added to the total number of transmitted ones. That explains why switching to TCP improves matters.<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">Note: Try doing this with mmap(), and you will get very different numbers, since mmap() can cache the entire database in memory, and only flush it out when you msync() (or when memory pressure forces it to do so).<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">One further criticism: there are no READ requests on the Sun machine. That suggests that it had the database entirely in cache when you started you test.<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">Cheers,<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">&nbsp; Trond
</BODY>
</HTML>


------=_20040108183246_16103--



-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
