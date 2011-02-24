Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tur.go2.pl ([193.17.41.50]:47535 "EHLO tur.go2.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754684Ab1BXN4z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 08:56:55 -0500
Received: from mailout1.go2.pl (mailout1.go2.pl [193.17.41.11])
	by tur.go2.pl (o2.pl Mailer 2.0.1) with ESMTP id F15F02317A7
	for <linux-nfs@vger.kernel.org>; Thu, 24 Feb 2011 14:56:53 +0100 (CET)
Received: from mailout1.go2.pl (unknown [10.0.0.104])
	by mailout1.go2.pl (Postfix) with ESMTP id 0460B3000B
	for <linux-nfs@vger.kernel.org>; Thu, 24 Feb 2011 14:56:06 +0100 (CET)
Received: from o2.pl (unknown [10.0.0.36])
	by mailout1.go2.pl (Postfix) with SMTP
	for <linux-nfs@vger.kernel.org>; Thu, 24 Feb 2011 14:56:05 +0100 (CET)
Subject: =?UTF-8?Q?stat_family_function_problem_(php?=
	=?UTF-8?Q?_file=5Fexists)?=
From: =?UTF-8?Q?larith?= <larith@go2.pl>
To: linux-nfs@vger.kernel.org
Message-ID: <3c95bae3.61f80ace.4d666374.d4ebc@go2.pl>
Date: Thu, 24 Feb 2011 14:56:04 +0100
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

I have one nfs server mounted on 2 clients. If I check on client2 if a file exists, then after creating this file on client2 is is not immediately visible to file_exist() function on client2. it was only after some time. how to fix this ?

client1:/mnt/storage0/test# cat a.php
<?php

if (file_exists ($argv[1])) {
    echo "1\n";
} else {
    echo "0\n";
}


client2:/mnt/storage0/test# php a.php test1
0
client1:/mnt/storage0/test# touch test1

client2:/mnt/storage0/test# php a.php test1
0
client2:/mnt/storage0/test# php a.php test1
0
..........
client2:/mnt/storage0/test# php a.php test1
1


mtab:

xxx:/mnt/drbd0/ /mnt/storage0 nfs rw,hard,timeo=7,intr,addr=xxx 0 0

export

/mnt/drbd0        10.0.0.0/8(rw,async,no_subtree_check,no_root_squash,fsid=100)
