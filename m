Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753472Ab1DFRDI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 13:03:08 -0400
Message-ID: <4D9C9CCA.1080103@RedHat.com>
Date: Wed, 06 Apr 2011 13:03:06 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Karel Zak <kzak@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: mount.nfs libmount support (v3)
References: <1300111108-13137-1-git-send-email-kzak@redhat.com>
In-Reply-To: <1300111108-13137-1-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 03/14/2011 09:58 AM, Karel Zak wrote:
> This is the third version of the mount.nfs with libmount support. The code
> depends on util-linux >= v2.19 (e.g. Fedora 15).
> 
> v3:
>   - call umount_error() on mount(2) error
> 
> v2:
>   - move nfs_umount_do_umnt() to network.c
>   - use union nfs_sockaddr
>   - add missing GPL address paragraph
>   - use abstract function the storing and retrieval mount options
>   - use "static const" for struct option
>   - use "strncmp() == 0" everywhere
> 
> 
Committed... 

I also enabled the libmount code in the Fedora rawhide builds,
at least for now.... 

steved.
