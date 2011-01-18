Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133Ab1ARSPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 13:15:55 -0500
Message-ID: <4D35D8B3.4030308@redhat.com>
Date: Tue, 18 Jan 2011 19:15:15 +0100
From: Milan Broz <mbroz@redhat.com>
To: Chuck Lever <Chuck.Lever@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: NFS OOps  - kernel BUG at fs/nfs/nfs3xdr.c:1338
References: <4D30D9D6.2080809@redhat.com> <1295048791.20016.15.camel@heimdal.trondhjem.org> <BC9E8816-B395-44C1-ACF8-FEC4E80870C1@oracle.com>
In-Reply-To: <BC9E8816-B395-44C1-ACF8-FEC4E80870C1@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/18/2011 04:59 PM, Chuck Lever wrote:

>>> [  105.327979] kernel BUG at fs/nfs/nfs3xdr.c:1338!
> 
> Milan, I assume the install command is trying to set an ACL on an NFS file.  Can you tell us what the ACL looks like?

Hi,

strace returns
fsetxattr(4, "system.posix_acl_access", "\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x00\x00\xff\xff\xff\xff \x00\x00\x00\xff\xff\xff\xff", 28, 0) = -1 EOPNOTSUPP (Operation not supported)

and it is reproducible with simple code:
        int fd = open("x", O_RDWR|O_CREAT, S_IRWXU);
        fsetxattr(fd, "system.posix_acl_access",
        "\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x00\x00\xff\xff\xff\xff \x00\x00\x00\xff\xff\xff\xff", 28, 0);

Milan
