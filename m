Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:51058 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756766Ab2CESRn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 13:17:43 -0500
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.3) with ESMTP id q25HGX7B021994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 18:16:33 +0100
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id q25HGWFe004376
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 18:16:33 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia2.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.2) with SMTP id q25HGWdV022088
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 18:16:32 +0100
Message-ID: <4F54F4F0.108@cea.fr>
Date: Mon, 05 Mar 2012 18:16:32 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: How does the client manage NFS3ERR_NOSPC ?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi List,

I ran a stupid test (using the kernel's knfsd) : I filled up completely 
a filesystem with a few big file. When it was 100% full (no free block 
at all), I ran a dd on it.
The dd said it could write 793 blocks of size 1mb  and failed on IO 
error. At the end, I could see an empty file in the NFS exported tree.
Question is :
    - why did I get EIO and not ENOSPC ?
    - why did dd say "hey, I could write 793 blocks" when it wrote 
nothing (and could not write anything).
Do you have an idea on that ?

    Regards

       Philippe
