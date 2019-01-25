Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3429C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 14:02:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A8BE6218CD
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 14:02:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728536AbfAYOCr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 09:02:47 -0500
Received: from nautica.notk.org ([91.121.71.147]:37118 "EHLO nautica.notk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728238AbfAYOCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Jan 2019 09:02:47 -0500
Received: by nautica.notk.org (Postfix, from userid 1001)
        id AB79CC009; Fri, 25 Jan 2019 15:02:44 +0100 (CET)
Date:   Fri, 25 Jan 2019 15:02:29 +0100
From:   Dominique Martinet <asmadeus@codewreck.org>
To:     linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, Hou Tao <houtao1@huawei.com>
Cc:     linux-nfs@vger.kernel.org
Subject: inode_add/set_bytes and i_blocks, dangerous for small files?
Message-ID: <20190125140229.GA5119@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

We've been discussing how i_blocks is set because of integrity problems
on 32bit smp and noticed some problems with v9fs as described here[1]; I
could use some help to sort this out.

[1] https://marc.info/?l=linux-fsdevel&m=154834116110451&w=2

Long story short, with 9p and caching activated (e.g. -o cache=fscache),
creating a new file and writing a few bytes will start at 0 and
increment blocks count with inode_add_bytes; so a file with e.g. 200
bytes of data will have i_blocks = 0 and i_bytes = 200.


(added linux-nfs@ in Cc because there is a small, few seconds window
where I can reproduce a similar issue on nfs:
$ echo foo > bar; stat -c %b bar; sleep 3; stat -c %b bar
0
8
with a 4.14.87 knfsd and 4.19.15-300.fc29 client, nfs 4.2, both x86_64,
no export option or explicit client option.
I'm honestly not sure we care about this single-client problem for a few
seconds but figured it's worth reporting)



I believe that from the first byte onwards there should be at least one
block in i_blocks:
 - that's how all the local filesystems I know work, when you write a
single byte you're actualy reserving a few blocks and that is the number
reported with st_blocks ;
 - tools like du show the file as empty ;
 - and most importantly there still are some tools looking at i_blocks
and not doing any read at all if i_blocks is zero (e.g. gnu tar with
some options, see code[2]); I know there's been some discussions around
this for btrfs but I'm not sure how these ended.

[2] http://git.savannah.gnu.org/cgit/tar.git/tree/src/sparse.c#n273


There also is a weird related behaviour since we use inode_add_bytes is
that if you start with an existing file, it'll initially report the
right number of blocks but then the evolution is 100%
client-write-driven e.g. you start with a file with 200 bytes and 8
blocks; then write another 1k and stat will report 10 blocks when the fs
really still only has 8 blocks.
I believe this does not matter as much as this probably doesn't cause
much problem except du confusion.


For what it's worth, cache=none doesn't have the problem because every
stat will send a getattr to the server, so it'd always report the number
of blocks as seen on the server.



Anyway, how is one supposed to use inode_set_bytes/add_bytes for that?
Should we remove our uses of inode_add_bytes ?

Given 9p does not do quota on the client (if required the server can
enforce it), do we care about i_bytes at all?

For cached mounts I'd be open to blatanlty lie and always print the
rounded up value of block based on i_size (e.g. i_size + 511 >> 9 and
i_bytes to 0) thus ignoring what the server report; I don't see much way
around that to have something consistent...


Thanks,
-- 
Dominique Martinet | Asmadeus
