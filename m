Return-Path: linux-nfs-owner@vger.kernel.org
Received: from catastrophix.ugh.no ([178.79.162.34]:50232 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758316Ab2FZHYV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 03:24:21 -0400
Message-ID: <4FE96399.8040608@tomt.net>
Date: Tue, 26 Jun 2012 09:24:09 +0200
From: Andre Tomt <andre@tomt.net>
MIME-Version: 1.0
To: Bryan Schumaker <bjschuma@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        David Howells <dhowells@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
References: <20120601034114.GA9248@localhost> <4FDBF056.7040404@tomt.net>   <4FDCD3C7.5080503@tomt.net> <1339876739.8267.96.camel@lade.trondhjem.org>  <4FDEEF38.8030101@tomt.net> <1340026127.2451.7.camel@lade.trondhjem.org> <4FDF533A.2090901@netapp.com> <4FE215FE.6010406@netapp.com>
In-Reply-To: <4FE215FE.6010406@netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20. juni 2012 20:27, Bryan Schumaker wrote:
> Hi Andre,
>
> Have you had a chance to test my patch (below) yet?

I reverted from using keyutils yesterday, verified the problem had 
returned, then patched the same kernel with just this patch - so far its 
been running fine for 15 hours. Without the patch it would fall over 
within 1-2 hours.

So thumbs up from me

Sorry about the delay, once I got it working with keyutils I suddenly 
got very, very lazy ;-)
