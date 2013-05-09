Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36556 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853Ab3EISKY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 14:10:24 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Vyacheslav Dubeyko <slava@dubeyko.com>
CC: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        "Hin-Tak Leung" <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of
 NFSv4 ACLs <-> POSIX ACLs mapping algorithms
Date: Thu, 9 May 2013 18:10:22 +0000
Message-ID: <1368123021.3282.117.camel@leira.trondhjem.org>
References: <1368117430.5695.30.camel@slavad-ubuntu-12.04>
	 <1368118877.3282.104.camel@leira.trondhjem.org>
	 <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com>
In-Reply-To: <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-09 at 21:34 +0400, Vyacheslav Dubeyko wrote:
> On May 9, 2013, at 9:01 PM, Myklebust, Trond wrote:
> 
> [snip]
> > 
> > How does this make sense? There is no lossless mapping of NFSv4 acls
> > into POSIX acls; the latter doesn't have any equivalent of the DENY aces
> > so you cannot represent the full set of acls that can be set using MacOS
> > on the same filesystem.
> > 
> > Shouldn't you rather be looking at the richacl patch sets?
> > 
> 
> Yes, I understand the nature of such mapping and impossibility of mapping NFSv4 ACLs to POSIX ACLs in some cases. But, as I understand, the richacl patch set is not mainline yet. And even if it will be in mainline then a user can have choice to use POSIX ACLs or richacls. So, we need to map NFSv4 ACLs <-> POSIX ACLs in hfsplus for the case of using POSIX ACLs model. I think that to have such mapping is better than to have nothing. Moreover, a user can use HFS+ filesystem with using POSIX ACLs only under Linux. Thereby, the generalization of mapping NFSv4 ACLs <-> POSIX ACLs makes sense, from my viewpoint.

No, there is no requirement that you must support the POSIX acl
interface in addition to NFSv4/richacls.

No, supporting a POSIX mapping is not necessarily "better than nothing"
if it cannot faithfully represent the original NFSv4 acl. Do you at
least enforce the original acl in permissions checks?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
