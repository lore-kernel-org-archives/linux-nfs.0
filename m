From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/2 v4] nfs: return nfs4 compound header status on op header
 decoding error
Date: Thu, 03 Jul 2008 20:49:03 +0300
Message-ID: <486D110F.1010608@panasas.com>
References: <47F0F6AB.3030302@panasas.com>		<1206974900-368-1-git-send-email-bhalevy@panasas.com>		<1207002349.15341.15.camel@heimdal.trondhjem.org>		<47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>		<4824E08E.6070401@panasas.com> <1210440276.12927.0.camel@localhost> <48277F7B.2060307@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:9191 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbYGCRtx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2008 13:49:53 -0400
Received: by yx-out-2324.google.com with SMTP id 8so306973yxm.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2008 10:49:52 -0700 (PDT)
In-Reply-To: <48277F7B.2060307@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,  following our conversation during the Connectathon
I reduced this patch as much as possible and restricted the
use of the compound header status to cases where op_hdr
decoding hit an error.

This is needed for nfs41 for graceful fallback when trying
to mount a 4.0 server with 4.1.  In this case the server
returns no ops and the hdr status is set to
NFS4ERR_MINOR_VERS_MISMATCH.

Please consider these patches:

[PATCH 1/2] nfs: return nfs4 compound header status on op header decoding error
[PATCH 2/2] nfs: remove incorrect usage of nfs4 compound response hdr.status

Thanks,

Benny
