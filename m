From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] [PATCH] knfsd: set the response bitmask for
	NFS4_CREATE_EXCLUSIVE (repost)
Date: Thu, 28 Jun 2007 06:54:21 -0400
Message-ID: <20070628065421.19d1c73e.jlayton@redhat.com>
References: <20070627092903.82f468cd.jlayton@redhat.com>
	<18050.54805.859007.848292@notabene.brown>
	<20070627212805.GA6267@fieldses.org>
	<20070627213047.1ecf1c09.jlayton@redhat.com>
	<20070628031416.GE20605@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20070628031416.GE20605@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 27 Jun 2007 23:14:16 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jun 27, 2007 at 09:30:47PM -0400, Jeff Layton wrote:
> > Here's a respun patch that includes an updated comment in nfsd_create_v3.
> > Look ok?
> 
> Looks fine to me, thanks.  So this tells the client which attributes it
> should set in a subsequent setattr?
> 

Yep. There's a client side patch that went into Trond's tree recently
too. Hopefully I've interpreted the spec correctly ;-)

> It's queued up in my tree, so if Neil doesn't take it then I'll pass it
> along to him for v2.6.23....
> 

Thanks!

> --b.
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-- 
Jeff Layton <jlayton@redhat.com>
