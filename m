From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: possible module refcount leak with auth_gss
Date: Wed, 10 Dec 2008 11:31:36 -0500
Message-ID: <20081210163136.GB28263@fieldses.org>
References: <20081208102855.30081708@tleilax.poochiereds.net>
	<20081208173706.GE16628@fieldses.org>
	<20081209153849.6605559a@tleilax.poochiereds.net>
	<4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
	<20081210112506.2b2d2c3a@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20081210112506.2b2d2c3a@tleilax.poochiereds.net>
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

On Wed, Dec 10, 2008 at 11:25:06AM -0500, Jeff Layton wrote:
> It works. With a nfs-utils that has your patches to properly set the
> cache timeouts it looks like this problem is generally fixed. The module
> refcounts go back to normal once the tickets expire.
> 
> That said, I think we should have a look at Bruce's suggestion for changing
> the way that the module refcounts are actually handled. It would seem to
> make more sense to hold the reference based on the exports using that auth
> scheme, and to purge the caches on module unload.
> 
> Not a huge deal, but probably something we should consider.

Yeah.  Since I don't care enough about module unloading, I'm not going
to work on this now.  But it's unfortunate.

I'm a little more worried about why the RPC_GSS_PROC_DESTROY requests
aren't working.

--b.
