From: Neil Brown <neilb@suse.de>
Subject: Re: nfsd dies quietly in anaconda loader
Date: Fri, 14 Oct 2005 17:45:32 +1000
Message-ID: <17231.25116.764430.223050@cse.unsw.edu.au>
References: <17221.43999.796998.941914@cse.unsw.edu.au>
	<BAY101-F3A29A71D505BC1D551AD5B2840@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQKGA-00004t-Kk
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 00:45:46 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQKG9-0007M0-Da
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 00:45:46 -0700
To: "Vithal Shirodkar" <vithals@hotmail.com>
In-Reply-To: message from Vithal Shirodkar on Friday October 7
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

On Friday October 7, vithals@hotmail.com wrote:
> Strace came in handy again.  I found that mountd was trying to open a 
> filehandle on /proc/fs/nfsd which failed.  So I did the following mounts and 
> things worked magically.
> mount nfsd /proc/fs/nfsd -t nfsd

nfsd is supposed to work without this mounted, but I believe there are
some broken version of nfs-utils floating around that don't....

It certainly doesn't hurt to mount it, and it is probably a good idea.
I'm glad this all got sorted out.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
