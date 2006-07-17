From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: Mon, 17 Jul 2006 14:49:18 -0400
Message-ID: <1153162159.13961.3.camel@localhost>
References: <m1hd1gksev.fsf@minerva.ceride.gov.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2Y9w-0003Ju-AM
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 11:49:37 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G2Y9w-0003tu-75
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 11:49:36 -0700
To: Mario Storti <mstorti@intec.unl.edu.ar>
In-Reply-To: <m1hd1gksev.fsf@minerva.ceride.gov.ar>
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

On Mon, 2006-07-17 at 15:17 -0300, Mario Storti wrote:
> Hi all, 
> 
> We have still problems with NFS in our Beowulf cluster. The original
> post is here
> 
> http://thread.gmane.org/gmane.linux.nfs/9564/focus=9566
> 
> The news are that we reproduced the problem on Scientific Linux 4.2
> and also without VNFS. In addition we have taken a tethereal capture
> that may help in understanding the problem. 
> 
> In brief we have a Beowulf class cluster built on Scientific Linux
> (Beryllium) 4.2, (kernel 2.6.9-22.0.1). The cluster is disk-less
> (nodes don't have hard disks) based on the Warewulf package. NFS
> traffic is reduced by using VNFS filesystems at the nodes. However we
> reproduced the problem in a configuration with disks at the nodes. 
> 
> The problem is that for some files in user accounts if we make some
> modifications to the file in the server, this changes are not seen in
> the compute nodes. The NFS server is NFS3 and with the standard
> configuration (8 instances of the server and default parameters). The
> cluster has 20 nodes at this time, but we have made experiments with a
> `cloned' cluster and even with only two nodes the problem persist.
> 
> The experiment is as follows: We change a text file in a user account
> with Emacs and checking whether the change is seen in the compute
> nodes. Sometimes the change is immediately seen in the compute nodes,
> but many times some nodes don't see the change. 
> 

This is a FAQ that has been well-publicised and discussed to death on
this list:
  http://nfs.sourceforge.net/#faq_a8

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
