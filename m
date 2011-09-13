Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:49855 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983Ab1IMEll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 00:41:41 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Casey Schaufler <casey@schaufler-ca.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Valdis.Kletnieks@vt.edu, agruen@kernel.org, akpm@linux-foundation.org,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        LSM <linux-security-module@vger.kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH -V6 00/26] New ACL format for better NFSv4 acl interoperability
In-Reply-To: <4E6E89E0.4010406@schaufler-ca.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <4E655049.6060507@schaufler-ca.com> <108028.1315442771@turing-police.cc.vt.edu> <4E6E7ACC.8040003@schaufler-ca.com> <20110912222014.GA17483@fieldses.org> <4E6E89E0.4010406@schaufler-ca.com>
Date: Tue, 13 Sep 2011 10:11:15 +0530
Message-ID: <87wrdd9hqs.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 12 Sep 2011 15:38:24 -0700, Casey Schaufler <casey@schaufler-ca.com> wrote:
> On 9/12/2011 3:20 PM, J. Bruce Fields wrote:
> > On Mon, Sep 12, 2011 at 02:34:04PM -0700, Casey Schaufler wrote:
> >> On 9/7/2011 5:46 PM, Valdis.Kletnieks@vt.edu wrote:
> >>> On Mon, 05 Sep 2011 15:42:17 PDT, Casey Schaufler said:
> >>>> On 9/5/2011 10:25 AM, Aneesh Kumar K.V wrote:
> >>>>> The following set of patches implements VFS and ext4 changes needed to implement
> >>>>> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> >>>>> extended by file( masks to fit into the standard POSIX file permission model.
> >>>>> They are designed to work seamlessly locally as well as across the NFSv4 and
> >>>>> CIFS/SMB2 network file system protocols.
> >>>> POSIX ACLs predate the LSM and can't be done as an LSM due to
> >>>> the interactions between mode bits and ACLs as defined by the
> >>>> POSIX DRAFT specification.
> > I don't know LSM so don't understand what you mean when you say that
> > interactions between mode bits and ACLs would make an ACL model hard to
> > implement as an LSM.
> 
> POSIX ACLs require that the file permission bits change when
> the ACL changes. This interaction violates the strict "additional
> restriction" model of the LSM.
> 
> 
> > But in any case the rich acl/mode bit interactions are similar to the
> > posix acl/mode bit interactions, so the same issue probably applies.
> 
> It would help if you knew for sure and could explain the interaction
> in sufficient detail to justify the position.
> 

Andreas have documented the details here
http://acl.bestbits.at/richacl/draft-gruenbacher-nfsv4-acls-in-posix-00.html

In short with respect to mode bits, the interaction between acl/mode
bits is more or less similar between posix acl and richacl. When we set
richacl we need to make sure that mode bits represent allowed permission
on the file system object. We need to do the above to be posix
compliant.  As per POSIX additional file access control mechanisms may
only further restrict the access permissions defined by the file
permission bits. You can find further details in the OLS 2010 paper on
richacl. http://www.fmeh.org/ols-2010-implementing-richacl-paper.pdf


-aneesh



