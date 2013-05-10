Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-in-06.arcor-online.net ([151.189.21.46]:53040 "EHLO
	mail-in-06.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753380Ab3EJTz4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 15:55:56 -0400
Received: from mail-in-19-z2.arcor-online.net (mail-in-19-z2.arcor-online.net [151.189.8.36])
	by mx.arcor.de (Postfix) with ESMTP id C56F810BCC0
	for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 21:55:54 +0200 (CEST)
Received: from mail-in-01.arcor-online.net (mail-in-01.arcor-online.net [151.189.21.41])
	by mail-in-19-z2.arcor-online.net (Postfix) with ESMTP id C64283F842C
	for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 21:55:54 +0200 (CEST)
Received: from laptop64.home (f053205062.adsl.alicedsl.de [78.53.205.62])
	(Authenticated sender: a.radke@arcor.de)
	by mail-in-01.arcor-online.net (Postfix) with ESMTPSA id 81E335A41C
	for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 21:55:54 +0200 (CEST)
Date: Fri, 10 May 2013 21:55:53 +0200
From: Andreas Radke <a.radke@arcor.de>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 ACL issues since 3.0.72 leading to corrupt files (xfs)
Message-ID: <20130510215553.0a1130be@laptop64.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm running a server with a NFSv4 share drive that also hosts a Mail
directory I provide with dovecot IMAP server. Dovecot has ACL plugin
disabled.

Since the 4 NFSv4 ACL related commits in kernel 3.0.72 (and all other
stable kernels) all kernels until the recent stable releases give such
errors when changing :

imap(andyrtr):
Error:maildir_file_do(/mnt/share/andyrtr/Mail/.Mailinglisten.Linux-stable/cur/msg.MFVZBC:2,):
Filename keeps changing

These are file system errors. I need to run xfs_repair on the drive
and then need to stay with an outdated kernel.

I think this is a serious regression. Can somebody confirm it and 
tell me if this should be reported somewhere to a bug tracker 
against nfs/xfs/... and how to solve this?

-Andy
ArchLinux
