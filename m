Return-Path: linux-nfs-owner@vger.kernel.org
Received: from maui.cs.washington.edu ([128.208.5.86]:35153 "EHLO
	maui.cs.washington.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab2JUUQT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2012 16:16:19 -0400
Date: 21 Oct 2012 13:15 PDT
From: Jan Sanislo <oystr@cs.washington.edu>
Subject: Re: nfsidmap and NFS key timeouts and quotas
To: jlayton@redhat.com
Cc: linux-nfs@vger.kernel.org
Message-Id: <1350849102/oystr@maui.cs.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Nice catch. The rpc.idmapd downcall handler does this already in the
> kernel:
>
>        ret = nfs_idmap_read_and_verify_message(&im,
>                        &idmap->idmap_upcall_data->idmap_msg,
>                        cons->key, cons->authkey);
>        if (ret >= 0) {
>                key_set_timeout(cons->key, nfs_idmap_cache_timeout);
>                ret = mlen;
>        }
>
> ...where nfs_idmap_cache_timeout defaults to 600 and is tunable via
> module parameter. Might it be better for consistency's sake to make the
> keys API upcall do the same thing?

Yes, that certainly works.  But I wonder whether it's conspicuous
absence on that call path wasn't intentional, with the intent being
to make request-keys/nfsidmap the single stop for setting NFS key
timeouts.  If the key_set_timeout call moves into the kernel then
it would be useful to remove the nfsidmap code and docs regarding
key timeouts -- otherwise things might get a littel confusing.

>> 
>> Finally, the key LRU discard patch: http://lkml.org/lkml/2012/3/28/144
>> looks promising for managing key quotas.  But it only seems to be
>> invoked when a key is linked into a destination keyring. fs/nfs/idmap.c
>> uses a call to security/keys/request_key which by default provides an
>> NULL dest_keyring. Might consider changing the request_key call in nfs/idmap.c
>> to request_key_and_link (although I don't pretend to know all the
>> implications of making such a change).

> Have you tested that? I thought these keys did end up in a keyring
> (hence the whole override_creds/revert_creds song-and-dance). I haven't
> looked closely at the LRU discard stuff though, so you may be correct
> here...

Tested only in the sense that, after cranking down the root key quota to
20 or so, the LRU code does not seem to be working for NFS keys.  I
should probably investigate that further.  I was hoping I would get
a response of "yeah, we know it's not quite right" or "you haven't got
things configured correctly".

Thanks for the help.

