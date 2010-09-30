Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63252 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756500Ab0I3UaI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 16:30:08 -0400
Message-ID: <4CA4F34D.7020105@panasas.com>
Date: Thu, 30 Sep 2010 22:30:05 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs:  compile error in blocklayout code
References: <4CA4ED68.3090806@RedHat.com> <20100930202256.GA6462@merit.edu>
In-Reply-To: <20100930202256.GA6462@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-30 22:22, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   I needed to make the following change to get the
>   block layout code to compile in a Fedora build 
>   environment.
> 
>   -#include <../pnfs.h>
>   +#include "../pnfs.h"
> 
> Not a comment on your fix, which looks correct, but there is a bit of
> disturbing asymmetry here.  The file layout source files are named
> nfs4filelayout*.[ch] and live in fs/nfs, but object and block layout are
> named {object,block}layout*.[ch] and live in fs/nfs/*layout.

That's true. NFSv4.1 files layout is considered in the linux
implementation as a first class citizen, as it's "native" to the
nfs client protocol, while other layout drivers are external
to the nfs client module.

That said, they could be pulled into the fs/nfs directory 
but this may just clutter it.
To keep things symmetrical I'd be inclined to make the files layout
driver similar to all other layout driver and not vice versa.

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
