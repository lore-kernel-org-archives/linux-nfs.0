Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.20]:61981 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755199Ab3EAUWj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 May 2013 16:22:39 -0400
Received: from mailout-de.gmx.net ([10.1.76.24]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0LqoQe-1U3VjI1YGo-00eIYA for
 <linux-nfs@vger.kernel.org>; Wed, 01 May 2013 22:22:38 +0200
Message-ID: <51817989.6000006@gmx.de>
Date: Wed, 01 May 2013 22:22:33 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Pseudoflavor 390004 not found!
References: <5180DBCF.8070303@gmx.de> <1367415199.4189.6.camel@leira.trondhjem.org>
In-Reply-To: <1367415199.4189.6.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/01/2013 03:33 PM, Myklebust, Trond wrote:
> We should just disable the above warnings.
> 
> Note that even if the lease negotiation uses krb5i, the actual mount
> will continue to use whatever flavour you specify in your 'sec=' mount
> option (or it will use NFSv4 security negotiation) when doing operations
> on the filesystem.
> 
> The attached patch will turn off those messages for you.
> 
Ah - thx for explanation.

I just applied the patch manually, my patch command was indisposed for
some reasons to apply it against current git.

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
