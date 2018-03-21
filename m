Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:8090 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751608AbeCUOt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Mar 2018 10:49:59 -0400
Subject: Re: [md PATCH 0/4] Minor 'cred' improvements prepare for NFS
 conversion
To: NeilBrown <neilb@suse.com>, David Howells <dhowells@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>
CC: NFS <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>
References: <151737571564.14845.2874586176125198504.stgit@noble>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <2ae93c98-108e-c687-4e21-f346515f5f66@Netapp.com>
Date: Wed, 21 Mar 2018 10:49:49 -0400
MIME-Version: 1.0
In-Reply-To: <151737571564.14845.2874586176125198504.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/31/2018 12:15 AM, NeilBrown wrote:
> Hi,
>  NFS and SUNRPC have an internal "rpc_cred" which plays two distinct
>  roles, one of which is much the same as 'struct cred' (which didn't
>  exist when rpc_cred was created).
>  I want to replace that usage of rpc_cred with 'struct cred'.
>  Doing so requires some minor improvements to cred.c and cred.h as
>  follows.
> 
>  It isn't clear to me who "maintains" cred.c and cred.h, so I'm hoping
>  that Andrew Morton will take these (if no-one complains).
>  Alternately if I got one or two credible "Acked-by"s, they could go
>  upstream through the NFS tree when the rest of the patches are ready.

Neil sent these patches out a while ago, and I haven't heard any acks for them yet.  Does anybody have a problem with me taking them through the NFS tree for 4.17?

Anna

> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (4):
>       cred: add cred_fscmp() for comparing creds.
>       cred: add get_cred_rcu()
>       cred: export get_task_cred().
>       cred: allow get_cred() and put_cred() to be given NULL.
> 
> 
>  include/linux/cred.h |   26 ++++++++++++++++++----
>  kernel/cred.c        |   58 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 78 insertions(+), 6 deletions(-)
> 
> --
> Signature
> 
