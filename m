From: Neil Brown <neilb@suse.de>
Subject: Re: File lock with multiple clients
Date: Fri, 21 Oct 2005 21:47:51 +1000
Message-ID: <17240.54631.430555.919388@cse.unsw.edu.au>
References: <20051021102518.7F60EEE8E@mx1.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESvNc-0001xX-Fz
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 04:48:12 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESvNZ-0001Z6-Dr
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 04:48:11 -0700
To: petter.knutsen@cgi.no
In-Reply-To: message from petter.knutsen@cgi.no on Friday October 21
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

On Friday October 21, petter.knutsen@cgi.no wrote:
> 
> I would appreciate if someone could tell me if this is possible or not, so I
> can either abandon NFS and look for alternatives or, if it should work, go
> back and look for flaws in my setup. :-)

fcntl locking definitely works between separate NFS clients.
There are some common config errors that can cause problems though,
including not having 'statd' running and firewalling the 'lockd' or
'statd' ports (which 'rpcinfo -p' reports are 'nlockmgr' and
'status').

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
