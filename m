Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:37681 "EHLO
	mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751474Ab3LOSte (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Dec 2013 13:49:34 -0500
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id 8BA24602EB
	for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 19:39:46 +0100 (CET)
Received: from vpn-2-cl173 (vpn-2-cl173 [10.41.21.173])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with ESMTP id 74B73600E6
	for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 19:39:46 +0100 (CET)
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: High rate of authrefrsh calls when no NFS activity is required
Date: Sun, 15 Dec 2013 19:39:38 +0100
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201312151939.39626.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

we see a high number of authrefrsh calls (about 1000/s) while
IMHO no NFS activity is required.

More details: We have an archive server which is booted from
a ram disc and mounts his system files (/usr, /lib, ...) per
NFS v3 (mounted with the option nolock).

When the archive server dumps its local data to tape he
generates about 1000 authrefrsh calls per second despite the
fact that it does not need any data from the nfs server. There
is a correponding high number of getattr calls but no read/write
over NFS. The archive server has some files open over NFS
(i.e. the dump utility), but these are readonly.

My questions:

- Is there any way to see for which files the getattr calls
  are made? This would help to debug the problem. Is there
  any other means to see what the client wants from the
  NFS server?

- Can anyone explain where these authrefrsh calls come from?
  They result in a severe performance degration during the 
  dump to tape

Thank you and best regards

-Ulrich

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------
