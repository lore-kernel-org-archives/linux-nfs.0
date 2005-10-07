From: "Vithal Shirodkar" <vithals@hotmail.com>
Subject: Re: nfsd dies quietly in anaconda loader
Date: Fri, 07 Oct 2005 07:40:12 -0700
Message-ID: <BAY101-F3A29A71D505BC1D551AD5B2840@phx.gbl>
References: <17221.43999.796998.941914@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENtOd-00049S-NT
	for nfs@lists.sourceforge.net; Fri, 07 Oct 2005 07:40:27 -0700
Received: from bay101-f3.bay101.hotmail.com ([64.4.56.13] helo=hotmail.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ENtOY-0006vg-5t
	for nfs@lists.sourceforge.net; Fri, 07 Oct 2005 07:40:24 -0700
In-Reply-To: <17221.43999.796998.941914@cse.unsw.edu.au>
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

Strace came in handy again.  I found that mountd was trying to open a 
filehandle on /proc/fs/nfsd which failed.  So I did the following mounts and 
things worked magically.
mount nfsd /proc/fs/nfsd -t nfsd
and just to be safe
mount sunrpc /var/lib/nfs/rpc_pipefs -t rpc_pipefs
Apparently you need these 2 entires in /etc/fstab for things to work.

Thanks for the help

Vithal

>From: Neil Brown <neilb@suse.de>
>To: "Vithal Shirodkar" <vithals@hotmail.com>
>CC: nfs@lists.sourceforge.net
>Subject: Re: [NFS] nfsd dies quietly in anaconda loader
>Date: Fri, 7 Oct 2005 08:57:35 +1000
>
>On Thursday October 6, vithals@hotmail.com wrote:
> > I did a strace on rpc.mountd and found that it was looking for a 
>loopback
> > interface to contact the rpc server.  I did not have a loopback 
>interface.
> > Once i added that, the daemons came up fine.  However, now I cannot 
>mount
> > from a client.  I get a "permission denied error" from server.
> >
> > I have portmap, nfsd, lockd, rpciod and rpc.mountd running.  
>/etc/exports
> > has the entry
> > /sbin *(ro,no_root_squash)
> > I did a "exportfs -ra" after making the entry... also tried restarting 
>the
> > daemons.  But still the permission denied error.  Am I missing
> > anything ?
>
>Nothing obvious.
>I assume /var/lib/nfs exists and has sensible etab/xtab files in it?
>I note you aren't running 'statd', but that shouldn't give you a
>permission-denied error.  It would only mean that locking might not
>work.
>Is there anything in the logs on the server, either kern.log or
>daemon.log (or anywhere else)?
>
>NeilBrown
>
> >
> > There is only a layer2 switch sitting in between the server and client.. 
>so
> > firewalls shouldn't be an issue.
> >
> > Thanks
> > Vithal
> >
> >
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
