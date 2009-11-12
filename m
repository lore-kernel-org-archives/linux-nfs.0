From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [pnfs] [PATCH 2/5] nfsd: Fix independence of a few nfsd related
 headers
Date: Thu, 12 Nov 2009 16:45:52 +0200
Message-ID: <4AFC1FA0.7040309@panasas.com>
References: <4ADEC1EF.8040107@panasas.com>	 <1256112873-32495-1-git-send-email-bharrosh@panasas.com>	 <4AFBE34B.8020905@panasas.com>	 <1258022133.2973.5.camel@heimdal.trondhjem.org>	 <4AFC0429.6030803@panasas.com> <1258033010.2968.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:49620 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752522AbZKLOpu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2009 09:45:50 -0500
In-Reply-To: <1258033010.2968.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2009 03:36 PM, Trond Myklebust wrote:
> On Thu, 2009-11-12 at 14:48 +0200, Boaz Harrosh wrote:
>>
>> from posix_acl.h:
>> extern int posix_acl_permission(struct inode *, const struct posix_acl *, int);
>>
>> stuct inode is defined in fs.h. hence the direct dependency.
> 
> Add a forward declaration of the form
> 
> struct inode;
> 

This will not work.

<quote>
...

static inline struct posix_acl *get_cached_acl(struct inode *inode, int type)
{
	struct posix_acl **p, *acl;
	switch (type) {
	case ACL_TYPE_ACCESS:
		p = &inode->i_acl;
		break;
	case ACL_TYPE_DEFAULT:
		p = &inode->i_default_acl;
		break;
	default:
		return ERR_PTR(-EINVAL);
	}
...
</quote>

the header has inlines that directly manipulate inode members
a forward declaration is not enough.

<snip>
>> And please note that this particular file is an NFSD and vfs related file only, it
>> has nothing to do with nfs.
> 
> ...and hence you need to send it to the VFS maintainer. I'm not touching
> that patch, or the patchset that "requires" it.
> 

OK This particular hunk I will send to fsdevel, anything else?

Boaz
