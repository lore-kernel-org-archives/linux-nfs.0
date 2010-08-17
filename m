Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25553 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736Ab0HQXQx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 19:16:53 -0400
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C68EDAE.5000201@cn.fujitsu.com>
References: <4C592F85.8070308@cn.fujitsu.com>
	 <4C59306A.9090302@cn.fujitsu.com>
	 <1280925913.3011.23.camel@heimdal.trondhjem.org>
	 <4C5A213F.9000506@cn.fujitsu.com>
	 <1281013423.2948.1.camel@heimdal.trondhjem.org>
	 <4C5B8B48.4050008@cn.fujitsu.com>
	 <1281101448.3586.11.camel@heimdal.trondhjem.org>
	 <4C68EDAE.5000201@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Aug 2010 19:16:52 -0400
Message-ID: <1282087012.18385.30.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-08-16 at 15:50 +0800, Bian Naimeng wrote:
> >>>>>> We should clear NFS_DELEGATED_STATE bit for inode->open_states after return delegation.
> 
>  ... snip ...
> 
> >> +
> >> +	list_for_each_entry(state, &nfsi->open_states, inode_states) {
> >> +		clear_bit(NFS_DELEGATED_STATE, &state->flags);
> >> +	}
> >> +
> >>  	spin_unlock(&inode->i_lock);
> >> -	return 0;
> >> +	return err;
> >>  }
> >>  
> > 
> > I still don't see why this should be necessary. In the case of a server
> > reboot or network partition, the state recovery thread ought to be
> > taking care of this for us.
> > 
> 
>    A open state can be found at nfsi->open_states and owner->so_states always, but
>   it not be found at nfsi->open_files until we call nfs4_intent_set_file.
> 
>    At _nfs4_do_open, we will invoke nfs4_return_incompatible_delegation to return a 
>   delegation,  a open stateid which set NFS_DELEGATED_STATE bit may not be found at
>   nfsi->open_files, but it still at nfsi->open_states, so we do not clear 
>   NFS_DELEGATED_STATE bit for it.
> 
>    Then _nfs4_do_open will find it by nfs4_get_open_state, and we still use it
>   as a delegation, some error will occur.
> 

OK. I see agree that is a race, but AFAICS, your fix means that we end
up with an nfs_state structure that has cleared NFS_DELEGATED_STATE, but
that did not recover its open stateid.

Cheers
  Trond
