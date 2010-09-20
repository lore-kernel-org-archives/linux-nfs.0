Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:39235 "EHLO
	mx01.colomx.prod.int.phx2.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752119Ab0ITPQp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 11:16:45 -0400
Date: Mon, 20 Sep 2010 11:15:56 -0400 (EDT)
From: Sachin Prabhu <sprabhu@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-ID: <981484.56.1284995756178.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
In-Reply-To: <14128115.54.1284995685991.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Subject: Re: Should we be aggressively invalidating cache when using
 -onolock?
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

----- "Chuck Lever" <chuck.lever@oracle.com> wrote:
> It also seems to me that if RHEL 4 is _not_ invalidating on lock, then
> it is not working as designed.  AFAIK the Linux NFS client has always
> invalidated a file's data cache on lock.  Did I misread something?
> 

The flock support for NFS was only implemented in the 2.6.12 kernel. Hence on the RHEL 4 kernel ie 2.6.9 nfs_file_operations->flock is NULL and any flock operations performed by the application was only applicable on that node. No part of the NFS client code was executed for the flock() operation. 

Sachin Prabhu
