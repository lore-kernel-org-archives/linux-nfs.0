From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd random drop
Date: Mon, 5 Apr 2004 10:13:05 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16496.42129.32286.429339@notabene.cse.unsw.edu.au>
References: <20040401102334.GC20772@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAHjr-0001Xm-IP
	for nfs@lists.sourceforge.net; Sun, 04 Apr 2004 17:13:19 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BAHjr-0005G8-2m
	for nfs@lists.sourceforge.net; Sun, 04 Apr 2004 17:13:19 -0700
Received: From
	notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU) (auth-user neilb)
	(for <okir@suse.de>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Mon, 5 Apr 2004 10:13:11 +1000
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Thursday April 1
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

On Thursday April 1, okir@suse.de wrote:
> Hi,
> 
> I hate to bore you all with the same old stuff, but I'm still fighting
> problems caused by nfsd's dropping active connections.
> 
..snip..
> 
> I propose to add the following two patches to the server and client. They
> increase the connection limit, stop dropping the neweset socket, and
> add some printk's to alert the admin of the contention.

I'm happy for the server patch to go in.
Andrew Morton already picked it up and asked if it was OK.  I have
confirmed that it is so you might see it in 2.6.6.

> 
> As an alternative to hardcoding a formula based on the number of threads,
> I could also make the max number of connections a sysctl.

Might be good, but I would only bother if a real need presents itself.

Thanks,

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
