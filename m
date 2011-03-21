Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.conversis.de ([213.203.219.181]:33497 "EHLO
	mail4.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476Ab1CUC6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Mar 2011 22:58:30 -0400
Received: from [10.143.1.248] (unknown [212.23.103.97])
	by mail4.conversis.de (Postfix) with ESMTP id 82D832410004
	for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2011 03:24:51 +0100 (CET)
Message-ID: <4D86B6F2.1070004@conversis.de>
Date: Mon, 21 Mar 2011 03:24:50 +0100
From: Dennis Jacobfeuerborn <d.jacobfeuerborn@conversis.de>
To: linux-nfs@vger.kernel.org
Subject: bind mounts, crossmnt and multi client nfsv3
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
I have a storage system that is exporting many directories to multiple 
clients resulting in a lot of mountpoints (156) on each client. What I'm 
trying to do is to create a single directory on the server and then use 
mount --bind to mount all the different directories (which are stored on 
different LVM volumes) into this single export directory and finally export 
this directory to the clients.
Now the exports man-page mentions the crossmnt option but it also mentions 
that it cannot be used if I want to export the directory to multiple 
clients. Is there another way to accomplish something like this?

Regards,
   Dennis
