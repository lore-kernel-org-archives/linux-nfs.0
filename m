Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-1.desy.de ([131.169.56.84]:63371 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551Ab1LDMK0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 07:10:26 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 7E58B1860
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:02:10 +0100 (MET)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id EE2D113E82
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:02:09 +0100 (MET)
Received: from smtp-intra-2.desy.de (lb-40-26.desy.de) by ZITSWEEP3.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Ta11593997583a96161fa0@ZITSWEEP3.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Sun, 4 Dec 2011 13:02:09 +0100
Received: from ani.desy.de (vpn-060.desy.de [131.169.252.91])
	by smtp-intra-2.desy.de (DESY-INTRA-2) with ESMTP id CCC67E3A
	for <linux-nfs@vger.kernel.org>; Sun,  4 Dec 2011 13:02:08 +0100 (MET)
From: tigran.mkrtchyan@desy.de
To: linux-nfs@vger.kernel.org
Subject: nfsv41: add current_stateid processing
Date: Sun,  4 Dec 2011 13:03:55 +0100
Message-Id: <1323000237-13565-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

current_stateid processing will allow clients to construct compounds
like OPEN + READ + CLOSE or OPEN +LAYOUTGET.

As dCache server marks all layouts return-on-close, any open to a file followed
by LAYOUTGET. A combined compound will allow to do the same in one go.

Currently linux client doesn't support it. But before we can get such functionality
linux server have to support it as well. Here is an attempt to add it.

I made a dirty test with pynfs with to test OPEN+CLOSE in a single compound.
If I read nfsd code correctly, READ and WRITE have to work as well. I will refactor
pynfs a bit to easily construct such tests.

This is patches for preview to be sure that other server developers are happy with
my approach before I change much more. 

Tigran.

