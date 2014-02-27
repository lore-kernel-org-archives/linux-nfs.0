Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:53144 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbaB0Szz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Feb 2014 13:55:55 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 5C2402809A0
	for <linux-nfs@vger.kernel.org>; Thu, 27 Feb 2014 19:55:52 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 3568C4A06
	for <linux-nfs@vger.kernel.org>; Thu, 27 Feb 2014 19:55:51 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP4.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tb181539c6583a96162fe8@ZITSWEEP4.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Thu, 27 Feb 2014 19:55:51 +0100
Received: from zimbratest.desy.de (zimbratest.desy.de [131.169.72.254])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 9799F4A06
	for <linux-nfs@vger.kernel.org>; Thu, 27 Feb 2014 19:55:51 +0100 (MET)
Date: Thu, 27 Feb 2014 19:55:51 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1634529985.321049.1393527351393.JavaMail.zimbra@desy.de>
In-Reply-To: <1332832676.321036.1393527245121.JavaMail.zimbra@desy.de>
Subject: pnfs: closed connection on timeout?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi,

we observe, that under high load, time-to-time client decides to
close connection to DS. Can delayed reply trigger such behavior?

Tigran.
