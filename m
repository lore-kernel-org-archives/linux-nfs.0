Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693AbaG2Ukh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jul 2014 16:40:37 -0400
Message-ID: <53D806C1.9030206@RedHat.com>
Date: Tue, 29 Jul 2014 16:40:33 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: Re: nfs4_state_manager() vs. nfs_server_remove_lists()
References: <53D7EA62.3070204@RedHat.com> <CAHQdGtQ2DU4GnMXy=n9JQzUhGkEC=+UEM8NVm=MviBt0+RJzBA@mail.gmail.com>
In-Reply-To: <CAHQdGtQ2DU4GnMXy=n9JQzUhGkEC=+UEM8NVm=MviBt0+RJzBA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29/07/14 15:52, Trond Myklebust wrote:
> Let's just move up the test for "pos->rpc_ops != new->rpc_ops",
> "pos->cl_minorversion != new->cl_minorversion" and "pos->cl_proto !=
> new->cl_proto" so that they all happen before we try to test the value
> of cl_cons_state.
> As far as I can tell, all those values are guaranteed to be set as
> part of the struct nfs_client allocators, before we ever put the
> result on the cl_share_link list.

The check for 
   if (pos->cl_cons_state > NFS_CS_READY)

then right after that check is:

   if (pos->cl_cons_state != NFS_CS_READY)
         continue;

confuses me... Is the second check even needed? 

steved.
