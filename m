Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:57828 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab2ECWbw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 May 2012 18:31:52 -0400
Received: by wgbdr13 with SMTP id dr13so2175835wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 May 2012 15:31:51 -0700 (PDT)
MIME-Version: 1.0
From: Marek Stopka <mstopka@opensuse.org>
Date: Thu, 3 May 2012 23:31:30 +0100
Message-ID: <CABdhxhS+OscW43pHLodfKQ-qV9ddLaJ1Dasp9s3H902_vCU-gQ@mail.gmail.com>
Subject: MultiPath NFS (Oracle DirectNFS)
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
as you might already know, Oracle 11g have its own implementation of NFS called
DirectNFS, it works pretty with very same NFSv3 protocol as everyone else,
except it implements some advanced features on a client side, such as MultiPath.

Currently if you want to have multiple physical paths to storage in Linux
environment, you need to configure Ethernet bonding, which might be a pain over
multiple physical switches, especially when you consider adding capacity as well
as redundancy. With Direct NFS you configure each path to a storage as separate
L1/L2/L3 domain with no support from Ethernet whatsoever and Oracle NFS client
"knows" these multiple IP addresses you provided leads to same storage with same
data and it automatically distributes your requests over these three paths.

Have you ever considered implementing same functionality in kernel NFS client?
It have some advantages over bonding/etherchannel scenario, such as you are
protected against L2 netwokr errors, whatever happends in one path L2 domain,
will not affect others paths L2 domains. It will remove all complexity of
bonding ethernet interfaces, which does not always work with all Ethernet
drivers for all Ethernet cards,... While at a same time, you can implement
redundancy and increased performance with multiple paths to the storage even
without advanced switches (Nexus with vPC, Catalyst with VSS,..) because you
don't need any link aggregation protocols to work over multiple
physical switches...

http://www.oracle.com/technetwork/articles/directnfsclient-11gr1-twp-129785.pdf
- Direct NFS whitepaper
--
S pozdravem / Best regards
Marek Stopka
Kontakty / Contacts
Mobil/Cell phone:+420 608 149 955
WEB: www.stopkaconsulting.eu
