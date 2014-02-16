Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.skyhub.de ([78.46.96.112]:54165 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbaBPRfu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Feb 2014 12:35:50 -0500
Date: Sun, 16 Feb 2014 18:35:47 +0100
From: Borislav Petkov <bp@alien8.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        John <da_audiophile@yahoo.com>, lkml <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "mlindner@marvell.com" <mlindner@marvell.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Message-ID: <20140216173547.GC25047@pd.tnic>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>
 <20140215203015.GA4528@pd.tnic>
 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <20140215232508.GB4508@pd.tnic>
 <1392571653.44773.4.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1392571653.44773.4.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 16, 2014 at 12:27:33PM -0500, Trond Myklebust wrote:
> Please ensure that you post to the linux-nfs@vger.kernel.org when
> reporting NFS and RPC related bugs.

Sorry, get_maintainer.pl gave it too but far down in an already too
long list and I wasn't sure who to spam so I picked up supporter and
maintainer:

$ ./scripts/get_maintainer.pl -f net/sunrpc/auth_gss/auth_gss.c
"J. Bruce Fields" <bfields@fieldses.org> (supporter:KERNEL NFSD, SUNR...,commit_signer:3/26=12%)
Trond Myklebust <trond.myklebust@primarydata.com> (maintainer:NFS, SUNRPC, AND...,commit_signer:24/26=92%,authored:14/26=54%,added_lines:394/475=83%,removed_lines:189/215=88%)
"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING [GENERAL])
Andy Adamson <andros@netapp.com> (commit_signer:3/26=12%,authored:3/26=12%,added_lines:56/475=12%)
Chuck Lever <chuck.lever@oracle.com> (commit_signer:3/26=12%,authored:3/26=12%)
Jeff Layton <jlayton@redhat.com> (commit_signer:3/26=12%,authored:3/26=12%,removed_lines:19/215=9%)
linux-nfs@vger.kernel.org (open list:KERNEL NFSD, SUNR...)
netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
linux-kernel@vger.kernel.org (open list)

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
