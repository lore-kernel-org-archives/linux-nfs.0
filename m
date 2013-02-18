Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:27255 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600Ab3BRVQO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 16:16:14 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Kernels 3.7 and newer break rpc.gssd -n
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi>
Date: Mon, 18 Feb 2013 16:16:05 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <73594034-4F9D-4DA6-A979-1E2745BCDF05@oracle.com>
References: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 13, 2013, at 10:29 AM, Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

> I've been using kerberized nfs4 mounts without machine credentials for 
> quite some time by running rpc.gssd with the -n option. This has 
> resulted rpc.gssd in using ccache in /tmp/krb5cc_0 when doing the mount 
> instead of machine credentials. This functionality seems to break when 
> using kernel 3.7 or newer. 3.6.11 and earlier work like expected.
> 
> The use case for this is diskless workstations that do not have machine 
> credentials stored on them as they have no secure storage medium. When a 
> user logs in, the home directory is mounted using the user's credentials 
> only.
> 
> Steps to reproduce the problem:
> 
> # kinit user (this creates /tmp/krb5cc_0)
> # rpc.gssd -f -n -vvvv
> # mount -t nfs4 -o sec=krb5 server.example.org:/home /mnt
> 
> The mount works when using kernel 3.6.11 or earlier and fails on 3.7-rc1 
> or later. Testing was done on Ubuntu 12.04 and 12.10 using Ubuntu kernels
> and kernel.org kernels (up to 3.8-rc7) with similar results.
> 
> nfs-utils versions 1.2.5 and the latest version from git master head 
> (git://linux-nfs.org/nfs-utils) behave the same way.

Reproduced.  Not clear yet if this is a kernel regression or a latent gssd bug.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




