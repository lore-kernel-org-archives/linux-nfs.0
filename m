Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33486 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbcC3VC5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2016 17:02:57 -0400
Received: by mail-io0-f171.google.com with SMTP id a129so83311281ioe.0
        for <linux-nfs@vger.kernel.org>; Wed, 30 Mar 2016 14:02:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHEt93VxL2Ysikgn8iZ_auWEWGdGkZ94LMBOa62wHDWMA@mail.gmail.com>
References: <CAN-5tyHEt93VxL2Ysikgn8iZ_auWEWGdGkZ94LMBOa62wHDWMA@mail.gmail.com>
Date: Wed, 30 Mar 2016 17:02:56 -0400
Message-ID: <CAN-5tyHrYxT-V2fms9vga_Ed+bQ3E+xk7A8fK0N1xYEzm_HtNg@mail.gmail.com>
Subject: Re: commit 7c2dad99d6 "Don't let the ctime override attribute barriers"
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 29, 2016 at 3:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> I think that patch introduces a problem. Since the checking for the
> change in ctime was removed by the commit it leads to (improper) cache
> invalidation in NFSv3.
>
> Test is write 10240bytes to the server then read it. Expectation is
> not to see read on the wire. In the test the write is spread over
> 3rpcs.
>
> On the 1nd reply
> fattr->gencount=33 nfsi->gencount=32 generation_counter=35
> On the 2nd reply
> fattr->gencount=34 nfsi->gencount=36 generation_counter=36
>
> In the code when processing 2nd reply,
> nfs_post_op_update_inode_force_wcc_locked() calls into
> nfs_inode_attrs_need_update() it determines that it doesn't need to
> update them (even though the size and the time have changed). so it
> doesn't call nfs_wcc_update_inode() so the inode->i_version doesn't
> get set to the ctime that was received in the 2nd reply.
>
> On the 3rd reply
> fattr->gencount=37 nfsi->gencount=36 generation_counter=37
>
> It leads to nfs_inode_attrs_need_update() returns 1 and in the
> nfs_update_inode() the difference in the ctimes leads to invalidation.
> fattr->gencount was update from nfs_writeback_update_node() ->
> nfs_post_op_update_inode_force_wcc() calling nfs_fattr_set_barrier().
>
> I'm not sure what appropriate values for "gencount" should have been.
> But if the check for nfs_ctime_need_update() was still there in
> nfs_inode_attrs_need_update() then the 2nd reply would have
> appropriately updated the i_version and not lead to invalidation.

Would like to add that this problem is not seen against the Linux
server because it doesn't send "before" attributes. So code doesn't
set the "pre_change_attr" which later doesn't make what's stored in
inode->i_version.

The problem also not seen for v4 because pre_change_attr is not gotten
from the "before" attributes but instead from the previous value in
inode->i_version which is then compared to the itself.

If reverting the problematic commit is not the solution, then how
about ignoring the "before" ctime attributes sent by the server. This
also helps with the out-of-order RPCs.

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 267126d..feca07f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -732,14 +732,12 @@ static int decode_wcc_attr(struct xdr_stream
*xdr, struct nfs_fattr *fattr)
  goto out_overflow;

  fattr->valid |= NFS_ATTR_FATTR_PRESIZE
- | NFS_ATTR_FATTR_PRECHANGE
  | NFS_ATTR_FATTR_PREMTIME
  | NFS_ATTR_FATTR_PRECTIME;

  p = xdr_decode_size3(p, &fattr->pre_size);
  p = xdr_decode_nfstime3(p, &fattr->pre_mtime);
  xdr_decode_nfstime3(p, &fattr->pre_ctime);
- fattr->pre_change_attr = nfs_timespec_to_change_attr(&fattr->pre_ctime);

  return 0;
 out_overflow:
