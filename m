From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Native NFSv4 ACLs on Linux
Date: Fri, 14 Jul 2006 17:16:59 +0200
Message-ID: <200607141716.59827.agruen@suse.de>
References: <200607141637.32246.agruen@suse.de>
	<1152888586.14027.18.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: nfs@lists.sourceforge.net, nfsv4@ietf.org
Return-path: <nfsv4-bounces@ietf.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1152888586.14027.18.camel@lade.trondhjem.org>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Friday, 14 July 2006 16:49, Trond Myklebust wrote:
> On Fri, 2006-07-14 at 16:37 +0200, Andreas Gruenbacher wrote:
> > Hello,
> >
> > This is to announce a prototype that implements NFSv4 ACLs natively on
> > Linux. So far, the implementation supports NFSv4 ACLs on Ext3
> > filesystems. The code is functional, but hasn't seen a whole lot of
> > testing so far.
>
> Ooh. Interesting...
>
> Are you planning on encoding the acl model that is being used directly
> in the on-disk filesystem flags instead of relying on a mount option?

I haven't thought about this much so far. At the moment it's either POSIX ACLs 
or NFSv4 ACLs, per filesystem, and even if xattrs of the "other" ACL model 
exist on the filesystem, they will be completely invisible. We could encode 
the ACL model used in the filesystem flags, or think about mixed models as 
known from NetApp Filers. There is a lot more work to be done before we'll 
get there though.

> The incompatibilities between the two models is bound to cause trouble
> if some administrator messes up the mount command line.

Quite likely, yes.

Andreas

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
