Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:48285 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756991Ab0EYD4E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 23:56:04 -0400
Message-ID: <4BFB4A51.8040405@panasas.com>
Date: Tue, 25 May 2010 06:56:01 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: redshield88888 <redshield88888@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Where is the spnfsd in ?
References: <loom.20100525T040243-971@post.gmane.org>
In-Reply-To: <loom.20100525T040243-971@post.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On May. 25, 2010, 5:06 +0300, redshield88888 <redshield88888@gmail.com> wrote:
> I using pnfs-anebled kernel and nfs-utils from this repo
> http://steved.fedorapeople.org/repos/pnfs/12/x86_64/rpms/
> 
> The kernel just working and installation of the nfs-util
> using rpm has succeeded. But I couldn't find "spnfsd".
> 
> Where? Should I build the nfs-utils from sources ?

It's in git://linux-nfs.org/~bhalevy/pnfs-nfs-utils
and yes, you should build from source.
There are quite a few development packages you might need
to install for that, please see the wiki topic below:

http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd
"Kernel and nfs-utils compilation"

Benny

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
