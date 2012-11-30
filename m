Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:59219 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1030442Ab2K3NU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 08:20:59 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Fri, 30 Nov 2012 08:20:58 -0500
From: David Quigley <dpquigl@davequigley.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Casey Schaufler <casey@schaufler-ca.com>, <trond.myklebust@netapp.com>,
        <sds@tycho.nsa.gov>, <linux-nfs@vger.kernel.org>,
        <selinux@tycho.nsa.gov>, <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <20121130121437.GC614@fieldses.org>
References: <50AC4A7A.6010208@davequigley.com>
 <50B65E7E.4030607@schaufler-ca.com> <50B6B706.1010002@davequigley.com>
 <50B6C398.90002@schaufler-ca.com> <50B7E189.80200@schaufler-ca.com>
 <d0817140372d745df0b4952b796610f2@countercultured.net>
 <50B7FEFB.30109@schaufler-ca.com>
 <579e850139bd3d5a0c9155270d5d9fbe@countercultured.net>
 <50B810D2.2000401@schaufler-ca.com>
 <3ea3f70e0a5cdb99f1594019b7bd619d@countercultured.net>
 <20121130121437.GC614@fieldses.org>
Message-ID: <d8f83798c612a3446d83249a59bdd203@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That last part should have read


Maybe if CAP_FS_MASK_B1 was like this it would work.

# define CAP_FS_MASK_B1     (CAP_TO_MASK(CAP_MAC_OVERRIDE)    \
                              | CAP_TO_MASK(CAP_MAC_ADMIN))
