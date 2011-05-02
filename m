Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34327 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344Ab1EBRSg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 13:18:36 -0400
Subject: Re: How does NFS handle notify?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stef Bon <stefbon@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <BANLkTikZnnt0cmpP4iT4Q4EJTxZnSC_SYQ@mail.gmail.com>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	 <20110502140750.GA10885@fieldses.org>
	 <BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
	 <1304347155.7830.7.camel@lade.trondhjem.org>
	 <BANLkTikZnnt0cmpP4iT4Q4EJTxZnSC_SYQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 02 May 2011 13:18:19 -0400
Message-ID: <1304356699.7830.26.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-05-02 at 16:56 +0200, Stef Bon wrote:
> Sorry,
> 
> Gamin is in the first place completly useless in my case. Futher I've
> tried to contact the developer of gamin, but no response at all, from
> different addresses.
> 
> And also with other fs's like cifs (and I think nfs as well), what I
> try to achieve is that the fs self is responsible for the handling of
> the inotify request.
> 
> How to do this? First possible via VFS, clients will set a watch on
> (mounted) fs directly, VFS handles this call and forwards it to the
> mounted fs. I write here forward, I mean sends a signal to the mounted
> fs about a notify watch being set on a inode. After that (and being
> successfull) the VFS opens a fd the mounted fs can send events to when
> something happens on the inode (what is significant).
> 
> Next via a daemon like Gamin. Yes, possible, but is this smart? Isn't
> it just possible through the VFS like above described.

All filesystems should already support notification for files that are
created through the VFS.

The missing bit is to support notification for files that are created on
the _server_ and that never go through the client VFS. That is precisely
the problem that projects such as FAM and gamin are supposed to solve
using generic userland daemons that can re-export the notifications from
the NFS/CIFS/... server to any interested listeners.

Note that there is no NFS protocol support for notifications in v2, v3
or v4. NFSv4.1 does have some limited protocol support for notifications
(dnotify only), but we haven't implemented them on Linux.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

