From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/10] lockd: add new export operation for
 nfsv4/lockd locking
Date: Sat, 09 Dec 2006 00:53:22 -0500
Message-ID: <457A4F52.1020709@redhat.com>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<1165383260627-git-send-email-bfields@fieldses.org>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	me <bfields@umich.edu>, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gsv22-00032E-71
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 21:45:54 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gsv22-0002Nx-EJ
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 21:45:55 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <1165383260627-git-send-email-bfields@fieldses.org>
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

J. Bruce Fields wrote:

>From: Marc Eshel <eshel@almaden.ibm.com>
>
>There is currently a filesystem ->lock() method, but it is defined only by
>a few filesystems that are not exported via nfsd.  So none of the lock
>routines that are used by lockd or nfsv4 bother to call those methods.
>
>Filesystems such as cluster filesystems would like to do their own locking
>and also would like to be exportable via NFS.
>
>So we add a new lock() export operation, and new routines vfs_lock_file,
>vfs_test_lock, and vfs_cancel_lock, which call the new export operation,
>falling back on the appropriate local operation if the export operation is
>unavailable.
>
>These new functions are intended to be used by lockd and nfsd; lockd and
>nfsd changes to take advantage of them are made by later patches.
>
>  
>
Starting to read these patches .. I see these new APIs are placed in 
lockd directory. Was there any discussion before to make these generic 
vfs layer functions ? I'm just curious.

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
