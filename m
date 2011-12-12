Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43953 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab1LLTo2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 14:44:28 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so1785048eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 11:44:27 -0800 (PST)
Message-ID: <4EE65996.6070901@tonian.com>
Date: Mon, 12 Dec 2011 21:44:22 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Tigran Mkrtchyan <kofemann@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATH v3 0/5] nfsd41: current state id processing
References: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-11 18:41, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> This is yet another update of current stateid handling

Thanks!  It looks must better every iteration!

> 
> currently tested to work in a single compound:
> 
>   OPEN+CLOSE
>   LOCK+WRITE+LOCKU+CLOSE
> 
> On the way ( not tested yet ):
>  OPEN+LAYOUTGET
> 
> TODO:
>   dispose current stateid on operations which provide CFH, but do not provide stateid.
> 
> Internals:
>   1. struct nfsd4_compound_state contains pointer to current stateid
>   2. operations marked to PROVIDE, CONSUME or CLEAR current stateid. 

Does the flag add anything beyond simply implementing
the respective method?

Is CLEAR just a specific form of PROVIDE?

[more comments in reply to the actual patches...]

Thanks,

Benny

>   3. during compound processing before operation execution current stateid copied into
>    operations stateid if it's equal to corresponding value ( 0, 1).
>   4. after operation execution current stateid changed to:
>      a) point to stateid of last operation
>      or
>      b) point to NULL, if operation is marked to do so.
> 
> 
> Probably all patches have to be squashed into a single one before merged
> as none of the changes makes sense without others.
> 
> Tigran.
> 
> Tigran Mkrtchyan (5):
>   nfsd41: handle current stateid in open and close
>   nfsd41: handle current stateid on lock and locku
>   nfsd41: update operations's stateid iff current stateid is set
>   nfsd41: consume current stateid on read and write
>   nfsd41: use pinter to current stateid to avoid extra copy
> 
>  fs/nfsd/current_stateid.h |   22 +++++++++++++++
>  fs/nfsd/nfs4proc.c        |   55 +++++++++++++++++++++++++++++-------
>  fs/nfsd/nfs4state.c       |   67 +++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/xdr4.h            |    1 +
>  4 files changed, 134 insertions(+), 11 deletions(-)
>  create mode 100644 fs/nfsd/current_stateid.h
> 
