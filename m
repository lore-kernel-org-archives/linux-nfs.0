From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS caching bug is back
Date: Thu, 19 Apr 2007 12:36:11 -0400
Message-ID: <1177000571.6663.25.camel@heimdal.trondhjem.org>
References: <46278E27.8050705@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Warren <warren@atmos.washington.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeZcG-0005aD-RR
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 09:36:16 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/QD6a5XzTBzZU9Smc01VL/u9A/XKDLmbk=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeZcJ-0008A3-0X
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 09:36:19 -0700
In-Reply-To: <46278E27.8050705@atmos.washington.edu>
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

On Thu, 2007-04-19 at 08:43 -0700, David Warren wrote:
> A bug that we turned in a while ago is back in the 2.6.20 kernels,
> only worse. I have found it in 2.6.20.6 and 2.6.20.7. It happens with
> both NFS4 and NFS3 mounts. Clients don't see inode changes (delete and
> recreate file):

Interesting. Do you see an OPEN request being sent to the server when
you 'cat' the file on enkf2 or enkf3? You can check either using
ethereal/wireshark, or by comparing the values in the OPEN column
in /proc/self/mountstats on the client before and after issuing the
'cat' command.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
