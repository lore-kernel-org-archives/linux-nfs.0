Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62210 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759778Ab2FUQ1r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jun 2012 12:27:47 -0400
Received: by pbbrp8 with SMTP id rp8so2311368pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jun 2012 09:27:47 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 21 Jun 2012 19:27:46 +0300
Message-ID: <CABpMAyKsxrxQ9azxOJLv209HYE=SFtS2-jQ7bdJZerYaxh9=EQ@mail.gmail.com>
Subject: Object Layout Driver Missing Functionality: FLUSH_STABLE
From: Idan Kedar <idank@tonian.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Boaz,

The OSD protocol has the concept of caching and that the FUA (force
unit access) bit can be used to tell the server to commit a write to
stable storage, much like NFS' stable_how4. the object layout driver
does not switch on the server caching logic and does not implement
commit_pagelist method and its satellites. instead, it assumes write
is always to stable storage.
the pNFS client communicates stable_how4 (along with other infomation)
to the layout drivers via the 'how' argument of the write_pagelist
method. the object layout driver currently uses the 'how' argument to
decide whether or not to wait for the OSD requests to end or use a
callback, but translation of stable_how4 via 'how' to FUA bit is
missing.
-- 
Idan Kedar
Tonian
