Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:41936 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756629Ab1AMU0C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 15:26:02 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id DC29718DE
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 21:26:00 +0100 (MET)
Received: from adserv72.win.desy.de (adserv72.win.desy.de [131.169.97.58])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id D58EF13F23
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 21:26:00 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by adserv72.win.desy.de
 (Clearswift SMTPRS 5.3.4) with ESMTP id <T9a8dae190983a9613a814@adserv72.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Thu, 13 Jan 2011 21:26:00 +0100
Received: from adxf1.win.desy.de (adxf1.win.desy.de [131.169.69.229])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id B8E7415CE
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 21:26:00 +0100 (MET)
Message-ID: <4D2F5FE1.6050509@desy.de>
Date: Thu, 13 Jan 2011 21:26:09 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: nfsv4 + readdir == too many requests
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



By running intensive tests I notice that readdir oration over nfsv4.1
asks for
file attributes in readdir (attr_request) and later on for each file. To
me it looks like
broken.

This 2.6.37 + pnfs-all-latests :

git://linux-nfs.org/~bhalevy/linux-pnfs.git
378978453b64bf895de8cd0e68dbcd9e9c0155ce

100% reproducible.

Regards,
   Tigran.
