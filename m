From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: [ANNOUNCE] patch for using >16 groups on 2.6.10 NFSv[23] client
Date: Mon, 7 Feb 2005 00:34:45 +0100
Message-ID: <20050206233445.GA11372@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cxvvb-0008SR-IN
	for nfs@lists.sourceforge.net; Sun, 06 Feb 2005 15:34:55 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CxvvZ-0001Ke-Vx
	for nfs@lists.sourceforge.net; Sun, 06 Feb 2005 15:34:55 -0800
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
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

This is the very first release of the many-groups patch for 2.6.x:

	http://www.frankvm.com/nfs-ngroups/2.6.10-nfs-ngroups-4.52.patch
	http://www.frankvm.com/nfs-ngroups/README

For a broken down version of this patch, see:

	http://www.frankvm.com/nfs-ngroups/2.6.10/



>From the above mentioned README:


Patch version 4.x
=================
Group id cache is gone. At the top NFS layer the group ids of
"interesting" file-system objects are collected (max 3, mostly 1) and
passed downwards. When an RPC credential is created the new AUTH_UNIX
specific unx_add_groups() function will add all the necessary group
information. When the number of groups is 16 or lower then it reverts
to old behavior. When there is no group id information passed downwards
then it reverts to old behavior too. Otherwise, only groups present in
_both_ group information passed downwards and the secondary group list
will be used for the AUTH_UNIX rpc credential (i.e. group lists are
intersected).

The patch has become significantly larger, mostly due to restructuring
and some cleanups:
-	removed broken_suid mount option.
-	reduced the number of rpc_message instantiations.

Also note that NFSv4 is not yet supported. Don't try this with a 2.6.x
server because at least 2.6.10 and 2.6.11-rc3 seem to have an NFS
ACCESS bug.


BUG REPORTS
-----------
If you think something didn't work as expected then it would be
helpful if you mail it and possibly include a relevant section of
/var/log/messages after reproducing the problem with

        echo 16 >/proc/sys/sunrpc/rpc_debug
        echo 17 >/proc/sys/sunrpc/nfs_debug

It is probably best to try to reproduce the problem with the "noac"
mount option.


-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
