Return-Path: linux-nfs-owner@vger.kernel.org
Received: from catastrophix.ugh.no ([178.79.162.34]:38386 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802Ab2FRJE7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jun 2012 05:04:59 -0400
Message-ID: <4FDEEF38.8030101@tomt.net>
Date: Mon, 18 Jun 2012 11:04:56 +0200
From: Andre Tomt <andre@tomt.net>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>,
        David Howells <dhowells@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
References: <20120601034114.GA9248@localhost> <4FDBF056.7040404@tomt.net>  <4FDCD3C7.5080503@tomt.net> <1339876739.8267.96.camel@lade.trondhjem.org>
In-Reply-To: <1339876739.8267.96.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16. juni 2012 21:59, Myklebust, Trond wrote:
> It looks to me as if the legacy upcall code is assuming that there can
> be no more than 1 upcall at a time: there is only a single
> idmap->idmap_key_cons, which gets assigned in nfs_idmap_legacy_upcall
> and then read in idmap_pipe_downcall.
>
> Bryan, can you look into this? I suspect that we need a mutex or
> something like that (for the legacy upcall case only) to ensure that
> nobody overwrites the idmap->idmap_key_cons while an upcall is in
> progress.
>
> Andre, if you want idmapper scalability, then you should rather use the
> new idmapper upcall. You need a recent version of the nfs-utils package,
> the keyutils package, and they you should add an 'id_resolver' line
> to /etc/request-keys.conf as per the nfsidmap manpage.

Indeed, using keyutils did avoid the crashes here, 40 hours and counting.

Are there any downsides of having keyutils w/ id_resolver on by default 
in a distribution? Would it break older kernels or nfs-utils (just not 
getting used is fine, obviously)?
