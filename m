From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: query about kernel 2.4.21-37.ELsmp
Date: Thu, 08 Jun 2006 02:35:01 -0400
Message-ID: <1149748501.3379.63.camel@localhost.localdomain>
References: <20060608042448.97900.qmail@web51615.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoDwd-0001fn-8F
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 23:24:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FoDwd-00054R-3X
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 23:24:39 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060608042448.97900.qmail@web51615.mail.yahoo.com>
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

On Wed, 2006-06-07 at 21:24 -0700, mehta kiran wrote:
> Hi,
>     From where can i get information about all the
> bugs
>     which were there in redhat kernel 2.4.21-37.ELsmp
> ?
>     I want to know if there existed a bug which
>     did not allow unmounting of device which was once
>     nfs exported and accessed by clients
> 

I'm personally not aware of any RHEL 3 bugzilla that turns out to be a
real bug to prevent NFS exported filesytem getting un-mounted. However,
I'm not frequently involved with RHEL NFS bugs either so I could be
wrong. 

On the other hand, things to check before you convince yourself there is
a bug somewhere: 

1. All the local file accesses (on the server) have been stopped
(processes killed) ?
2.1 If possible, "service nfs stop" invoked ? This will clean up all the
states associated with NFS accesses; Or
2.2.a Manually unexport filesystem. This is a tricky one. Note that if
kernel still hold the vfsmount reference for the export entry, umount
will fail. The "exportfs -u hostname:/export_path" doesn't necessarily
go into the kernel to delete the export entry (to drop vfsmount
reference count). You have to use either "exportfs -ua" or "exportfs
*:/export_path" to explicitly remove the export entry from RHEL 3
kernel. 
2.2.b Is NFS client holding a posix lock via NLM without releasing it ?
If yes, a quick and dirty way is to send lockd a signal ("kill -9
lockd"). This will signal lockd to drop the NLM locks (and subsequently
close the file).

-- Wendy






_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
