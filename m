Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:51526 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbaBWQWZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Feb 2014 11:22:25 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 04572280489
	for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 17:22:19 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id D56E713E9C
	for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 17:22:17 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP4.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tb16c2d93d083a96162fe8@ZITSWEEP4.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Sun, 23 Feb 2014 17:22:17 +0100
Received: from ani.fritz.box (vpn-009.desy.de [131.169.252.40])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id 4EB273E902
	for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 17:22:17 +0100 (MET)
From: tigran.mkrtchyan@desy.de
To: linux-nfs@vger.kernel.org
Subject: 
Date: Sun, 23 Feb 2014 17:22:14 +0100
Message-Id: <1393172535-4617-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

to me it's unclear, why a SETATTR  always follows an OPEN, even in case of
EXCLUSIVE4_1. With this fix, I get desired behavior.

Tigran.

