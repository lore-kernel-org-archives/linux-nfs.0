From: Chris Penney <cpenney@gmail.com>
Subject: NAT & lockd
Date: Fri, 8 Apr 2005 09:25:08 -0400
Message-ID: <111aefd050408062546161db8@mail.gmail.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJtU6-00080E-EI
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 06:25:18 -0700
Received: from wproxy.gmail.com ([64.233.184.197])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJtU4-00080C-VI
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 06:25:18 -0700
Received: by wproxy.gmail.com with SMTP id 69so841155wra
        for <nfs@lists.sourceforge.net>; Fri, 08 Apr 2005 06:25:08 -0700 (PDT)
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

I have an new NFS server (2.6.11.5 w/ NFS-ALL) that serves some
clients that sit behind a NAT box (linux clusters).  It replaced a
SLES 8 file server.   The NAT box is a old RH8 box (soone to be
upgraded to SLES 9).  On the new NFS server I'm getting the following
messages from lockd:

nsm_mon_unmon: rpc failed, status=-13
lockd: cannot monitor x.x.x.x

With our old NFS server I never got any messages.  The IP address
x.x.x.x is that of the NAT box.  I'm curious if this means locking
does not work behind nat or if it means something else.  Is there
anything I can do here?  Would a 2.6.x based NAT box have a more up to
date iptables that supports lockd?  This is non-critical, I'm just
trying to understand.

   Chris


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
