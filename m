Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53568 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab1G2SPH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 14:15:07 -0400
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
From: Eric Dumazet <eric.dumazet@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Greg Banks <gnb@fastmail.fm>, Christoph Hellwig <hch@infradead.org>,
        NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
In-Reply-To: <20110729165345.GM23194@fieldses.org>
References: <20110729153207.17af3085@notabene.brown>
	 <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop>
	 <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org>
	 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
	 <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
	 <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Jul 2011 20:15:03 +0200
Message-ID: <1311963303.2873.9.camel@edumazet-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Le vendredi 29 juillet 2011 à 12:53 -0400, J. Bruce Fields a écrit :

> (Annoying fact: some initscripts stop nfsd using a rough equivalent of
> "killall nfsd".  So the name of the threads is arguably ABI.  I think
> those initscripts are nuts and deserve what they get, but that may be
> because I'm forgetting the reason they do that.)
> 

Yes, it seems we cant change then...

I tried on a RHEL4 distro and "service nfs stop" could not stop my nfsd
threads if I changed their names as described.

Next, I am going to try nfsd/...  

By the way, any idea why after "service nfs stop" I cannot unload sunrpc
module ?

# lsmod
Module                  Size  Used by
nfsd                  285597  3 
lockd                  76103  1 nfsd
auth_rpcgss            45002  1 nfsd
sunrpc                231915  6 nfsd,lockd,auth_rpcgss
exportfs                3813  1 nfsd


