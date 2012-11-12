Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.virtall.com ([178.63.195.102]:49898 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171Ab2KLPUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 10:20:23 -0500
Received: from mail.virtall.com (localhost [127.0.0.1])
	by mail.virtall.com (Postfix) with ESMTP id 36E14359971
	for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 16:14:05 +0100 (CET)
Received: from [192.168.1.2] (adsl-61.91.140.82.tellas.gr [91.140.82.61])
	by mail.virtall.com (Postfix) with ESMTPSA id AF4A3359969
	for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 16:14:04 +0100 (CET)
Message-ID: <50A1123A.4000004@wpkg.org>
Date: Mon, 12 Nov 2012 17:14:02 +0200
From: Tomasz Chmielewski <mangoo@wpkg.org>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: xattr support in NFS?
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Does Linux support xattr in NFS?

IF tries using it in both NFS3 and NFS4 under Debian Lenny (2.6.32, both 
server and client), without success.

# setfattr -n user.comment -v "this is a comment" /mnt/nfs
setfattr: /mnt/nfs: Operation not supported


-- 
Tomasz Chmielewski
http://blog.wpkg.org
