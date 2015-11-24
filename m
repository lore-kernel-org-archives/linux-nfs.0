Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm45-vm1.bullet.mail.bf1.yahoo.com ([216.109.115.60]:34269 "EHLO
	nm45-vm1.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753260AbbKXSGe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 13:06:34 -0500
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        labeled-nfs@linux-nfs.org
Cc: Casey Schaufler <casey@schaufler-ca.com>
From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Use of i_security in fs/nfs/inode.c
Message-ID: <5654A5C2.4050008@schaufler-ca.com>
Date: Tue, 24 Nov 2015 10:00:34 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


There is a check for inode->i_security == NULL in nfs_setsecurity
in fs/nfs/inode.c. What is the intent of this check? Are you looking
for an uninitialized security blob, are you looking to see if there
is an active security module or something else?

Is there any reason that you can see that a call to 
security_inode_getsecid()
followed by a check to see if the secid == 0 would not be equivalent?
I understand that the NULL check is faster, but it may not always be 
correct.

