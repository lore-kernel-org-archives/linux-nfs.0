Return-Path: linux-nfs-owner@vger.kernel.org
Received: from postman.teamix.net ([194.150.191.120]:37699 "EHLO
	rproxy.teamix.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755000Ab2CLN2C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 09:28:02 -0400
From: Martin Steigerwald <ms@teamix.de>
To: David Howells <dhowells@redhat.com>
Subject: FS-Cache questions: Delayed writing / aliasing
Date: Mon, 12 Mar 2012 14:18:06 +0100
Cc: linux-fsdevel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201203121418.07100.ms@teamix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David, hi everyone,

I am currently preparing some slides about FS-Cache regarding our Linux 
Performance Analysis & Tuning training.

I do have some questions:


1) What kind of caching does FS-Cache do?

I understand that FS-Cache does read caching.

I understand that FS-Cache can do write-through caching and should do so via 
NFS and CIFS. Thus when I write something into the NetFS it will be in the 
cache (unless purged in the meanwhile). Does the AFS support support write-
through caching?

Does it also do delayed writing? I.e. writes go to the cache at cache writing 
speed and are then synchronized with the NetFS in the background?

I didn't found a definite answer in [1] or [2].


2) Your paper about FS-Cache [2] mentions cache aliasing issues when accessing 
the same cache through different NetFS like NFS / CIFS or withing NFS as well.

What is the current status about this?

I understand that it should be safe when I obey the following rules:

- NFS: Each directory tree on the server is only mounted once on the client
- NFS: Sub directories of an already mounted directory on the server are not 
mounted on the client - i.e. no overlapping of server directory trees by the 
client
- Each directory tree is only mounted via one NetFS on the client

Are all these still valid?

Are there any other issues to consider?


3) What is the current state of NFS, CIFS and AFS integration? Are these 
suitable for production use in your oppinion? I have NFS FS-Cache via 
Cachefiles in testing on my workstation since a week and it seems to work.


4) What has happened to CacheFS? Is it still stalled? It does not seem to be 
integrated in mainline kernel.


I am willing to provide a patch for fscache.txt with includes some information 
about these topics.

[1] Documentation/filesystems/caching/fscache.txt
[2] http://people.redhat.com/.../fscache/FS-Cache.pdf

Thanks,
-- 
Martin Steigerwald - teamix GmbH - http://www.teamix.de
gpg: 19E3 8D42 896F D004 08AC A0CA 1E10 C593 0399 AE90
