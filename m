Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fisica.ufpr.br ([200.17.209.129]:51875 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbaJKDoU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Oct 2014 23:44:20 -0400
Date: Sat, 11 Oct 2014 00:36:27 -0300
From: Carlos Carvalho <carlos@fisica.ufpr.br>
To: linux-nfs@vger.kernel.org
Subject: massive memory leak in 3.1[3-5] with nfs4+kerberos
Message-ID: <20141011033627.GA6850@fisica.ufpr.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're observing a big memory leak in 3.1[3-5]. We've gone until 3.15.8 and back
to 3.14 because of LTS. Today we're running 3.14.21. The problem has existed
for several months but recently has become a show-stopper.

Here are the values of SUnreclaim: from /proc/meminfo, sampled at every 4h
(units are kB):

87192
297044
765320
2325160
3306056
4412808
4799292
5085392
4999936
5521648
6628496
7785460
8518084
8988404
9141220
9533224
10053484
10954000
11716700
12369516
12847412
13318872
13846196
14339476
14815600
15293564
15798024
17092772
19240084
21679888
22399060
22943812
23407004
24049804
26210880
28034980
29059812  <== almost 30GB!

After a few days the machine has lost so much memory that it panics or becomes
very slow due to lack of cache and we have to reboot it. It's a busy file
server of home directories.

We have several other busy servers (including identical hardware) but the
memory leak happens only in this machine. What is different with it is that
it's the only place where we use:
- nfs4 with authentication and encryption by kerberos
- raid10

All others do only nfs3 or no nfs, and raid6. That's why we suspect it's a nfs4
problem.

What about these patches: http://permalink.gmane.org/gmane.linux.nfs/62012
Bruce said they were accepted but they're not in 3.14. Were they rejected or
forgotten? Could they have any relation to this memory leak?

