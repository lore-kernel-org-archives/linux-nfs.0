From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 10:01:23 -0400
Message-ID: <1121349683.8202.79.camel@lade.trondhjem.org>
References: <20050714133019.30046.qmail@web51613.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt4HZ-0000sI-2l
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 07:01:45 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt4HY-0002y3-Jf
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 07:01:45 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050714133019.30046.qmail@web51613.mail.yahoo.com>
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

to den 14.07.2005 Klokka 06:30 (-0700) skreiv mehta kiran:
> Hi Trond , 
>      Lock recovery worked with nfsv3 even if
>      nfs server fail over to some other system
>      This was possible because sm directory was shared
>      across systems.
>      Will this work with nfsv4 though there are
>      no files in sm directory. 

Servers that don't store anything to disk will usually support reboot
recovery, but will offer a more limited recovery model (i.e. one client
may find that another has stolen its locks due to races).

An server that supports the full NFSv4 state recovery model will usually
store some client information on permanent disk (recent Linux servers
store a list of all the "clientid"s in /var/lib/nfs/v4recovery).
Strictly speaking, though, this is really only necessary in order to
resolve some very obscure state recovery corner cases. For instance in
one case, a double reboot of the server combined with a network
partition may lead to 2 clients believing they have locked the same file
unless the server has stored information about which client lost its
state during the period between the 2 reboots (see the discussion in
RFC3530).

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
