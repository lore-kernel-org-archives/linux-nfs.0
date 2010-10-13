Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61396 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab0JMEKx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 00:10:53 -0400
Received: by bwz15 with SMTP id 15so2924972bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 21:10:52 -0700 (PDT)
In-Reply-To: <AANLkTi=rzJXAPc17ggmw0LPS_Hn9HG15syLOtSN=nWdp@mail.gmail.com>
References: <AANLkTi=rzJXAPc17ggmw0LPS_Hn9HG15syLOtSN=nWdp@mail.gmail.com>
Date: Wed, 13 Oct 2010 00:41:50 -0300
Message-ID: <AANLkTimNH+YuR2fHo3Sz1sO434oOag9ON-omTXBQ0_2Z@mail.gmail.com>
Subject: Re: nfs4 all_squash: does it work at all?
From: zoolook <nbensa@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2010/10/12 zoolook <nbensa@gmail.com>:
> Why uid:1000 with nfs4 and uid:65534 with nfs3? What am I missing?
> Note that I would like nfs4 behave like nfs3.

I've been struggling with this for two weeks. I've read lots of docs,
posts, forums, faqs... and I hate when I find the answer just after
clicking send to a mailing list.

For the record, what I missed was the fact that I need to do bind
mount for nfs4 to work properly.

Server:
$ ls -lnd /shares/sistemas/
drwxrws--- 2 65534 1002 4096 2010-10-12 23:25 /shares/sistemas/

$ mount | grep NFSROOT
/shares/sistemas on /NFSROOT/shares/Sistemas type none (rw,bind)

$ cat /etc/exports
/NFSROOT			*(ro,sync,no_subtree_check,fsid=root)
/NFSROOT/shares/Sistemas	*(rw,sync,no_subtree_check,all_squash,anongid=1002)

Client:
$ mount | grep nfsserver
nfsserver:/shares/Sistemas on /compartidos/sistemas type nfs4
(rw,clientaddr=10.11.101.124,addr=10.11.101.126)

$ touch /compartidos/sistemas/q

$ ls -ln /compartidos/sistemas/
total 0
-rw-r--r-- 1 65534 1002 0 2010-10-13 00:37 q



Thanks to all who have read. And I'm sorry for the noise.

Best regards,
Norberto
