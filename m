From: Eric Garland <perlfs2@ericgarland.com>
Subject: NFS support for PerlFS
Date: Fri, 02 May 2003 03:01:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EB217D7.6080706@ericgarland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from h0002b3a89c72.ne.client2.attbi.com ([24.62.242.148] helo=server.ericgarland.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19BUYE-0006I2-00
	for <nfs@lists.sourceforge.net>; Fri, 02 May 2003 00:01:46 -0700
Received: from ericgarland.com (lurch [10.0.0.4])
	by server.ericgarland.com (8.12.5/8.12.5) with ESMTP id h4271eMq002176
	for <nfs@lists.sourceforge.net>; Fri, 2 May 2003 03:01:41 -0400
To: nfs@lists.sourceforge.net
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

  I'm looking to add support to the PerlFS filesystem so
it can be exported using NFS.  From reading the
interface requirements it would seem the way to do
that would be to turn on the FS_REQUIRES_DEV flag in
the file_system_type structure that get's registered.
This works execpt I then need to pass a valid device
file into the mount command or mount doesn't work. 
The device I pass in doesn't have any bearing on the
filesystem that get's mounted which doesn't really make
much sense.

Is there any way of making the NFS server not
check the NFS_REQUIRES_DEV flag?

    -Eric



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
