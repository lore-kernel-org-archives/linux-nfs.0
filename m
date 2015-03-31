Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48868 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752558AbbCaOVR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 10:21:17 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id D261820C3E
	for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2015 10:21:13 -0400 (EDT)
Message-Id: <1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
From: lyndat3@your-mail.com
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain
Subject: file xfer over NFSv4 with 'sync' ~300X slower than with 'async' ?
Date: Tue, 31 Mar 2015 07:21:16 -0700
In-Reply-To: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
References: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Narrowing doen the issue, NFSv4 file xfer with 'sync' appears, here, to be ~ 300X slower than with 'async'.

(1) for NFSv4 mount with 'sync'

	grep NAS1 /etc/auto.nfs4 
		NAS1   -fstype=nfs4,_netdev,rw,proto=tcp,sync,...  xen01.loc:/

a 100MB file xfer takes ~8 minutes

	rm -f /mnt/NFS4/NAS1/file.out && \
	 time dd if=/dev/zero of=/mnt/NFS4/NAS1/file.out  bs=32K count=3K
		3072+0 records in
		3072+0 records out
		100663296 bytes (101 MB) copied, 485.721 s, 207 kB/s

		real    8m5.861s
		user    0m0.012s
		sys     0m0.250s

(2) Change mount 'sync' -> 'async',

	vi /etc/auto.nfs4 
	-	NAS1   -fstype=nfs4,_netdev,rw,proto=tcp,sync,...  xen01.loc:/
	+	NAS1   -fstype=nfs4,_netdev,rw,proto=tcp,async,...  xen01.loc:/
	systemctl restart autofs

the same 100MB file xfer takes ~ 2 seconds

	rm -f /mnt/NFS4/NAS1/file.out && \
	 time dd if=/dev/zero of=/mnt/NFS4/NAS1/file.out  bs=32K count=3K
		3072+0 records in
		3072+0 records out
		100663296 bytes (101 MB) copied, 1.65577 s, 60.8 MB/s

		real    0m1.658s
		user    0m0.000s
		sys     0m0.089s


I'd expect 'sync' to be slower than 'async', but 300X ?

Is there additional config that cures, or at least drastically improves, this slow down?

Some very old (10+ years) posts suggested kernel bugs, but those were fixed ages ago.  Maybe reemerged?

LT
