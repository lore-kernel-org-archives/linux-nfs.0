From: Bill Shupp <hostmaster@shupp.org>
Subject: Debian Diskless client mounts FS as Read Only
Date: Wed, 02 Feb 2005 14:28:34 -0800
Message-ID: <42015412.7080406@shupp.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwSzG-0005K6-So
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 14:28:38 -0800
Received: from ns1.merchbox.com ([216.234.249.114] helo=merchbox.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CwSzF-0007Zx-EX
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 14:28:38 -0800
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

I am trying to setup a Debian Woody diskless client.  I followed 
instructions located here to make it work with my PXE enabled 3com NIC:

http://zeewier.blub.net/~jdv/pxe-debian.html

Everything is working fine, except the root file system is still being 
mounted as read only, and I don't know why.  Here's my entry in 
/etc/exports:

/nfsroot/webcam 192.168.1.31(no_root_squash,rw,sync)

Here's what's in /proc/fs/nfs/exports:

/nfsroot/webcam 192.168.1.31(rw,no_root_squash,sync,wdelay) # 192.168.1.31


The server is also Debian Woody, both using the 2.4.18 kernel (the 
client's kernel was compiled manually to avoid modules).

Here's what apt-get show nfs-common shows for the version:

Source: nfs-utils
Version: 1:1.0-2woody3

Lastly, here are the kernel boot parameters I'm using:

ip=dhcp nfsroot=192.168.1.1:/nfsroot/webcam root=/dev/nfs init=/sbin/init

Any advice is greatly appreciated!


Regards,

Bill Shupp


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
