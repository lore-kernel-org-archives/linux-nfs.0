From: Phil Garcia <apgarcia@oppie.phys.uwm.edu>
Subject: nfsd, high load
Date: Mon, 7 Apr 2003 16:06:56 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030407210656.GA16047@oppie.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from oppie.phys.uwm.edu
	([129.89.57.60] helo=oppie ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 192dpw-00031x-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Apr 2003 14:07:28 -0700
Received: from apgarcia by oppie with local (Exim 3.35 #1 (Debian))
	id 192dpQ-0004BG-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Apr 2003 16:06:56 -0500
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

Hi,

We experience some trouble when 200+ nodes mount the same NFS
directory, each opening a different file and writing a small number of
bytes to it.  Even though we're not using anywhere near the capacity
of the ethernet card or the disk writing speed, the load average on
the server goes up to above 20 or so, and the system is very slow.
The system is a dual Athlon MP 1800+, but the cpu usage is near 100%,
practically all of which is spent in "system time" (vmstat).  Do you
understand why this is happening, and is there anything we can do
about it?

Thank you


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
