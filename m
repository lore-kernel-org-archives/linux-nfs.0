From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 11:00:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1082732429.2617.35.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DF4D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH2AJ-00070h-QL
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 08:00:31 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BH2AJ-0003mg-Ky
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 08:00:31 -0700
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DF4D@lavender-fe.eng.netapp.com>
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

On Fri, 2004-04-23 at 10:48, Lever, Charles wrote:
> there appears to be a real problem when restoring from a backup,
> or using rsync.  the file size and the mtime stay precisely the
> same, but the file handle changes.  i'm not sure anything can be
> done about this in NFSv2/3?

The only way to distinguish the two is to replace the use of the mtime
with the ctime in nfs_check_verifier() and friends.

Under ordinary circumstances, the mtime and ctime should be more or less
identical, so I'm not sure why Steve was seeing extra revalidations when
he was running the Connectathon suite. Were you perhaps changing the
algorithm in nfs_refresh_inode() instead, Steve?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
