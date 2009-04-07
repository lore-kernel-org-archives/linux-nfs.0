From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Tue, 7 Apr 2009 19:37:30 -0400
Message-ID: <20090407193730.6b662f45@tleilax.poochiereds.net>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
	<1239117946-7535-4-git-send-email-jlayton@redhat.com>
	<41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
	<49db7f0d.85c2f10a.5025.ffffb257@mx.google.com>
	<20090407131151.69203e5e@tleilax.poochiereds.net>
	<49dbacf3.14025a0a.5898.ffffbaa2@mx.google.com>
	<20090407231406.GC28733@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090407231406.GC28733@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 7 Apr 2009 19:14:06 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Apr 07, 2009 at 03:43:39PM -0400, Tom Talpey wrote:
> > At 01:11 PM 4/7/2009, Jeff Layton wrote:
> > >On Tue, 07 Apr 2009 12:27:49 -0400
> > >Tom Talpey <tmtalpey@gmail.com> wrote:
> > >
> > >> At 12:02 PM 4/7/2009, Chuck Lever wrote:
> > >> >
> > >> >On Apr 7, 2009, at 11:25 AM, Jeff Layton wrote:
> > >> >> +	/* Use standard NFS port for NFSv4 */
> > >> >> +	if (program == 100003 && version == 4) {
> > >> >> +		port = 2049;
> > >> >> +		goto set_port;
> > >> >> +	}
> > >> >
> > >> >I think this patch set looks pretty reasonable.  Here's my one  
> > >> >remaining quibble.
> > >> >
> > >> >You can specify "port=" for nfs4 mounts, in which case we want to use  
> > >> >that value here, too, I think.  It would be simpler overall if the  
> > >> 
> > >> *Must* use a port= specification. The 2049 definition is only true for
> > >> NFSv4/TCP, as a counterexample the NFSv4/RDMA IANA binding is
> > >> port 20049. So slamming the port to 2049 would break NFSv4/RDMA.
> > >> 
> > >
> > >rpc.gssd doesn't seem to be rdma-enabled at this point. It only seems
> > >to handle "tcp" and "udp" in the existing code.
> > 
> > Fair enough. But hardwiring 2049 for all transports is going to very
> > problematic. What's the motivation for bypassing the rpcbind query
> > altogether (that "goto set_port" skips over it)? Why not at least
> > try the query first?
> 
> We're just doing the rpcsec_gss context initiation.  Normally that would
> be done over an already-established connection--the only reason we don't
> is because our implementation is split between the client and the
> server, so it's more convenient for us to set up a new connection in
> rpc.gssd.  But we really shouldn't be doing an entirely new rpcbind
> call--somebody else already did that for us and is telling us the
> results through the rpc_pipefs info file.
> 

Technically, the info file doesn't display the port from an rpcbind
call. That field is populated before the kernel's rpcbind call is
done. The contents will be one of:

- the value of the port= mount option if one was specified
- 2049 if it's an nfs4 mount and there is no port= option specified
- 0 if nfsv2/3 and no port= option was specified

...its real value is in allowing gssd to skip the rpcbind call if
someone specified port= when doing the mount. This could probably
be changed, but I'm not sure it's such a big deal. It only means an
extra rpcbind call at mount time for NFSv2/3. Further upcalls for
other creds by the same client don't incur extra rpcbind queries.

-- 
Jeff Layton <jlayton@redhat.com>
