From: Nick Couchman <nick-lists@seakr.com>
Subject: Re: Root Over NFS Memory Problem
Date: Thu, 04 Mar 2004 07:18:57 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078409937.3882.10.camel@nick0.seakr.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-JTf6cYKXbQ07712tBjZ9"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aytmh-00035e-VP
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 06:25:12 -0800
Received: from gw2.seakr.com ([209.144.181.2] helo=mail-gw.seakr.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AytN4-00021A-Dx
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 05:58:42 -0800
Received: from scan-gw.seakr.com (seakr5.seakr.com [192.168.100.10])
	by mail-gw.seakr.com (8.12.10/8.12.10) with ESMTP id i24EEW6a020285
	for <nfs@lists.sourceforge.net>; Thu, 4 Mar 2004 07:14:32 -0700
Received: from nick0.seakr.com (nick0 [192.168.10.70])
	by seakr5.seakr.com (8.10.2/8.10.2) with ESMTP id i24EIwZ18198
	for <nfs@lists.sourceforge.net>; Thu, 4 Mar 2004 07:18:58 -0700 (MST)
To: nfs@lists.sourceforge.net
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


--=-JTf6cYKXbQ07712tBjZ9
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

> We are running currently 43 system over a nfs root filesystem and 
> none of those systems is suffering from such memory leak. So I 
> really don't think this is a vanilla kernel issue. If you are sure >
that its the kernel, try without OpenMosix and other patches.
>
> Cheers,
>        Bernd

Two things: 1) What version of the kernel are you running?  2) We have
another Linux box running the same kernel, but it is not booting
root-over-NFS, it is using the local hard drive.  This machine does not
"leak" memory.  Other ideas?  Could it be portmap?

--Nick
-- 
Nick Couchman
Information Technology
SEAKR Engineering, Inc.
Phone: (303) 790-8499
Fax: (303) 790-8720
Web: http://www.seakr.com

--=-JTf6cYKXbQ07712tBjZ9
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.9">
</HEAD>
<BODY>
<TT>&gt; We are running currently 43 system over a nfs root filesystem and <BR>
&gt; none of those systems is suffering from such memory leak. So I <BR>
&gt; really don't think this is a vanilla kernel issue. If you are sure &gt; that its the kernel, try without OpenMosix and other patches.<BR>
&gt;<BR>
&gt; Cheers,<BR>
&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Bernd<BR>
<BR>
Two things: 1) What version of the kernel are you running?&nbsp; 2) We have another Linux box running the same kernel, but it is not booting root-over-NFS, it is using the local hard drive.&nbsp; This machine does not &quot;leak&quot; memory.&nbsp; Other ideas?&nbsp; Could it be portmap?<BR>
<BR>
--Nick</TT><BR>
<TABLE CELLSPACING="0" CELLPADDING="0" WIDTH="100%">
<TR>
<TD>
<PRE>-- 
Nick Couchman
Information Technology
SEAKR Engineering, Inc.
Phone: (303) 790-8499
Fax: (303) 790-8720
Web: http://www.seakr.com</PRE>
</TD>
</TR>
</TABLE>

</BODY>
</HTML>

--=-JTf6cYKXbQ07712tBjZ9--



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
