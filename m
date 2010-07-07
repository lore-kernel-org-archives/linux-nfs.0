Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea01.nsa.gov ([63.239.65.39]:38006 "EHLO
	msux-gh1-uea01.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372Ab0GGSTu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 14:19:50 -0400
Subject: Re: [PATCH 07/10] NFSv4: Introduce new label structure
From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        bfields@fieldses.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
In-Reply-To: <4C34BE3A.3050806@oracle.com>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-8-git-send-email-dpquigl@tycho.nsa.gov>
	 <4C34A4F1.3060708@oracle.com>
	 <1278519727.2494.92.camel@moss-terrapins.epoch.ncsc.mil>
	 <4C34BE3A.3050806@oracle.com>
Content-Type: text/plain
Date: Wed, 07 Jul 2010 14:11:54 -0400
Message-Id: <1278526314.2494.170.camel@moss-terrapins.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-07-07 at 13:49 -0400, Chuck Lever wrote:
> On 07/ 7/10 12:22 PM, David P. Quigley wrote:
> > Hello Chuck,
> >     Thank you for the comments. I'll go through and address them inline
> > (Sorry for the top post).
> >
> > On Wed, 2010-07-07 at 12:01 -0400, Chuck Lever wrote:
> >> My comments below apply to the other NFS client patches as well.  This
> >> seemed like the right one to use for code examples.
> >>
> >> On 07/ 7/10 10:31 AM, David P. Quigley wrote:
> 
>    [ ... snipped ... ]
> 
> >> It seems to me you want something more generic, just like nfs_fh or
> >> nfs_fattr, to represent these.  Over time, I'm guessing label support
> >> won't be tied to a specific NFS version.  And, you are passing these
> >> around in the generic NFS functions (for post-op updates and inode
> >> revalidation, and what not).
> >>
> >> Can I recommend "struct nfs_seclabel" instead?  Then have
> >> nfs_seclabel_alloc() and nfs_seclabel_free().
> >
> > I can definitely rename them to be more generic. I don't see anything
> > else besides NFSv4 using them but its fine with me to rename them. The
> > reason we call them nfs4_label is because we modeled it after the NFSv4
> > acl support code. I spoke with Christoph a long time ago and he
> > suggested that it should be handled the same way that the NFSv4 ACLs are
> > handled as opposed to the iattr thing we were trying.
> >
> >>
> >> Does it make sense to deduplicate these in the client's memory?  It
> >> seems to me that you could have hundreds or thousands that all contain
> >> the same label information.
> >
> > I don't think it is worth the effort. We are only using these structures
> > until the security label is crammed into the inode. Once that happens
> > they get freed. You shouldn't have them sitting around for very long.
> 
> OK, the lifetime of these things wasn't clear.
> 
> > They will be pulled again when the inode attributes expire and need to
> > be revalidated. For things like SELinux you could argue that the LSM
> > might benefit from this (and it might already do it but I'm not sure)
> > but I think that is something to be handled by the LSM itself or the
> > credentials code (since it already supports COW credentials it should be
> > possible).
> 
> I think the lifetime of the label structure then is about the same as 
> the lifetime of an nfs_attr, and not at all the same as an ACL.  I'm 
> just guessing here.

Intersting I figured that the ACL structure was just to get it to a
point where you could convert the NFS ACL into a posixacl and set it in
the inode. I didn't realize they were hanging around for a while.

> 
> Would it then make sense to add a field that refers to the security 
> label to struct nfs_fattr instead?  That might simplify or eliminate all 
> of the internal API changes.

I want to say that we had it in there at one point and then we endedup
running into a problem and having to change it. I'll ask Matt about what
problems we had sticking it in the nfs_fattr initially.

Dave

