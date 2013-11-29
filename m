Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f53.google.com ([209.85.215.53]:45424 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab3K2LVL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Nov 2013 06:21:11 -0500
Received: by mail-la0-f53.google.com with SMTP id ea20so6584245lab.26
        for <linux-nfs@vger.kernel.org>; Fri, 29 Nov 2013 03:21:08 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 29 Nov 2013 12:21:08 +0100
Message-ID: <CAPD_G3JioWUiBJD-SMZeMgQd40DarVV_bYAnggQKgWLi3bQPCw@mail.gmail.com>
Subject: Questions abou nfsd file cache and open files
From: "Charles 'Boyo" <charlesboyo@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all.

Please guide me into to find out the impact a busy nfsd is having on
the Linux page cache. Is it possible to determine which files have
portions in the page cache?

Secondly, files opened by nfs clients do not show up in lsof (or ftop)
on the nfs server? Is there any way to list these open files and more
importantly, observe the i/o to them?

Charles
