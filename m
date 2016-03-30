Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35982 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbcC3Vpu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2016 17:45:50 -0400
Received: by mail-oi0-f46.google.com with SMTP id r187so34371464oih.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 Mar 2016 14:45:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHrYxT-V2fms9vga_Ed+bQ3E+xk7A8fK0N1xYEzm_HtNg@mail.gmail.com>
References: <CAN-5tyHEt93VxL2Ysikgn8iZ_auWEWGdGkZ94LMBOa62wHDWMA@mail.gmail.com>
	<CAN-5tyHrYxT-V2fms9vga_Ed+bQ3E+xk7A8fK0N1xYEzm_HtNg@mail.gmail.com>
Date: Wed, 30 Mar 2016 17:45:49 -0400
Message-ID: <CAHQdGtTxkUjQ+yLip_DrZB305U3NsZp8ZQ3VvkqgJhACPPM+Bg@mail.gmail.com>
Subject: Re: commit 7c2dad99d6 "Don't let the ctime override attribute barriers"
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 30, 2016 at 5:02 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Tue, Mar 29, 2016 at 3:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> I think that patch introduces a problem. Since the checking for the
>> change in ctime was removed by the commit it leads to (improper) cache
>> invalidation in NFSv3.
>>
>> Test is write 10240bytes to the server then read it. Expectation is
>> not to see read on the wire. In the test the write is spread over
>> 3rpcs.
>>
>> On the 1nd reply
>> fattr->gencount=33 nfsi->gencount=32 generation_counter=35
>> On the 2nd reply
>> fattr->gencount=34 nfsi->gencount=36 generation_counter=36
>>
>> In the code when processing 2nd reply,
>> nfs_post_op_update_inode_force_wcc_locked() calls into
>> nfs_inode_attrs_need_update() it determines that it doesn't need to
>> update them (even though the size and the time have changed). so it
>> doesn't call nfs_wcc_update_inode() so the inode->i_version doesn't
>> get set to the ctime that was received in the 2nd reply.
>>
>> On the 3rd reply
>> fattr->gencount=37 nfsi->gencount=36 generation_counter=37
>>
>> It leads to nfs_inode_attrs_need_update() returns 1 and in the
>> nfs_update_inode() the difference in the ctimes leads to invalidation.
>> fattr->gencount was update from nfs_writeback_update_node() ->
>> nfs_post_op_update_inode_force_wcc() calling nfs_fattr_set_barrier().
>>
>> I'm not sure what appropriate values for "gencount" should have been.
>> But if the check for nfs_ctime_need_update() was still there in
>> nfs_inode_attrs_need_update() then the 2nd reply would have
>> appropriately updated the i_version and not lead to invalidation.
>
> Would like to add that this problem is not seen against the Linux
> server because it doesn't send "before" attributes. So code doesn't
> set the "pre_change_attr" which later doesn't make what's stored in
> inode->i_version.
>
> The problem also not seen for v4 because pre_change_attr is not gotten
> from the "before" attributes but instead from the previous value in
> inode->i_version which is then compared to the itself.
>
> If reverting the problematic commit is not the solution, then how
> about ignoring the "before" ctime attributes sent by the server. This
> also helps with the out-of-order RPCs.

Why bother doing that on the client? These attributes aren't mandatory
to send...

Cheers
  Trond
