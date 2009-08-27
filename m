From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATHC] nfsd: Fix a couple issues with POSIX->NFSv4 ACL conversion
Date: Thu, 27 Aug 2009 17:37:38 -0400
Message-ID: <20090827213738.GF11721@fieldses.org>
References: <1250287351.32255.3.camel@dyn9047022153>
	<20090824235944.GH8532@fieldses.org>
	<1251394811.32255.6.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <linux-nfs@vger.kernel.org>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1251394811.32255.6.camel@dyn9047022153>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 27, 2009 at 10:40:11AM -0700, Frank Filz wrote:
> On Mon, 2009-08-24 at 19:59 -0400, J. Bruce Fields wrote:
> > On Fri, Aug 14, 2009 at 03:02:30PM -0700, Frank Filz wrote:
> > > 1. GROUP@ Allow entry doesn't have NFS4_ACE_IDENTIFIER_GROUP, This
> > > appears to have been introduced by accident as part of commit
> > > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=bec50c47aaf6f1f9247f1860547ab394a0802a4c
> > 
> > It's good to flip that bit every now and then just to keep client
> > implementations on their toes....
> > 
> > 	(Slightly more seriously, the 4.1 draft says "The
> > 	ACE4_IDENTIFIER_GROUP flag MUST be ignored on entries with these
> > 	special identifiers.  When encoding entries with these special
> > 	identifiers, the ACE4_IDENTIFIER_GROUP flag SHOULD be set to
> > 	zero."  It really shouldn't matter either way, but the point is
> > 	that this flag is used to distinguish named users from named
> > 	groups (since unix allows a group to have the same name as a
> > 	user), so it doesn't really make sense to use it on a special
> > 	identifier such as this.)
> 
> Ok, that makes sense, in that case, we probably should have this
> fragment to remove the flag from the GROUP@ deny entry:

Sure.  Applied.

--b.

> 
> @@ -321,7 +321,7 @@ _posix_to_nfsv4_one(struct posix_acl *pacl, struct nfs4_acl *acl,
>  	deny = ~pas.group & pas.other;
>  	if (deny) {
>  		ace->type = NFS4_ACE_ACCESS_DENIED_ACE_TYPE;
> -		ace->flag = eflag | NFS4_ACE_IDENTIFIER_GROUP;
> +		ace->flag = eflag;
>  		ace->access_mask = deny_mask_from_posix(deny, flags);
>  		ace->whotype = NFS4_ACL_WHO_GROUP;
>  		ace++;
> 
> 
