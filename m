From: Suresh Jayaram <sureshjayaram@gmail.com>
Subject: Re: Kerberized NFSv3 Client for Linux
Date: Thu, 17 Feb 2005 18:54:26 +0530
Message-ID: <38c3c4860502170524484f5aa@mail.gmail.com>
References: <38c3c48605021405536f044f64@mail.gmail.com>
	 <20050214150945.BAE461BAF7@citi.umich.edu>
	 <38c3c4860502142059261a119a@mail.gmail.com>
	 <20050215134718.59E051BB0B@citi.umich.edu>
	 <38c3c48605021606265170db94@mail.gmail.com>
	 <20050216144927.138341BB88@citi.umich.edu>
Reply-To: Suresh Jayaram <sureshjayaram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1leU-0005ou-4p
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 05:25:06 -0800
Received: from wproxy.gmail.com ([64.233.184.192])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1leT-0005Nx-7x
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 05:25:06 -0800
Received: by wproxy.gmail.com with SMTP id 69so243113wra
        for <nfs@lists.sourceforge.net>; Thu, 17 Feb 2005 05:24:59 -0800 (PST)
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <20050216144927.138341BB88@citi.umich.edu>
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

Kevin,

Thanks again for inputs..

> > Also I created /var/lib/nfs/rpc_pipefs. I am running "rpc.gssd -m" and
> > "rpc.idmapd" Now iam able to mount
> > mount -osec=krb5 nfsserver:/exportedpath /mntpoint
> > But When I do an "ls /mntpoint" it hangs
 
> Is this still as root, or as a normal user?  If as a normal user,
> had you already done a kinit to get a Kerberos TGT?

All operations iam doing as root user only
 
> This means that rpc.gssd probably stopped, or is hung up and no
> longer answering upcalls.  Running rpc.gssd with option "-vvv"
> may give more clues.

I did two more things.. 
1. Added rpc_pipefs	/var/lib/nfs/rpc_pipefs	rpc_pipefs	defaults	0	0 to
/etc/fstab of CLIENT ( Not sure whether it is actually required in
client or not. But documentation says  client will use rpc_pipesfs for
kernel/userspace communication and server will use proc fs)
2. ran rpc.gssd with -f option and -p /var/lib/nfs/rpc_pipefs
(Though not sure what -f means)
which reported "Could not find libgssapi_krb5.so", then modified the
path in gssapi_mech.conf

Now Iam able to mount, but ls doesn't hang it says "Permission denied"
/var/log/messages shows (rpc.gssd -vvv)

Feb 17 18:34:11 nfsclient rpc.gssd[4296]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_REALM' are good until 1108731834
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: using
FILE:/tmp/krb5cc_machine_REALM as credentials cache for machine creds
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: using gss_krb5_ccache_name
to select krb5 ccache FILE:/tmp/krb5cc_machine_REALM
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: creating context using euid
0 (save_uid 0)
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: creating tcp client for
server nfsserver.domain
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: creating context with server
nfs@nfsserver.domain
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: WARNING: Failed to create
krb5 context for user with uid 0 for server nfsserver.domain
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: WARNING: Failed to create
krb5 context for user with uid 0 with credentials cache
FILE:/tmp/krb5cc_machine_REALM for server nfsserver.domain
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: WARNING: Failed to create
krb5 context for user with uid 0 with any credentials cache for server
nfsserver.domain
Feb 17 18:34:11 nfsclient rpc.gssd[4296]: doing error downcall

Any interoperability issues with Solaris NFS server(kerberized)?
Iam running gssd on NFSserver also ..

Any pointers ?

Thanks,
Suresh

> > > > > > Iam trying to setup kerberized NFS(v3) client for Linux.
> > > > > >
> > > > > > My setup details
> > > > > > NFS client: Suse Linux Enterprise Server (SLES 9) which has
> > > > > > kernel - 2.6.5-7.97 (CONFIG_SUNRPC=y, CONFIG_SUNRPC_GSS=y,
> > > > > > CONFIG_RPCSEC_GSS_KRB5=y )
> > > > > >
> > > > > > nfs-utils-1.0.7 (patched - nfs-utils-1.0.7-CITI_NFS4_ALL-1.dif)
> > > > > > util-linux-2.12 (patched - util-linux-2.12-CITI_NFS4_ALL-3.dif)
> > > > > >
> > > > > > KDC Server: RedHat Linux
> > > > > > NFS Server: Kerberized Solaris server (KDC Server & NFS Server are
> > > > > > Tested and working fine)
> > > > > >
> > > > > > To setup kerberized Linux Client, I presume a kernel with rpcsecgss
> > > > > > support, patched nfs-utils pkg and patched util-linux pkg is
> > > > > > sufficient. (Let me know any other pkg/configuration is required)
> > > > > >
> > > > > > My NFS Server export entry is:
> > > > > > share -F nfs -o sec=krb5 /export/home
> > > > > >
> > > > > > Server has nfs principal registered to KDC and the user principal of
> > > > > > client also registered to the Server.
> > > > > > After doing a kinit if I try to mount the exported path, Iam getting
> > > > > >
> > > > > > "mount: nfsserver:/export/home failed, reason given by server:
> > > > > > Permission denied"
> > > > > > Then I specified the client name in the exports file make gave
> > > > > > readonly perms. Then also I got the same error.
> > > > > >
> > > > > > Am I missing something ? Any pointers ..
> > > > > >
> > > > > > thanks,
> > > > > > Suresh
> > > > > >
> > > > > >
> > > > > > -------------------------------------------------------
> > > > > > SF email is sponsored by - The IT Product Guide
> > > > > > Read honest & candid reviews on hundreds of IT Products from real use
> > rs.
> > > > > > Discover which products truly live up to the hype. Start reading now.
> > > > > > http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > > > > > _______________________________________________
> > > > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > > >
> > > > >
> > > >
> > > >
> > > > --
> > > > "Good Luck is when preparation meets opportunity"
> > > >
> > > >
> > > > -------------------------------------------------------
> > > > SF email is sponsored by - The IT Product Guide
> > > > Read honest & candid reviews on hundreds of IT Products from real users.
> > > > Discover which products truly live up to the hype. Start reading now.
> > > > http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > > > _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > >
> > >
> >
> >
> > --
> > "Good Luck is when preparation meets opportunity"
> 
> 


-- 
"Good Luck is when preparation meets opportunity"


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
