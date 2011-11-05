Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47592 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab1KEOTY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Nov 2011 10:19:24 -0400
Received: by ywf7 with SMTP id 7so3532418ywf.19
        for <linux-nfs@vger.kernel.org>; Sat, 05 Nov 2011 07:19:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <loom.20111104T233047-797@post.gmane.org>
References: <loom.20111104T233047-797@post.gmane.org>
Date: Sat, 5 Nov 2011 10:19:23 -0400
Message-ID: <CAKnQG+eLQN8jJz77+x=faYj7jm+oOA-ckMxwxOC3aYKatRgJeg@mail.gmail.com>
Subject: Re: NFSV4 and Kerberos ( Failed to create machine krb5 context with
 any credentials cache for server )
From: Kevin Coffman <kwc@umich.edu>
To: Sumana Annam <sumana@vigyaan.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 4, 2011 at 7:11 PM, Sumana Annam <sumana@vigyaan.com> wrote:
> Problem description:
>
> Have both NFS Server and NFS Client working on the same RedHat 6.0 ( rhel60sec02
> ) with kernel version 2.3.32 running on the same box. The redhat server has the
> following installed:
>
> Installed:
>
>  nfs-utils.x86_64 1:1.2.2-7.el6       nfs4-acl-tools.x86_64 0:0.3.3-5.el6
>  rpcbind.x86_64 0:0.2.0-8.el6
>
> Dependency Installed:
>
>  libevent.x86_64 0:1.4.13-1.el6       libgssglue.x86_64 0:0.1-8.1.el6
>  libtirpc.x86_64 0:0.2.1-1.el6        nfs-utils-lib.x86_64 0:1.1.5-1.el6
>
> Machine is joined to the domain and it is defined in DNS as
> rhel60sec02.ngdclab.local
>
> Shared directory: /var/share
>
> Mount point: /mnt
>
> Windows is 2008 R2 server with 2008 Domain level.
>
> Followed the instructions from Tom's blog in addition with KB article and set up
> exports, fstab on the same box. The upn is set on rhel60sec02 server in AD to
> 'nfs/rhel60sec02.ngdclab.local@NGDCLAB.LOCAL'. As root, running kinit -k
> rhel60sec02$ gets the ticket with RC4 enc type. So NFS Client is working but
> when we run the command :
>
> mount -t nfs4 -o sec=krb5 rhel60sec02:/ /var/mnt results in Access denied
> generic error message.
>
> Turned on verbose level logging on both rpc.gssd and rpc.svcgssd which brings up
> the following error messages:
>
> Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: WARNING: Failed to create krb5
> context for user with uid 0 for server rhel60sec02.ngdclab.local
> Nov  4 13:01:27 rhel60sec02 rpc.svcgssd[10943]: finished handling null request
> Nov  4 13:01:27 rhel60sec02 rpc.svcgssd[10943]: entering poll
> Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: WARNING: Failed to create machine
> krb5 context with credentials cache FILE:/tmp/krb5cc_machine_NGDCLAB.LOCAL for
> server rhel60sec02.ngdclab.local
> Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: WARNING: Failed to create machine
> krb5 context with any credentials cache for server rhel60sec02.ngdclab.local
> Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: doing error downcall
> Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: destroying client
> /var/lib/nfs/rpc_pipefs/nfs/clnt55
> Nov  4 13:01:27 rhel60sec02 rpc.gssd[10897]: destroying client
> /var/lib/nfs/rpc_pipefs/nfs/clnt54
>
> No matter what we do, we are unable to get past the above error.
>
> Appreciate any help.
> Sumana
>

> Nov  4 13:01:27 rhel60sec02 rpc.svcgssd[10943]: finished handling null request
> Nov  4 13:01:27 rhel60sec02 rpc.svcgssd[10943]: entering poll

This says to me that the server's user-land (svcgssd) thinks it
succeeded, but then the kernel returns an error.  Kernel debugging
messages or a network trace might indicate why the server's kernel
returned an error.

K.C.
