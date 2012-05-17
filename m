Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34332 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965520Ab2EQL3i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 07:29:38 -0400
Received: by wibhn6 with SMTP id hn6so1739637wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 17 May 2012 04:29:37 -0700 (PDT)
Message-ID: <4FB4E11D.2000202@tonian.com>
Date: Thu, 17 May 2012 14:29:33 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.4-rc7-2012-05-17
References: <4EC13EEA.3030404@tonian.com>
In-Reply-To: <4EC13EEA.3030404@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I rebased the pnfs tree onto v3.4-rc7 and tagged pnfs-all-latest as pnfs-all-3.4-rc7-2012-05-17

Note that the pnfsd-block back-end is temporarily deprecated as the rpc pipe mechanism
was changed considerably and I currently have no resources to forward port this code
and test it.

The following patches were merged since pnfs-all-3.3-2012-03-25:

pnfsd:
  Benny Halevy     4e55bbb SQUASHME: fixup rpc_pton parameters for 3.4

pnfsd-lexp:
  Benny Halevy     f5cd008 pnfsd: apply pnfs export option on pnfs export ops setup
