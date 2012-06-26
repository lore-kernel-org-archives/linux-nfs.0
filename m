Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17169 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756792Ab2FZMnA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jun 2012 08:43:00 -0400
Message-ID: <4FE9AE52.10800@netapp.com>
Date: Tue, 26 Jun 2012 08:42:58 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Andre Tomt <andre@tomt.net>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        David Howells <dhowells@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
References: <20120601034114.GA9248@localhost> <4FDBF056.7040404@tomt.net>   <4FDCD3C7.5080503@tomt.net> <1339876739.8267.96.camel@lade.trondhjem.org>  <4FDEEF38.8030101@tomt.net> <1340026127.2451.7.camel@lade.trondhjem.org> <4FDF533A.2090901@netapp.com> <4FE215FE.6010406@netapp.com> <4FE96399.8040608@tomt.net>
In-Reply-To: <4FE96399.8040608@tomt.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/26/2012 03:24 AM, Andre Tomt wrote:
> On 20. juni 2012 20:27, Bryan Schumaker wrote:
>> Hi Andre,
>>
>> Have you had a chance to test my patch (below) yet?
> 
> I reverted from using keyutils yesterday, verified the problem had returned, then patched the same kernel with just this patch - so far its been running fine for 15 hours. Without the patch it would fall over within 1-2 hours.
> 
> So thumbs up from me
> 
> Sorry about the delay, once I got it working with keyutils I suddenly got very, very lazy ;-)

Cool, thanks for checking this!  You can go back to whichever method you like better now :).

- Bryan

