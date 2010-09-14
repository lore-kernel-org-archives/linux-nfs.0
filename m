Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:37468 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab0INOR7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Sep 2010 10:17:59 -0400
Date: Tue, 14 Sep 2010 10:17:57 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: DENIEL Philippe <philippe.deniel@cea.fr>, linux-nfs@vger.kernel.org
Subject: Re: Deploying a pNFS / LAYOUT4_BLOCK_VOLUME configuration
Message-ID: <20100914141757.GA26504@merit.edu>
References: <4C8F6D39.2070406@cea.fr>
 <4C8F80DA.4030607@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C8F80DA.4030607@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  Jim, mind taking a look at the wiki page and update it,
  in particular anything regarding blkmapd?

I can't comment on the server setup.  For the client, there are Fedora
specific instructions here:

http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

If you're not using Fedora, you want to install the kernel and nfs-utils
from git.  I'm working on a wiki page with generic client instructions but
it goes something like this:

iscsiadm -m discovery -t sendtargets -p pnfs-server-iscsi -l
service blkmapd restart
mount -t nfs4 -o minorversion=1 pnfs-server-1:/pnfs /mnt
[ run tests ]
umount /mnt
iscsiadm -m node -U all
