From: Neil Brown <neilb@suse.de>
Subject: Re: nfsd dies quietly in anaconda loader
Date: Fri, 7 Oct 2005 08:57:35 +1000
Message-ID: <17221.43999.796998.941914@cse.unsw.edu.au>
References: <BAY101-F38BB20A9CD39137D725E79B2850@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENegM-0000i7-5F
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 15:57:46 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ENegK-0002Xt-QD
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 15:57:46 -0700
To: "Vithal Shirodkar" <vithals@hotmail.com>
In-Reply-To: message from Vithal Shirodkar on Thursday October 6
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

On Thursday October 6, vithals@hotmail.com wrote:
> I did a strace on rpc.mountd and found that it was looking for a loopback 
> interface to contact the rpc server.  I did not have a loopback interface. 
> Once i added that, the daemons came up fine.  However, now I cannot mount 
> from a client.  I get a "permission denied error" from server.
> 
> I have portmap, nfsd, lockd, rpciod and rpc.mountd running.  /etc/exports 
> has the entry
> /sbin *(ro,no_root_squash)
> I did a "exportfs -ra" after making the entry... also tried restarting the 
> daemons.  But still the permission denied error.  Am I missing
> anything ?

Nothing obvious.
I assume /var/lib/nfs exists and has sensible etab/xtab files in it?
I note you aren't running 'statd', but that shouldn't give you a
permission-denied error.  It would only mean that locking might not
work.
Is there anything in the logs on the server, either kern.log or
daemon.log (or anywhere else)?

NeilBrown

> 
> There is only a layer2 switch sitting in between the server and client.. so 
> firewalls shouldn't be an issue.
> 
> Thanks
> Vithal
> 
> 


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
