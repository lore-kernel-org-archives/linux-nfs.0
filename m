From: Danny Smith <dannys@cinesite.co.uk>
Subject: NFSERR_EAGAIN
Date: Thu, 10 Jul 2003 19:29:28 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F0DB088.303@cinesite.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Iain Irwin-Powell <Iain@cinesite.co.uk>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19agBJ-00086s-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Jul 2003 11:30:28 -0700
Received: from sirius.cinesite.co.uk (sirius.cinesite.co.uk [10.66.0.23])
	by scanman.cinesite.co.uk (8.9.3/8.9.3) with ESMTP id TAA04332
	for <nfs@lists.sourceforge.net>; Thu, 10 Jul 2003 19:29:29 +0100 (BST)
To: nfs <nfs@lists.sourceforge.net>
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

I've been trying to resolve some issues we have with a set of systems 
running 2.4.20+NFS_ALL, dual CPU and Gigabit Ethernet. They're talking 
to SGI IRIX servers, (6.5.19), and having intermittent problems - this 
can be seen sometimes where an NFS mounted directory will "disappear", 
but subsequently be accessible. No errors are returned to the shell - 
the directory just appears to have no entries.

This seems (although I don't have proof positive yet, more testing is in 
progrees) to coincide with errors in the logs:

Jul  9 14:18:09 trout-node13 kernel: nfs_stat_to_errno: bad nfs status 
return value: 11

Looking through nfs2xdr.c and nfs.h and googling, it seems that error 
number 11 is not properly defined, but certainly seems to be in use by 
SGI. From nfs2xdr.c:
 
      { NFSERR_NXIO,         ENXIO         },
/*    { NFSERR_EAGAIN,       EAGAIN        }, */
      { NFSERR_ACCES,        EACCES        },

(EAGAIN having value 11)

Does anyone know much about the history of this? Was this removed in 
order to be RFC compliant, or is there a stronger motivation not to have 
this?

It would maybe explain what I'm seeing if SGI are interpreting error 11 
as "Try again" - this mainly happens when server load is high.

Any insight into this would be welcome - meanwhile I'm going to try some 
tests with NFSERR_EGAIN put back in.

Danny

-- 
Danny Smith
Senior Systems Administrator, Cinesite (Europe) Ltd
020 7973 4000 - x4055    /    dannys@cinesite.co.uk




-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
