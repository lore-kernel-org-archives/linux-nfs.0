Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy12-pub.bluehost.com ([50.87.16.10]:44381 "HELO
	oproxy12-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752343Ab3EJLSD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 07:18:03 -0400
Subject: Re: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of NFSv4 ACLs <-> POSIX ACLs mapping algorithms
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Vyacheslav Dubeyko <slava@dubeyko.com>
In-Reply-To: <20130509181647.GA18541@pad.fieldses.org>
Date: Fri, 10 May 2013 15:19:45 +0400
Cc: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Message-Id: <243AE8A2-453A-4F16-BF66-4E1EE4EA8309@dubeyko.com>
References: <1368117430.5695.30.camel@slavad-ubuntu-12.04> <1368118877.3282.104.camel@leira.trondhjem.org> <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com> <20130509181647.GA18541@pad.fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 9, 2013, at 10:10 PM, Myklebust, Trond wrote:

[snip]
> 
> No, there is no requirement that you must support the POSIX acl
> interface in addition to NFSv4/richacls.
> 
> No, supporting a POSIX mapping is not necessarily "better than nothing"
> if it cannot faithfully represent the original NFSv4 acl. Do you at
> least enforce the original acl in permissions checks?

On May 9, 2013, at 10:16 PM, J. Bruce Fields wrote:

[snip]
>> Yes, I understand the nature of such mapping and impossibility of
>> mapping NFSv4 ACLs to POSIX ACLs in some cases. But, as I understand,
>> the richacl patch set is not mainline yet.
> 
> Neither are these patches.  You could pick up the richacl patches and
> work on them instead.  That might be more work, I don't know, but the
> result would certainly be more useful, to many more people....
> 
>> And even if it will be in mainline then a user can have choice to use
>> POSIX ACLs or richacls.
> 
> I actually kinda like the idea of allowing people to use either model
> and translating automatically between them.  But it is complicated, and
> I'm not convinced it's necessary.
> 
>> So, we need to map NFSv4 ACLs <-> POSIX ACLs in hfsplus for the case
>> of using POSIX ACLs model. I think that to have such mapping is better
>> than to have nothing.
> 
> So, in the "better than nothing" spirit, I'll take a look at these, but
> I would still rather we get the richacl stuff done....
> 
> --b.

Yes, I am going to support richacls on hfsplus side when the richacl patch set will be in mainline. How soon it will be in mainline? Why the richacl patch set is not mainline yet? What it should be made for promoting richacl patch set in mainline?

The most of file systems in Linux support POSIX ACL model. So, I think that it makes sense to support POSIX ACLs for HFS+ also. Because it is possible to use POSIX ACLs only under Linux. And such extended attributes may be simply ignored under Mac OS X. So, what good way is for it? I think that we can use "com.apple.system.Security" xattrs for richacl model. And this xattrs will be valid NFSv4 ACLs as for Linux as for Mac OS X. But also it is possible to use "system.posix_acl_access" and "system.posix_acl_default" xattrs as storage of POSIX ACLs that will be treated only under Linux as ACLs. Mac OS X will treat such xattrs as raw xattrs without any real meaning for this OS. What do you think about such suggestion?

With the best regards,
Vyacheslav Dubeyko.

