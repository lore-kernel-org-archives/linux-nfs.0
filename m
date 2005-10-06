From: "Vithal Shirodkar" <vithals@hotmail.com>
Subject: Re: nfsd dies quietly in anaconda loader
Date: Thu, 06 Oct 2005 11:39:01 -0700
Message-ID: <BAY101-F38BB20A9CD39137D725E79B2850@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENae6-0000uB-SL
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 11:39:10 -0700
Received: from bay101-f38.bay101.hotmail.com ([64.4.56.48] helo=hotmail.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ENae2-00058A-Kh
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 11:39:10 -0700
To: neilb@suse.de
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

I did a strace on rpc.mountd and found that it was looking for a loopback 
interface to contact the rpc server.  I did not have a loopback interface. 
Once i added that, the daemons came up fine.  However, now I cannot mount 
from a client.  I get a "permission denied error" from server.

I have portmap, nfsd, lockd, rpciod and rpc.mountd running.  /etc/exports 
has the entry
/sbin *(ro,no_root_squash)
I did a "exportfs -ra" after making the entry... also tried restarting the 
daemons.  But still the permission denied error.  Am I missing anything ?

There is only a layer2 switch sitting in between the server and client.. so 
firewalls shouldn't be an issue.

Thanks
Vithal




From:  Neil Brown <neilb@suse.de>
To:  "Vithal Shirodkar" <vithals@hotmail.com>
CC:  nfs@lists.sourceforge.net
Subject:  Re: [NFS] nfsd dies quietly in anaconda loader
Date:  Thu, 6 Oct 2005 16:19:20 +1000
>On Tuesday October 4, vithals@hotmail.com wrote:
> > I modified anaconda loader to complete startup till network is up and 
>call
> > my script where I try to load nfs server.  I did insmod for nfsd, nfs,
> > lockd, sunrpc and see that these modules are up.  However, when I do a
> > /etc/rc.d/init.d/nfs start I get a OK message but ps -e reports that nfs 
>is
> > not running.
>
>My best guess is that /etc/exports doesn't actually mention anything
>to export.  In that case, the 'nfs' script doesn't bother starting
>nfsd.
>
>Is that possible.?
>
>NeilBrown
>
> >
> > My goal is to have a basic kernel running which will have nfs server up
> > without going through init.
> >
> > vithals
> >
> >
> >
> >
> > -------------------------------------------------------
> > This SF.Net email is sponsored by:
> > Power Architecture Resource Center: Free content, downloads, 
>discussions,
> > and more. http://solutions.newsforge.com/ibmarch.tmpl
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by:
>Power Architecture Resource Center: Free content, downloads, discussions,
>and more. http://solutions.newsforge.com/ibmarch.tmpl
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
