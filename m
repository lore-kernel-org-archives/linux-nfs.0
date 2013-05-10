Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53710 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757410Ab3EJR2P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 May 2013 13:28:15 -0400
Date: Fri, 10 May 2013 13:28:02 -0400
To: Vyacheslav Dubeyko <slava@dubeyko.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of
 NFSv4 ACLs <-> POSIX ACLs mapping algorithms
Message-ID: <20130510172801.GA14936@fieldses.org>
References: <1368117430.5695.30.camel@slavad-ubuntu-12.04>
 <1368118877.3282.104.camel@leira.trondhjem.org>
 <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com>
 <20130509181647.GA18541@pad.fieldses.org>
 <243AE8A2-453A-4F16-BF66-4E1EE4EA8309@dubeyko.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <243AE8A2-453A-4F16-BF66-4E1EE4EA8309@dubeyko.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 10, 2013 at 03:19:45PM +0400, Vyacheslav Dubeyko wrote:
> Yes, I am going to support richacls on hfsplus side when the richacl
> patch set will be in mainline. How soon it will be in mainline? Why
> the richacl patch set is not mainline yet?

Because nobody's working on it.  Why don't you work on it?

> What it should be made for
> promoting richacl patch set in mainline?

Track down the latest version, rebase it to the latest kernel, make sure
it still works (I think there are also some tests that you'd want to
run).  Look for feedback on previous postings, read it and take it into
account.  Post new versions, get feedback.  Repeat as necessary.

> The most of file systems in Linux support POSIX ACL model. So, I think
> that it makes sense to support POSIX ACLs for HFS+ also. Because it is
> possible to use POSIX ACLs only under Linux. And such extended
> attributes may be simply ignored under Mac OS X. So, what good way is
> for it? I think that we can use "com.apple.system.Security" xattrs for
> richacl model. And this xattrs will be valid NFSv4 ACLs as for Linux
> as for Mac OS X. But also it is possible to use
> "system.posix_acl_access" and "system.posix_acl_default" xattrs as
> storage of POSIX ACLs that will be treated only under Linux as ACLs.
> Mac OS X will treat such xattrs as raw xattrs without any real meaning
> for this OS. What do you think about such suggestion?

I don't know, it depends on how you expect the filesystem to be used.

--b.
