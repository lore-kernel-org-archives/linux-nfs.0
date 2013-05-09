Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy14-pub.unifiedlayer.com ([67.222.51.224]:59954 "HELO
	oproxy14-pub.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752523Ab3EIRhN convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 13:37:13 -0400
Subject: Re: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of NFSv4 ACLs <-> POSIX ACLs mapping algorithms
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Vyacheslav Dubeyko <slava@dubeyko.com>
In-Reply-To: <1368118877.3282.104.camel@leira.trondhjem.org>
Date: Thu, 9 May 2013 21:34:50 +0400
Cc: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        "Hin-Tak Leung" <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Message-Id: <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com>
References: <1368117430.5695.30.camel@slavad-ubuntu-12.04> <1368118877.3282.104.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 9, 2013, at 9:01 PM, Myklebust, Trond wrote:

[snip]
> 
> How does this make sense? There is no lossless mapping of NFSv4 acls
> into POSIX acls; the latter doesn't have any equivalent of the DENY aces
> so you cannot represent the full set of acls that can be set using MacOS
> on the same filesystem.
> 
> Shouldn't you rather be looking at the richacl patch sets?
> 

Yes, I understand the nature of such mapping and impossibility of mapping NFSv4 ACLs to POSIX ACLs in some cases. But, as I understand, the richacl patch set is not mainline yet. And even if it will be in mainline then a user can have choice to use POSIX ACLs or richacls. So, we need to map NFSv4 ACLs <-> POSIX ACLs in hfsplus for the case of using POSIX ACLs model. I think that to have such mapping is better than to have nothing. Moreover, a user can use HFS+ filesystem with using POSIX ACLs only under Linux. Thereby, the generalization of mapping NFSv4 ACLs <-> POSIX ACLs makes sense, from my viewpoint.

With the best regards,
Vyacheslav Dubeyko.

> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

