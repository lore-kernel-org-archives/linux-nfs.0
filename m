From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: nfs4 filesystem mounted via the "bind" option reports wrong
	fstype
Date: Mon, 27 Aug 2007 20:32:51 +0200
Message-ID: <46D318D3.9020101@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	jkar8572@users.sourceforge.net
To: nfsv4@linux-nfs.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPjOV-0001TQ-8o
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 11:32:59 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPjOW-0003lP-JC
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 11:33:03 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

A nfs4 filesystem, mounted elsewhere via the "bind" option (the usual 
way to do with nfsv4 and its pseudofs), reports wrong fstype "nfs" 
instead of "nfs4" filesystem.
An example is much easier to understand :
Server-side :
- /exports is the pseudo root filesystem (fsid=0 option in /etc/exports)
- /exports/data is a mountpoint for another filesystem (not the same 
device-id as /exports). This condition seems to be what triggers the bug
- /exports/data must be exported with the "nohide" option (again, the 
usual way to do se with nfsv4)

Client-side :
- mount server:/  on /imports
- mount "bind" /imports/data on /home/data
(this magically shows a second nfs mount in /proc/mounts)
And here is the bug : this second mount is of fstype "nfs" instead of 
"nfs4" although the options field contains "vers=4".

This is like a cosmetic bug, but this becomes a problem when some apps 
need to differentiate nfs and nfs4 fstype (e.g. linuxquota uses it to 
know how to handle the nfs source-path)

Gabriel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
