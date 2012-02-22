Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57874 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab2BVTYO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2012 14:24:14 -0500
Received: by bkcjm19 with SMTP id jm19so413364bkc.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2012 11:24:12 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 22 Feb 2012 19:24:12 +0000
Message-ID: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com>
Subject: NFSv4 client restriction
From: Peter Horvath <peter.horvath77@googlemail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We are using Ubuntu LTS 10.04 servers and clients.
NFS version is the following:
nfs-common                     1.2.0-4ubuntu4.2
nfs-kernel-server               1.2.0-4ubuntu4.2

My exports looks like this:

/srv 10.66.3.0/24(fsid=0,ro,no_subtree_check,sync)
/srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
/srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
/srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)

My problem is that in this case clients have only read-only access. If
i set the pseudofilesystem root to RW it is working but in that case
all the clients would be able to mount the root and access other
projects too.
How can i achieve the same results as it was in NFSv3 with this config.

/srv/www/project1 10.66.3.101(rw,no_root_squash,no_subtree_check,sync)
/srv/www/project2 10.66.3.102(rw,no_root_squash,no_subtree_check,sync)
/srv/www/project3 10.66.3.103(rw,no_root_squash,no_subtree_check,sync)

I wasn't able to find any solution on the net and forums so far.

All help would be appreciated.

Thank you
