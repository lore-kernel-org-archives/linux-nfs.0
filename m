From: Suresh Jayaram <sureshjayaram@gmail.com>
Subject: Re: Kerberized NFSv3 Client for Linux
Date: Wed, 16 Feb 2005 19:56:00 +0530
Message-ID: <38c3c48605021606265170db94@mail.gmail.com>
References: <38c3c48605021405536f044f64@mail.gmail.com>
	 <20050214150945.BAE461BAF7@citi.umich.edu>
	 <38c3c4860502142059261a119a@mail.gmail.com>
	 <20050215134718.59E051BB0B@citi.umich.edu>
Reply-To: Suresh Jayaram <sureshjayaram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1Q81-00015T-W8
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 06:26:10 -0800
Received: from wproxy.gmail.com ([64.233.184.192])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1Q80-0002yP-Fn
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 06:26:09 -0800
Received: by wproxy.gmail.com with SMTP id 69so83403wra
        for <nfs@lists.sourceforge.net>; Wed, 16 Feb 2005 06:26:01 -0800 (PST)
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <20050215134718.59E051BB0B@citi.umich.edu>
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

Thanks for the response.
On Tue, 15 Feb 2005 08:47:18 -0500, Kevin Coffman <kwc@citi.umich.edu> wrote:

> Mount must be done by root.  When a request comes up to rpc.gssd with
> uid 0 to negotiate a gss context, it uses a "machine credential"
> (nfs/<hostname>@REALM) as the client principal.

I created service(nfs) principal for both client and server
nfs/nfsclient.domain@REALM (extracted in client)
nfs/nfsserver.domain@REALM (extracted in server)
Is this correct?

> Are you not doing the mount as root?
Iam Mounting as root only.

Also I created /var/lib/nfs/rpc_pipefs. I am running "rpc.gssd -m" and
"rpc.idmapd"
Now iam able to mount
mount -osec=krb5 nfsserver:/exportedpath /mntpoint
But When I do an "ls /mntpoint" it hangs

Also Iam getting the following in messages frequently
Feb 16 19:49:27 nfstest kernel: RPC: AUTH_GSS upcall timed out.
Feb 16 19:49:27 nfstest kernel: Please check user daemon is running!

Any pointers ?

Thanks,
Suresh
> > > > Iam trying to setup kerberized NFS(v3) client for Linux.
> > > >
> > > > My setup details
> > > > NFS client: Suse Linux Enterprise Server (SLES 9) which has
> > > > kernel - 2.6.5-7.97 (CONFIG_SUNRPC=y, CONFIG_SUNRPC_GSS=y,
> > > > CONFIG_RPCSEC_GSS_KRB5=y )
> > > >
> > > > nfs-utils-1.0.7 (patched - nfs-utils-1.0.7-CITI_NFS4_ALL-1.dif)
> > > > util-linux-2.12 (patched - util-linux-2.12-CITI_NFS4_ALL-3.dif)
> > > >
> > > > KDC Server: RedHat Linux
> > > > NFS Server: Kerberized Solaris server (KDC Server & NFS Server are
> > > > Tested and working fine)
> > > >
> > > > To setup kerberized Linux Client, I presume a kernel with rpcsecgss
> > > > support, patched nfs-utils pkg and patched util-linux pkg is
> > > > sufficient. (Let me know any other pkg/configuration is required)
> > > >
> > > > My NFS Server export entry is:
> > > > share -F nfs -o sec=krb5 /export/home
> > > >
> > > > Server has nfs principal registered to KDC and the user principal of
> > > > client also registered to the Server.
> > > > After doing a kinit if I try to mount the exported path, Iam getting
> > > >
> > > > "mount: nfsserver:/export/home failed, reason given by server:
> > > > Permission denied"
> > > > Then I specified the client name in the exports file make gave
> > > > readonly perms. Then also I got the same error.
> > > >
> > > > Am I missing something ? Any pointers ..
> > > >
> > > > thanks,
> > > > Suresh
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
> >
> >
> > -------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT Products from real users.
> > Discover which products truly live up to the hype. Start reading now.
> > http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
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
