Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from crash-1.cutaway.it ([89.186.66.80]:58936 "EHLO mail.cutaway.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754994Ab0FHQcX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 12:32:23 -0400
Received: from mail.cutaway.it (localhost [127.0.0.1])
	by mail.cutaway.it (Postfix) with ESMTP id C4EA7208052
	for <linux-nfs@vger.kernel.org>; Tue,  8 Jun 2010 18:24:50 +0200 (CEST)
Received: from mail.cutaway.it (localhost [127.0.0.1])
	by mail.cutaway.it (Postfix) with ESMTP id D5E6A20804F
	for <linux-nfs@vger.kernel.org>; Tue,  8 Jun 2010 18:24:49 +0200 (CEST)
Received: from [IPv6:::1] (89-96-63-86.ip11.fastwebnet.it [89.96.63.86])
	by mail.cutaway.it (Postfix) with ESMTPA
	for <linux-nfs@vger.kernel.org>; Tue,  8 Jun 2010 18:24:49 +0200 (CEST)
Message-ID: <4C0E6ED0.60200@miamammausalinux.org>
Date: Tue, 08 Jun 2010 18:24:48 +0200
From: RaSca <rasca@miamammausalinux.org>
Reply-To: rasca@miamammausalinux.org
To: linux-nfs@vger.kernel.org
Subject: Problem using exportfs in an active-active nfs cluster
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all,
I'm trying to use a resource agent named exportfs for my active-active 
nfs cluster configuration.
The resource agent works using the exportfs command. I have an instance 
of nfs-kernel-server for each node and exportfs dynamically remove or 
append the export to the node (obviously I've got also a shared storage).
The problem comes when the export is mounted by a client and this client 
is writing on it: if the node switches, then the migration fails. The 
sequence is this one:

- The resource exportfs stops correctly (the Resource Agent launch 
exportfs -u)
- The Filesystem resource tries to unmount the exported filesystem, 
doing an fuser to see if some processes are locking the fs.
- fuser doesn't return anything, but the filesystem is still locked. 
This happens because the kernel process nfsd is locking the FS.
- The migration fails.

The only way to make thing work again is to restart the 
nfs-kernel-daemon on the node which the resource reside and then cleanup 
the resource.

Now, after many discussions on the Linux-ha Mailing List, I'm here to 
ask if this problem is about the exportfs command. Why a filesystem 
remains locked to the nfsd kernel process even if I (or the resource 
agent) have done an "exportfs -u" command?

What can else I do to free the exported filesystem? Note that I've tried 
to mount from the client with "nolock" option and also the exported 
filesystem is mounted with "noatime".

Thanks a lot,

-- 
RaSca
Mia Mamma Usa Linux: Niente è impossibile da capire, se lo spieghi bene!
rasca@miamammausalinux.org
http://www.miamammausalinux.org
