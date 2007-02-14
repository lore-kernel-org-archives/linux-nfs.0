From: Ming Zhang <blackmagic02881@gmail.com>
Subject: Re: [PATCH 001 of 9] knfsd: nfsd4: fix non-terminated string
Date: Wed, 14 Feb 2007 13:04:46 -0500
Message-ID: <1171476286.3336.9.camel@localhost.localdomain>
References: <20070213103941.28958.patches@notabene>
	<1070212234402.29224@suse.de>
	<1171458018.2638.1.camel@localhost.localdomain>
	<45D34D0D.3040606@oracle.com>
Reply-To: blackmagic02881@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HHOVC-0000Os-0V
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 10:05:10 -0800
Received: from wx-out-0506.google.com ([66.249.82.231])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HHOVD-0002PU-7t
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 10:05:11 -0800
Received: by wx-out-0506.google.com with SMTP id i30so410743wxd
	for <nfs@lists.sourceforge.net>; Wed, 14 Feb 2007 10:05:10 -0800 (PST)
In-Reply-To: <45D34D0D.3040606@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-02-14 at 09:55 -0800, Chuck Lever wrote:
> Ming Zhang wrote:
> > On Tue, 2007-02-13 at 10:44 +1100, NeilBrown wrote:
> >> From: J. Bruce Fields <bfields@citi.umich.edu>
> >> The server name is expected to be a null-terminated string, so we can't
> >> pass in the raw client identifier.
> >>
> >> What's more, the client identifier is just a binary, not necessarily
> >> printable, blob.  Let's just use the ip address instead.  The server
> >> name appears to exist just to help debugging by making some printk's
> >> more informative.
> >>
> >> Note that the string is copies into the rpc client structure, so
> >> the pointer to the local variable does not outlive the function call.
> >>
> >> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> >> Signed-off-by: Neil Brown <neilb@suse.de>
> >>
> >> ### Diffstat output
> >>  ./fs/nfsd/nfs4callback.c |    7 ++++++-
> >>  1 file changed, 6 insertions(+), 1 deletion(-)
> >>
> >> diff .prev/fs/nfsd/nfs4callback.c ./fs/nfsd/nfs4callback.c
> >> --- .prev/fs/nfsd/nfs4callback.c	2007-02-13 09:50:26.000000000 +1100
> >> +++ ./fs/nfsd/nfs4callback.c	2007-02-13 10:00:59.000000000 +1100
> >> @@ -387,7 +387,6 @@ nfsd4_probe_callback(struct nfs4_client 
> >>  		.address	= (struct sockaddr *)&addr,
> >>  		.addrsize	= sizeof(addr),
> >>  		.timeout	= &timeparms,
> >> -		.servername	= clp->cl_name.data,
> >>  		.program	= program,
> >>  		.version	= nfs_cb_version[1]->number,
> >>  		.authflavor	= RPC_AUTH_UNIX,	/* XXX: need AUTH_GSS... */
> >> @@ -397,6 +396,7 @@ nfsd4_probe_callback(struct nfs4_client 
> >>  		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
> >>  		.rpc_argp       = clp,
> >>  	};
> >> +	char clientname[16];
> >>  	int status;
> >>  
> >>  	if (atomic_read(&cb->cb_set))
> >> @@ -419,6 +419,11 @@ nfsd4_probe_callback(struct nfs4_client 
> >>  	memset(program->stats, 0, sizeof(cb->cb_stat));
> >>  	program->stats->program = program;
> >>  
> >> +	/* Just here to make some printk's more useful: */
> >> +	snprintf(clientname, sizeof(clientname),
> >> +		"%u.%u.%u.%u", NIPQUAD(addr.sin_addr));
> > 
> > can use NIPQUAD_FMT here instead of "%u.%u.%u.%u".
> > 
> > btw, will the ip address here possibly be an ipv6 address?
> 
> Some patches are in the works to build in IPv6 support.  See the patch 
> series at http://oss.oracle.com/~cel/linux-2.6/2.6.19/patches/

thanks for the info.

-- 
http://blackmagic02881.wordpress.com/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
