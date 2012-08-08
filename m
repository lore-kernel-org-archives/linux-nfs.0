Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:38725 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757369Ab2HHH60 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 03:58:26 -0400
Date: Wed, 8 Aug 2012 09:58:13 +0200
From: Zdenek Salvet <salvet@ics.muni.cz>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Lukas Hejtmanek <xhejtman@ics.muni.cz>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 backchannel authentication
Message-ID: <20120808075813.GW604@horn.ics.muni.cz>
Reply-To: salvet@ics.muni.cz
References: <20120806135517.GS25979@ics.muni.cz>
 <20120807154114.GA21460@fieldses.org>
 <1344355148.5781.31.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1344355148.5781.31.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 07, 2012 at 18:12:11 +0200, Lukas Hejtmanek wrote:
> well, ok, thanks for anwsers. However, it seems that while NFS server's name
> is server-home.domain.com (floating name), and true hostname is
> server1.domain.com, it does not matter that callback is authenticated with
> server1.domain.com instead of server-home.domain.com.
> 
> Is this expected? Or is it a bug?

It does matter, callback client name must match the name NFS client uses
for server. 

We don't see any hard failures because NFS protocol does
not depend on working callback RPCs, but no delegations are granted
(we had nfs-kernel-server package installed on clients before which masked
the bug).

> I would suppose that client rejects authentication of the backchannel from 
> server that sends nfs/server1.domain.com KRB principal instead of expected
> nfs/server-home.domain.com. 
> 
> The client mounts server-home.domain.com with sec=krb5i. Using debugs I can
> see that the server picks up nfs/server1.domain.com key from /etc/krb5.keytab
> and the client seems to be happy with that (context is established).

Server name is checked later, when the context is used for actual callback RPC.

Best regards,

Zdenek Salvet                                              salvet@ics.muni.cz 
Institute of Computer Science of Masaryk University, Brno, Czech Republic
and CESNET, z.s.p.o., Prague, Czech Republic
Phone: ++420-549 49 6534                           Fax: ++420-541 212 747
----------------------------------------------------------------------------
      Teamwork is essential -- it allows you to blame someone else.

