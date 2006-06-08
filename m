From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: query about kernel 2.4.21-37.ELsmp
Date: Thu, 08 Jun 2006 02:39:27 -0400
Message-ID: <1149748767.3379.66.camel@localhost.localdomain>
References: <20060608042448.97900.qmail@web51615.mail.yahoo.com>
	<1149748501.3379.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoFJe-0007oP-GV
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 00:54:16 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1FoE1k-0007fj-RH
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 23:30:57 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FoE0o-0006hG-Vl
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 23:29:00 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <1149748501.3379.63.camel@localhost.localdomain>
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

On Thu, 2006-06-08 at 02:35 -0400, Wendy Cheng wrote:


> 2.2.a Manually unexport filesystem. This is a tricky one. Note that if
> kernel still hold the vfsmount reference for the export entry, umount
> will fail. The "exportfs -u hostname:/export_path" doesn't necessarily
> go into the kernel to delete the export entry (to drop vfsmount
> reference count). You have to use either "exportfs -ua" or "exportfs
> *:/export_path" to explicitly remove the export entry from RHEL 3
> kernel. 

I'm famous for my typo :) ... should use "exportfs -u *:/export_path".

> 2.2.b Is NFS client holding a posix lock via NLM without releasing it ?
> If yes, a quick and dirty way is to send lockd a signal ("kill -9
> lockd"). This will signal lockd to drop the NLM locks (and subsequently
> close the file).

-- Wendy



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
