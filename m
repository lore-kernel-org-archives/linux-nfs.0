Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay06.ispgateway.de ([80.67.31.95]:59250 "EHLO
	smtprelay06.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbaIZPP4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 11:15:56 -0400
Received: from [91.47.192.41] (helo=zarafa)
	by smtprelay06.ispgateway.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <sb@plzk.de>)
	id 1XXX84-00054b-LU
	for linux-nfs@vger.kernel.org; Fri, 26 Sep 2014 17:08:16 +0200
Received: from srv1.localhost (localhost [IPv6:::1])
	by zarafa (Postfix) with ESMTP id F1D65220064
	for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2014 17:08:15 +0200 (CEST)
Subject: posix acl to nfs4 acl mapping - status?
From: =?utf-8?Q?Stefan_Bauer?= <sb@plzk.de>
To: =?utf-8?Q?linux-nfs=40vger=2Ekernel=2Eorg?=
	<linux-nfs@vger.kernel.org>
Date: Fri, 26 Sep 2014 17:08:15 +0200
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Message-Id: <zarafa.5425815f.6e31.1b72722237f64a60@srv1.localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm just a regular sysadmin and want to use NFS4 shares for backup purpose and keep existing posix acls from local filesystems during transfer.

It seems to not be supported:

root@s1:/# mount.nfs4 -o acl 192.168.0.254:/ /bla
root@s1:/# cp -Rvp omg /bla/
‘omg’ -> ‘/bla/omg’
cp: preserving permissions for ‘/bla/omg’: Operation not supported

What is the status on that? I'm aware of nfs4_getfacl but dont want to adjust permissions manually.

I also found https://tools.ietf.org/html/draft-ietf-nfsv4-acl-mapping-05 which describes a working algorithm for posix->nfs4 mapping but no evidence whether this is implemented and if so - how.

I'm using Debian testing with kernel 3.14.3.4 #5 SMP Thu May 8 16:31:22 CEST 2014 x86_64 GNU/Linux.
mount.nfs4: (linux nfs-utils 1.2.8)

Kind regards

Stefan
