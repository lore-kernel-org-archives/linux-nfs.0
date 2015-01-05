Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003AbbAEN24 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 08:28:56 -0500
Message-ID: <54AA9196.1030908@RedHat.com>
Date: Mon, 05 Jan 2015 08:28:54 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Upstream nfs-utils not building on EL6 again
References: <E046B731-3611-4E1D-8C88-42134819B123@oracle.com>
In-Reply-To: <E046B731-3611-4E1D-8C88-42134819B123@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

On 01/02/2015 04:16 PM, Chuck Lever wrote:
> checking pkg-config is at least version 0.9.0... yes
> checking for TIRPC... no
> configure: error: libtirpc not found.
> make: *** No rule to make target `all'.  Stop.
> [cel@manet nfs-utils]$ sudo yum install libtirpc-devel
> Loaded plugins: security
> Setting up Install Process
> Package libtirpc-devel-0.2.1-10.el6.x86_64 already installed and latest version
> Nothing to do
> [cel@manet nfs-utils]$ 
> 
> After the following patch is reverted, the build is successful:
> 
> commit 853406302d7a506605ce64592e77fd722b5e23d5
> Author:     Yann E. MORIN <yann.morin.1998@free.fr>
> Date: Sat Dec 13 10:16:38 2014 -0500
> 
>     configure: use pkg-config to find libtirpc
> 
> Perhaps the new "[libtirpc >= 0.2.4]” check is too aggressive.
No... The problem is litbtirpc does not register with the pkg-config
program. So "pkg-config --exists libtirpc" fails even when libtirpc 
is installed. 

I would like to maintain being able to compile upstream code on 
legacy OSs so I'm looking into how painful it will be to
revert this patch... 

steved.

