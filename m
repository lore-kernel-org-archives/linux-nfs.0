Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:28699 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754366AbbCDOGT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2015 09:06:19 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
References: <1411654543.3044.24.camel@leira.trondhjem.org>
	<28059.1411650278@warthog.procyon.org.uk>
	<6150.1424947519@warthog.procyon.org.uk>
	<1424964991.10136.8.camel@primarydata.com>
Date: Wed, 04 Mar 2015 09:06:18 -0500
In-Reply-To: <1424964991.10136.8.camel@primarydata.com> (Trond Myklebust's
	message of "Thu, 26 Feb 2015 10:36:31 -0500")
Message-ID: <m2h9u06en9.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

   Some feedback on patches you have in your devel branch. We've been
  seeing a problem where the server/client conversation after a few
  hours (usually after we leave the environment overnight) becomes
  nothing but sequence operations back and forth with the server
  continually asserting SEQ4_STATUS_RECALLABLE_STATE_REVOKED. The
  client is in an unusable state which can rapidly degrade to a
  lock or crash. (We've seen this with both 3.18.8 and RHEL7
  3.10.0-123.20.1.el7.x86_64)

  Cherry-picking these:

  9f0f8e12c48e4bb89192a0de876c77dc1fbfaa75
    NFSv4: Pin the superblock while we're returning the delegation

  ade04647dd56881e285983af3db702d56ee97e86
    NFSv4: Ensure we honour NFS_DELEGATION_RETURNING in nfs_inode_set_delegation()

  b04b22f4ca691280f0ab3f77954f5a21500881e7
    NFSv4: Ensure that we don't reap a delegation that is being returned

  ec3ca4e57e00d52ff724b0ae49f4489667a9c311
    NFSv4: Ensure we skip delegations that are already being returned

  Plus this:

  ea7c38fef0b774a5dc16fb0ca5935f0ae8568176
    NFSv4: Ensure we reference the inode for return-on-close in delegreturn

  And applying to 3.18.8 has eliminated this from manifesting for at
  least last night.

  Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
