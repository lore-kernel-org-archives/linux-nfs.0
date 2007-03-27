From: Roger Heflin <rheflin@atipa.com>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 10:31:42 -0500
Message-ID: <460938DE.302@atipa.com>
References: <46082D10.1060301@cse.yorku.ca>	<46083474.8090906@redhat.com>	<46091325.6050403@cse.yorku.ca>	<46091498.6030706@moving-picture.com>	<46091C41.6070908@cse.yorku.ca>
	<46092FC2.2080901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: James Pearson <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWDeF-0007VC-JE
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:31:48 -0700
Received: from 125.14.124.24.cm.sunflower.com ([24.124.14.125]
	helo=mail.atipa.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HWDeE-0006pm-7V
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:31:47 -0700
In-Reply-To: <46092FC2.2080901@redhat.com>
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

Wendy Cheng wrote:

> 1. If server for whatever reason gets rebooted and somehow the device 
> major-minor number gets altered, the client that keeps the "old" file 
> handle will get a "stale file handle" error. Some of the NFS clients 
> will re-do lookup to obtain the correct FileHandle(s). Some of them will 
> simply fail. There is really not much you can do as a system administrator.

I think this can also happen if you are using the major+minor numbers with
say lvm, and change the order of the underlying LVM's, this might even
be a risk with the fsid option if the underlying filesystem that it was
supposed to be exporting fails to get mounted before the export.

Server reboots, a different device is put at the same major and minor 
numbers
than was there before,now  the server now gets hammered with inode numbers
that don't exist  (valid range for filesystem, but don't exist on the "new"
filesystem that is at the same major and minor numbers as the old one was).

I have seen this actually completely use up all of the CPU on a NFS server,
eventually causing it to be completely unusable, and of course the issue 
survives
reboots of the server as the requests are coming from the clients, and the
clients don't appear to ever give up, and if you have enough clients you
can make the server unusable fairly quickly.   I have seen the machine
actually hang bringing up NFS from this.

                                           Roger

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
