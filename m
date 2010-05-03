Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:40089 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759658Ab0ECQN6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 12:13:58 -0400
Received: by bwz19 with SMTP id 19so1410367bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 09:13:57 -0700 (PDT)
Message-ID: <4BDEF641.4020507@panasas.com>
Date: Mon, 03 May 2010 19:13:53 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [RFC 0/3] nfsd41: do not expire client while in use by current compound
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce,  the following patchset compiles but is not fully tested yet.
It is based on top of http://marc.info/?l=linux-nfs&m=127288934008791&w=2
Please review.

Thanks,

Benny

[RFC 1/3] nfsd4: use local variable in nfs4svc_encode_compoundres
[RFC 2/3] nfsd4: hold a reference on nfs4_client when it is used by a session
[RFC 3/3] nfsd4: do not expire nfs41 clients while in use
