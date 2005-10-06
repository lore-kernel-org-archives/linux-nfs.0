From: Neil Brown <neilb@suse.de>
Subject: Re: nfsd dies quietly in anaconda loader
Date: Thu, 6 Oct 2005 16:19:20 +1000
Message-ID: <17220.49640.430710.782074@cse.unsw.edu.au>
References: <BAY101-F1370AF195FDE8C4E12D44BB2820@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENP6G-00065q-IX
	for nfs@lists.sourceforge.net; Wed, 05 Oct 2005 23:19:28 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ENP6F-00046J-UW
	for nfs@lists.sourceforge.net; Wed, 05 Oct 2005 23:19:28 -0700
To: "Vithal Shirodkar" <vithals@hotmail.com>
In-Reply-To: message from Vithal Shirodkar on Tuesday October 4
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

On Tuesday October 4, vithals@hotmail.com wrote:
> I modified anaconda loader to complete startup till network is up and call 
> my script where I try to load nfs server.  I did insmod for nfsd, nfs, 
> lockd, sunrpc and see that these modules are up.  However, when I do a 
> /etc/rc.d/init.d/nfs start I get a OK message but ps -e reports that nfs is 
> not running.

My best guess is that /etc/exports doesn't actually mention anything
to export.  In that case, the 'nfs' script doesn't bother starting
nfsd.

Is that possible.?

NeilBrown

> 
> My goal is to have a basic kernel running which will have nfs server up 
> without going through init.
> 
> vithals
> 
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by:
> Power Architecture Resource Center: Free content, downloads, discussions,
> and more. http://solutions.newsforge.com/ibmarch.tmpl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
