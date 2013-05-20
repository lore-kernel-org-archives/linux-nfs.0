Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57472 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab3ETTYm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 15:24:42 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 09/13] NFS:Add labels to client function prototypes
Date: Mon, 20 May 2013 19:24:40 +0000
Message-ID: <1369077843.6115.31.camel@leira.trondhjem.org>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
	 <1368719808-14584-10-git-send-email-SteveD@redhat.com>
In-Reply-To: <1368719808-14584-10-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-16 at 11:56 -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>
> 
> >From David Quigley <dpquigl@davequigley.com>
> 
> After looking at all of the nfsv4 operations the label structure has been added
> to the prototypes of the functions which can transmit label data.
> 

Why do helpers like nfs_post_op_update_inode() need to be here?

Also, instead of converting functions like nfs_refresh_inode() that are
used absolutely everywhere, why not make special versions,
nfs_refresh_labeled_inode() for those call sites that actually do use
labels?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
