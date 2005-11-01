From: Neil Brown <neilb@suse.de>
Subject: Re: Stale NFS mounts
Date: Tue, 1 Nov 2005 21:11:47 +1100
Message-ID: <17255.16227.712240.839790@cse.unsw.edu.au>
References: <9E621559095AA746B22B21CD4FAF99A54E3126@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWt7c-0004lU-Nx
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 02:12:04 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EWt7c-00089p-77
	for nfs@lists.sourceforge.net; Tue, 01 Nov 2005 02:12:04 -0800
To: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
In-Reply-To: message from Edward Hibbert on Tuesday November 1
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

On Tuesday November 1, Edward.Hibbert@dataconnection.com wrote:
> 
> So:
> *	Are nested mounts safe to use?

Should be.

> *	Are there any common causes of stale mounts which I might not be
> aware of?

Not sure...

> *	Any suggestions for how to investigate this further?

See below.

> 
> The NFS server is a Fedora system with kernel 2.6.9-1.667smp.  The NFS
> clients are RedHat AS 4.0 2.6.9-11.ELsmp.  Do ask for more details if
> needed.

On the server:
  cat /etc/exports
  cat /proc/fs/nfsd/exports
  grep . /proc/net/rpc/*/content

Do this while it is working, and then again when it isn't working.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
