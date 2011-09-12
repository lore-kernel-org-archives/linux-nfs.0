Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755182Ab1ILWUU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Sep 2011 18:20:20 -0400
Date: Mon, 12 Sep 2011 18:20:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Valdis.Kletnieks@vt.edu,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        LSM <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH -V6 00/26] New ACL format for better NFSv4 acl
 interoperability
Message-ID: <20110912222014.GA17483@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <4E655049.6060507@schaufler-ca.com>
 <108028.1315442771@turing-police.cc.vt.edu>
 <4E6E7ACC.8040003@schaufler-ca.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E6E7ACC.8040003@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 12, 2011 at 02:34:04PM -0700, Casey Schaufler wrote:
> On 9/7/2011 5:46 PM, Valdis.Kletnieks@vt.edu wrote:
> > On Mon, 05 Sep 2011 15:42:17 PDT, Casey Schaufler said:
> >> On 9/5/2011 10:25 AM, Aneesh Kumar K.V wrote:
> >>> The following set of patches implements VFS and ext4 changes needed to implement
> >>> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> >>> extended by file( masks to fit into the standard POSIX file permission model.
> >>> They are designed to work seamlessly locally as well as across the NFSv4 and
> >>> CIFS/SMB2 network file system protocols.
> >>
> >> POSIX ACLs predate the LSM and can't be done as an LSM due to
> >> the interactions between mode bits and ACLs as defined by the
> >> POSIX DRAFT specification.

I don't know LSM so don't understand what you mean when you say that
interactions between mode bits and ACLs would make an ACL model hard to
implement as an LSM.

But in any case the rich acl/mode bit interactions are similar to the
posix acl/mode bit interactions, so the same issue probably applies.

--b.
