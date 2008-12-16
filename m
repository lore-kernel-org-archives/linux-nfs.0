From: Jeff Layton <jlayton@redhat.com>
Subject: Re: possible module refcount leak with auth_gss
Date: Tue, 16 Dec 2008 16:45:32 -0500
Message-ID: <20081216164532.22cab9d6@tleilax.poochiereds.net>
References: <20081208102855.30081708@tleilax.poochiereds.net>
	<20081208173706.GE16628@fieldses.org>
	<20081209153849.6605559a@tleilax.poochiereds.net>
	<4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
	<20081210112506.2b2d2c3a@tleilax.poochiereds.net>
	<20081210163136.GB28263@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20081210163136.GB28263@fieldses.org>
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

On Wed, 10 Dec 2008 11:31:36 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Dec 10, 2008 at 11:25:06AM -0500, Jeff Layton wrote:
> > It works. With a nfs-utils that has your patches to properly set the
> > cache timeouts it looks like this problem is generally fixed. The module
> > refcounts go back to normal once the tickets expire.
> > 
> > That said, I think we should have a look at Bruce's suggestion for changing
> > the way that the module refcounts are actually handled. It would seem to
> > make more sense to hold the reference based on the exports using that auth
> > scheme, and to purge the caches on module unload.
> > 
> > Not a huge deal, but probably something we should consider.
> 
> Yeah.  Since I don't care enough about module unloading, I'm not going
> to work on this now.  But it's unfortunate.
> 
> I'm a little more worried about why the RPC_GSS_PROC_DESTROY requests
> aren't working.
> 

I took some time today to dig into this. Here's some debug output from
the RPC_GSS_PROC_DESTROY request on the client:

RPC:     0 holding RPCSEC_GSS cred ffff880011579bb8
RPC:       new task initialized, procpid 2846
RPC:       allocated task ffff88001e110000
RPC:    11 __rpc_execute flags=0x281
RPC:    11 call_start nfs4 proc NULL (async)
RPC:    11 call_reserve (status 0)
RPC:    11 call_refresh (status 0)
RPC:    11 refreshing RPCSEC_GSS cred ffff880011579bb8
RPC:    11 call_refreshresult (status -13)
RPC:    11 return 0, status -13
RPC:    11 release task
RPC:    11 releasing RPCSEC_GSS cred ffff880011579bb8

...looks like we're trying to refresh the credentials before sending the
call but that's failing. That's as far as I've gotten with it so far
though.

-- 
Jeff Layton <jlayton@redhat.com>
