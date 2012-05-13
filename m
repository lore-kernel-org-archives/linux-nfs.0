Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61738 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199Ab2EMLmV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 May 2012 07:42:21 -0400
Received: by bkcji2 with SMTP id ji2so3149845bkc.19
        for <linux-nfs@vger.kernel.org>; Sun, 13 May 2012 04:42:20 -0700 (PDT)
Message-ID: <4FAF9E19.4060802@tonian.com>
Date: Sun, 13 May 2012 14:42:17 +0300
From: Lior <lior@tonian.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: nfs v4.1 client without pNFS
Content-Type: text/plain; charset=windows-1255; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The rfc 5661 states that pNFS is an optional feature.
Is there currently an intent to implement some sort of an option (module 
option ,or mount option) to run the NFSv4.1 client without pNFS 
functionality?

Thanks,
  Lior K.
