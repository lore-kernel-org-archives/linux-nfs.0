Return-Path: <SRS0=EpnZ=T5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1014C28CC0
	for <linux-nfs@archiver.kernel.org>; Wed, 29 May 2019 15:08:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8879523B88
	for <linux-nfs@archiver.kernel.org>; Wed, 29 May 2019 15:08:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726323AbfE2PIq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 29 May 2019 11:08:46 -0400
Received: from mx1.redhat.com ([209.132.183.28]:58688 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725914AbfE2PIq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 May 2019 11:08:46 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B2E7319CF89
        for <linux-nfs@vger.kernel.org>; Wed, 29 May 2019 15:08:46 +0000 (UTC)
Received: from [10.10.66.3] (ovpn-66-3.rdu2.redhat.com [10.10.66.3])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 7BC385D704
        for <linux-nfs@vger.kernel.org>; Wed, 29 May 2019 15:08:46 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: client lookup_revalidate bug
Date:   Wed, 29 May 2019 11:08:45 -0400
Message-ID: <D4DAB8F2-CAA7-4BC3-B0A0-4EAF5E9DE261@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 29 May 2019 15:08:46 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hey, here's an interesting one, this seems wrong:

[root@fedora27_c2_v5 ~]# mkdir /mnt/one
[root@fedora27_c2_v5 ~]# mkdir /mnt/two
[root@fedora27_c2_v5 ~]# mount -t nfs -ov4,noac,sec=sys,nosharecache 
192.168.122.50:/exports /mnt/one
[root@fedora27_c2_v5 ~]# mount -t nfs -ov4,noac,sec=sys,nosharecache 
192.168.122.50:/exports /mnt/two
[root@fedora27_c2_v5 ~]# mkdir /mnt/one/A
[root@fedora27_c2_v5 ~]# mkdir /mnt/one/B
[root@fedora27_c2_v5 ~]# touch /mnt/one/A/foo
[root@fedora27_c2_v5 ~]# cat /mnt/two/A/foo
[root@fedora27_c2_v5 ~]# mv /mnt/two/A/foo /mnt/two/B/foo
[root@fedora27_c2_v5 ~]# mv /mnt/one/B/foo /mnt/one/A/foo
[root@fedora27_c2_v5 ~]# cat /mnt/two/A/foo
[root@fedora27_c2_v5 ~]# stat /mnt/two/B/foo
   File: /mnt/two/B/foo
   Size: 0         	Blocks: 0          IO Block: 262144 regular empty 
file
Device: 2fh/47d	Inode: 439603      Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Context: system_u:object_r:nfs_t:s0
Access: 2019-05-28 14:00:18.929663705 -0400
Modify: 2019-05-28 14:00:18.929663705 -0400
Change: 2019-05-28 14:00:58.990124573 -0400
  Birth: -


^^ that lstat should return -ENOENT.

I think we detect a stale directory by comparing the directory's 
change_attr with the dentry's d_time.  But, here's a case where they are 
the same!

Am I wrong about this, or any clever ideas to catch this case?

Ben
