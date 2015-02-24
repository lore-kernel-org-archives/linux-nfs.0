Return-Path: linux-nfs-owner@vger.kernel.org
Received: from discipline.rit.edu ([129.21.6.207]:19640 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752234AbbBXVTW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Feb 2015 16:19:22 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Anthony Messina <amessina@messinet.com>
Cc: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: soft lockup in the laundromat
References: <alpine.OSX.2.19.9992.1502181132520.80359@planck.local>
	<2527473.XPWgOc24eg@linux-ws1.messinet.com>
	<1524803.SbAy9NQUHI@ws1.m.messinet.com>
Date: Tue, 24 Feb 2015 16:12:40 -0500
Message-ID: <m2pp8zj9o7.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


We're running into something very similar.


fs/nfsd/nfs4state.c:

  1631  static void
  1632  __destroy_client(struct nfs4_client *clp)
  1633  {

    <snip>   

  1652          while (!list_empty(&clp->cl_revoked)) {
  1653                  dp = list_entry(reaplist.next, struct  nfs4_delegation, dl_recall_lru);
  1654                  list_del_init(&dp->dl_recall_lru);
  1655                  nfs4_put_stid(&dp->dl_stid);
  1656          }

  shouldn't that be:

  1653                  dp = list_entry(clp->cl_revoked.next, struct  nfs4_delegation, dl_recall_lru);

see commit 2d4a532d385f635ab8243b88db3136bb52a0bc29

  ?

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
