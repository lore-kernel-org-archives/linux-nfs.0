From: James Pearson <james-p@moving-picture.com>
Subject: Re: ANNOUNCE: nfs-utils 1.0.4
Date: Wed, 30 Jul 2003 17:43:45 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F27F5C1.8C0C3E79@moving-picture.com>
References: <1030714170001.24267@cse.unsw.edu.au>
			<3F2681A6.7E33A7E6@moving-picture.com> <16167.18330.605320.168421@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19hu3z-00042C-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Jul 2003 09:44:31 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Neil Brown wrote:
> 
> On Tuesday July 29, james-p@moving-picture.com wrote:
> > >  If you are using 2.6.0-testX and exporting files with NFS *please*
> > >  test this out and let me know of any problems.
> >
> > I've just been trying out 2.6.0-test2 with nfs-utils 1.0.5 and I've come
> > across a couple of problems:
> 
> Thanks for reporting them.
> 
> >
> > When using 'mount -t nfsd nfsd /proc/fs/nfs' on the server, if I now run
> > 'showmount -d server', nothing is returned. If I don't use the 'mount -t
> > nfsd ...', showmount works as expected.
> >
> 
> Hmm.. "showmount -d" effectively just shows the contents of rmtab.  I
> thought I was still keeping rmtab mostly up-to-date, but apparently
> not.  I will look into it and see if I can find a sensible way for it
> to work.

What is the 'best' way to enable /proc/fs/nfs? i.e. if nfsd is a module,
then you can't mount /proc/fs/nfs until the module is loaded, which
normally doesn't happen until rpc.nfsd is started - which is after
exportfs has been run in the startup script ...

Should /proc/fs/nfs be unmounted when the /etc/init.d/nfs is stopped?

Could there be problems if nfsd uses /proc/fs/nfs, then nfsd is shutdown
and restarted without /proc/fs/nfs being mounted?

> >
> > When starting /etc/init.d/nfs, I get a pause between 'Starting NFS
> > daemon' and 'Starting NFS mountd' - this turns out to be rpcinfo timing
> > out i.e.
> >
> > rpcinfo: RPC: Timed out
> > program 100003 version 3 is not available
> >
> > i.e. from '/usr/sbin/rpcinfo -u localhost nfs 3'
> >
> > and hence rpc.mountd starts with '--no-nfs-version 3'
> >
> > Once nfsd is up and running, rpcinfo returns the expected result.
> >
> > Forcing 'MOUNTD_NFS_V3=yes' works fine, and clients can mount using
> > NFSv3
> 
> Yep.  This requres a change to /etc/init.d/nfs which I have done for
> debian but not for others.  I'll look into that.
> ...

It appears this has already been done for NFSv2 in /etc/init.d/nfs, but
not for NFSv3 - adding the similar bits for NFSv3 now works OK.

> >
> > One thing I would be interested in knowing - how does the server now
> > 'know' about clients that have mounted file systems across server
> > reboots now that /var/lib/nfs/rmtab is no longer used?
> 
> It doesn't.  But the client does.
> 
> When the client sends the first request after a server has rebooted,
> the kernel fails to find any information about the client in it's
> export cache so it sends a request to mountd, via
>    /proc/net/rpc/*/channel
> mountd determines whether the client is allowed access and sends an
> approprate answer back.
> 
> This is explained to some extent in
>    man 7 nfsd
> 
> though that is really just a first draft.


Thanks

James Pearson


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
