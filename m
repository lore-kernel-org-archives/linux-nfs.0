From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: possible module refcount leak with auth_gss
Date: Wed, 17 Dec 2008 14:54:11 -0500
Message-ID: <1229543651.7257.107.camel@heimdal.trondhjem.org>
References: <20081208102855.30081708@tleilax.poochiereds.net>
	<20081208173706.GE16628@fieldses.org>
	<20081209153849.6605559a@tleilax.poochiereds.net>
	<4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
	<20081210112506.2b2d2c3a@tleilax.poochiereds.net>
	<20081210163136.GB28263@fieldses.org>
	<20081216164532.22cab9d6@tleilax.poochiereds.net>
	<20081216214051.51019f51@tupile.poochiereds.net>
	<20081217192047.GL4614@fieldses.org>
	<20081217143458.080aa9be@tleilax.poochiereds.net>
	<20081217194127.GN4614@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, Trond Myklebust <trond@netapp.com>,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20081217194127.GN4614@fieldses.org>
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

On Wed, 2008-12-17 at 14:41 -0500, J. Bruce Fields wrote:
> It looks like the CRED_UPTODATE is just being used as a signal to decide
> whether the PROC_DESTROY has already been sent; the test_and_clear_bit
> ensures that the null call is made just once.  Maybe a separate flag
> would be simpler.

Just make a separate gss_destroy_cred() which doesn't call
gss_destroying_context() and stick it into gss_nullops.

Trond
