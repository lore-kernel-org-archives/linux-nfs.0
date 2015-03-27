Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:35949 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbbC0LYR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 07:24:17 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 6EF8E280AF1
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 12:24:15 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 5944B16A3
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 12:24:14 +0100 (MET)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tb96799628a83a9615f1c70@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Fri, 27 Mar 2015 12:24:15 +0100
Received: from z-mta-2.desy.de (z-mta-2.desy.de [131.169.55.136])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 933BB2ADA
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 12:24:14 +0100 (MET)
Received: from z-mta-2.desy.de (localhost [127.0.0.1])
	by z-mta-2.desy.de (Postfix) with ESMTPS id 8F39C26011B
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 12:24:14 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by z-mta-2.desy.de (Postfix) with ESMTP id 80B6426011C
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 12:24:14 +0100 (CET)
Received: from z-mta-2.desy.de ([127.0.0.1])
	by localhost (z-mta-2.desy.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id P20-e3VNLQAf for <linux-nfs@vger.kernel.org>;
	Fri, 27 Mar 2015 12:24:14 +0100 (CET)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
	by z-mta-2.desy.de (Postfix) with ESMTP id 6C53A26011B
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 12:24:14 +0100 (CET)
Date: Fri, 27 Mar 2015 12:24:14 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs list <linux-nfs@vger.kernel.org>
Message-ID: <61504045.542929.1427455454361.JavaMail.zimbra@desy.de>
Subject: pNFS layout, ROC and multiple opens
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi folks,

we run into following issue:

on a client host we have two processes - A and B.
Process A opens a file and reads some data:

OPEN -> LAYOUTGET -> READ.
Notice, that layout has a roc set to true.

Process B opens the same file:

OPEN -> READ.

Client obviously re-used layout information.
Now, process A closes the file and as a result,
layout becomes invalid. Nevertheless, process B
still assumes that layout still valid:

I thinks this is the source of the problem:

fs/nfs/pnfs.c:

1074         list_for_each_entry(ctx, &nfsi->open_files, list) {
1075                 state = ctx->state;
1076                 /* Don't return layout if there is open file state */
1077                 if (state != NULL && state->state != 0)
1078                         goto out_noroc;
1079         }
1080 


this is with 3.19. The RHEL7 kernel send yet another LAYOUTGET when the process A
closes the file.

Tigran.


