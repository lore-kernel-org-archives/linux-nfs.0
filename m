From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs client monitoring?
Date: Fri, 30 Jul 2004 07:22:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <410A2F8A.4030307@RedHat.com>
References: <41092832.3030400@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BqVTY-0006L3-4O
	for nfs@lists.sourceforge.net; Fri, 30 Jul 2004 04:23:00 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BqVTX-0006NT-NI
	for nfs@lists.sourceforge.net; Fri, 30 Jul 2004 04:23:00 -0700
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <41092832.3030400@psu.edu>
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

Jason Holmes wrote:

> Is there a command that can show the demands being placed on the nfs 
> server by each individual client?  I run into the situation from time 
> to time where a random user will do something that puts an extreme 
> load on the fileserver and having such a command would help greatly in 
> trying to figure out the source of the load.

I've recently added some hooks to xosview that will graphically
show NFS and kNFSD traffic which I find pretty handy....

http://download.fedora.redhat.com/pub/fedora/linux/core/2/i386/os/Fedora/RPMS/xosview-1.8.0-19.i386.rpm

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
