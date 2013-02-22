Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755645Ab3BVNzt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 08:55:49 -0500
Message-ID: <512778E0.1050708@RedHat.com>
Date: Fri, 22 Feb 2013 08:55:44 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.2: Added NFS v4.2 support to the NFS client
References: <1361522832-11177-1-git-send-email-steved@redhat.com> <1361522832-11177-2-git-send-email-steved@redhat.com> <20130222131101.GA12862@umich.edu>
In-Reply-To: <20130222131101.GA12862@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/02/13 08:11, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   +config NFS_V4_2
>   +	bool "NFS client support for NFSv4.2"
>   +	depends on NFS_V4_1
>   +	select NFS_V4_SECURITY_LABEL
>   +	help
>   +	  This option enables support for minor version 1 of the NFSv4 protocol
>   +	  in the kernel's NFS client.
>   +
>   +	  If unsure, say N.
>   +
> 
> Shouldn't that be "enables support for minor version 2..."?
> 
Yes it should be... thanks!

steved.
