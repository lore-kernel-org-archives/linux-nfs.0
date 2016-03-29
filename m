Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34418 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbcC2Try (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2016 15:47:54 -0400
Received: by mail-io0-f178.google.com with SMTP id e3so38615085ioa.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Mar 2016 12:47:54 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 29 Mar 2016 15:47:53 -0400
Message-ID: <CAN-5tyHEt93VxL2Ysikgn8iZ_auWEWGdGkZ94LMBOa62wHDWMA@mail.gmail.com>
Subject: commit 7c2dad99d6 "Don't let the ctime override attribute barriers"
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think that patch introduces a problem. Since the checking for the
change in ctime was removed by the commit it leads to (improper) cache
invalidation in NFSv3.

Test is write 10240bytes to the server then read it. Expectation is
not to see read on the wire. In the test the write is spread over
3rpcs.

On the 1nd reply
fattr->gencount=33 nfsi->gencount=32 generation_counter=35
On the 2nd reply
fattr->gencount=34 nfsi->gencount=36 generation_counter=36

In the code when processing 2nd reply,
nfs_post_op_update_inode_force_wcc_locked() calls into
nfs_inode_attrs_need_update() it determines that it doesn't need to
update them (even though the size and the time have changed). so it
doesn't call nfs_wcc_update_inode() so the inode->i_version doesn't
get set to the ctime that was received in the 2nd reply.

On the 3rd reply
fattr->gencount=37 nfsi->gencount=36 generation_counter=37

It leads to nfs_inode_attrs_need_update() returns 1 and in the
nfs_update_inode() the difference in the ctimes leads to invalidation.
fattr->gencount was update from nfs_writeback_update_node() ->
nfs_post_op_update_inode_force_wcc() calling nfs_fattr_set_barrier().

I'm not sure what appropriate values for "gencount" should have been.
But if the check for nfs_ctime_need_update() was still there in
nfs_inode_attrs_need_update() then the 2nd reply would have
appropriately updated the i_version and not lead to invalidation.
