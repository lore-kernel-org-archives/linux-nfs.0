Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:34176 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254AbaFKSjD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2014 14:39:03 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 883362808D3
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2014 20:30:44 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 7C08710CB
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2014 20:30:44 +0200 (MEST)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tb39908eadb83a9615f471c@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Wed, 11 Jun 2014 20:30:44 +0200
Received: from z-mta-2.desy.de (z-mta-2.desy.de [131.169.55.136])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id F28B910CB
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2014 20:30:43 +0200 (MEST)
Received: from z-mta-2.desy.de (localhost [127.0.0.1])
	by z-mta-2.desy.de (Postfix) with ESMTP id EB9E726003A
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2014 20:30:43 +0200 (CEST)
Received: from z-mta-2.desy.de (localhost [127.0.0.1])
	by z-mta-2.desy.de (Postfix) with ESMTP id DD64C26007B
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2014 20:30:43 +0200 (CEST)
Received: from z-mbx-3.desy.de (z-mbx-3.desy.de [131.169.55.141])
	by z-mta-2.desy.de (Postfix) with ESMTP id D5CEF26003A
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2014 20:30:43 +0200 (CEST)
Date: Wed, 11 Jun 2014 20:30:43 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Message-ID: <378787782.2570868.1402511443819.JavaMail.zimbra@desy.de>
In-Reply-To: <955256583.2570604.1402504421889.JavaMail.zimbra@desy.de>
References: <955256583.2570604.1402504421889.JavaMail.zimbra@desy.de>
Subject: pNFS client behavior confirmation
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




Dear pnfs developers,

I would like to confirm client behavior which was hurting us for years.

If for some reason the client is unable to connect to a DS, then this DS got blacklisted
and the only way to whitelist it again was client reboot. With RHEL7 (and I believe with
upstream kernel), after 2 mins client 'forgets' about bad DS and uses it again. This
behavior is tested and confirmed during June bakeathon.

Missing bits:

  i) it takes client 6 min to fall back to MDS, e.g time between LAYOUTGET and first WRITE to MDS 
  ii) there are no log entries why client have decided to use MDS

Thanks,
   Tigran.
