From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: Kerberized NFSv3 Client for Linux
Date: Tue, 15 Feb 2005 08:47:18 -0500
Message-ID: <20050215134718.59E051BB0B@citi.umich.edu>
References: <38c3c48605021405536f044f64@mail.gmail.com>
 <20050214150945.BAE461BAF7@citi.umich.edu> <38c3c4860502142059261a119a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D132w-0005Ay-1Y
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 05:47:22 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D132u-00034m-EU
	for nfs@lists.sourceforge.net; Tue, 15 Feb 2005 05:47:21 -0800
To: Suresh Jayaram <sureshjayaram@gmail.com>
In-reply-to: <38c3c4860502142059261a119a@mail.gmail.com> 
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

> Kevin,
> 
> Thanks for your inputs.
> 
> On Mon, 14 Feb 2005 10:09:45 -0500, Kevin Coffman <kwc@citi.umich.edu> wrote:
> > I don't think you mentioned Suse in your message to the Kerberos list.
> > Does this mean you have Heimdal (as opposed to MIT) Kerberos libraries
> > on your client?  (We have problems with the released Heimdal code.)
> Yeah I didn't mention that my NFS client is SLES, but I have installed
> MIT kerberos on SLES and Iam using that only.

OK, good.

> > I assume you are running rpc.gssd on the client.  Can you run that with
> > "-vvv" and send the output when you attempt to do the mount?
> When I started rpc.gssd on client (-vvv option) I got the following
> info on /var/log/messages
> 
> [ snip ]
> Feb 15 10:07:01 nfsclient rpc.gssd[13870]: Using (machine) credentials
> cache: 'FILE:/tmp/krb5cc_machine_REALM'
> Feb 15 10:07:01 nfsclient rpc.gssd[13870]: processing client list
> 
> But when I try to mount, Iam not getting any log messages. I
> understand that I have to extract nfs service principal on client also
> (though not sure why..)

Mount must be done by root.  When a request comes up to rpc.gssd with
uid 0 to negotiate a gss context, it uses a "machine credential" 
(nfs/<hostname>@REALM) as the client principal.

> Also rpcsec_gss_krb5 support is compiled in to my kernel (not as a
> module) CONFIG_RPCSEC_GSS_KRB5=y). Is this OK ? or need to be compiled
> only as a module. My System.map also have rpcsec_gss symbols..

This is fine.

> >From the snoop traces Iam able to see MOUNT reply itself is failing
> (Status = ERR_ACCESS). It is not returning the AUTH flavors supported.

Are you not doing the mount as root?

> Thanks,
> Suresh
>  
> > > Iam trying to setup kerberized NFS(v3) client for Linux.
> > >
> > > My setup details
> > > NFS client: Suse Linux Enterprise Server (SLES 9) which has
> > > kernel - 2.6.5-7.97 (CONFIG_SUNRPC=y, CONFIG_SUNRPC_GSS=y,
> > > CONFIG_RPCSEC_GSS_KRB5=y )
> > >
> > > nfs-utils-1.0.7 (patched - nfs-utils-1.0.7-CITI_NFS4_ALL-1.dif)
> > > util-linux-2.12 (patched - util-linux-2.12-CITI_NFS4_ALL-3.dif)
> > >
> > > KDC Server: RedHat Linux
> > > NFS Server: Kerberized Solaris server (KDC Server & NFS Server are
> > > Tested and working fine)
> > >
> > > To setup kerberized Linux Client, I presume a kernel with rpcsecgss
> > > support, patched nfs-utils pkg and patched util-linux pkg is
> > > sufficient. (Let me know any other pkg/configuration is required)
> > >
> > > My NFS Server export entry is:
> > > share -F nfs -o sec=krb5 /export/home
> > >
> > > Server has nfs principal registered to KDC and the user principal of
> > > client also registered to the Server.
> > > After doing a kinit if I try to mount the exported path, Iam getting
> > >
> > > "mount: nfsserver:/export/home failed, reason given by server:
> > > Permission denied"
> > > Then I specified the client name in the exports file make gave
> > > readonly perms. Then also I got the same error.
> > >
> > > Am I missing something ? Any pointers ..
> > >
> > > thanks,
> > > Suresh
> > >
> > >
> > > -------------------------------------------------------
> > > SF email is sponsored by - The IT Product Guide
> > > Read honest & candid reviews on hundreds of IT Products from real users.
> > > Discover which products truly live up to the hype. Start reading now.
> > > http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > 
> > 
> 
> 
> -- 
> "Good Luck is when preparation meets opportunity"
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
