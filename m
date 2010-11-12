Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755416Ab0KLItX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:23 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fA025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:07 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/22] rewrite of CB_LAYOUTRECALL and layoutstate code, try 2
Date: Fri, 12 Nov 2010 03:48:22 -0500
Message-Id: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is version 2 of code that rewrites the layout state handling and
the CB_LAYOUTRECALL paths, incorporating suggestions from Benny, as
well as some compile fixes for the non-v4.1 case, and reordering
the patches to put the simpler, less intrusive changes first.

I'm not entirely happy with the non-v4.1 compile fixes I added, but
they are a starting point.

It applies to Benny's current pnfs-submit branch (commit eb04948a).

patches 01-05 are straightforward tweaking preparing for the bigger changes

patches 06-08 modify CB_COMPUND processing to pass the CB_SEQUENCE info (the session in particular) up to subsequent operations.

patches 09-15 are more substantial changes affecting refcounting and blocking.

patches 16-17 are the point of it all, the rewrite of the stateid and race handling for LAYOUTGET, LAYOUTRETURN, and CB_LAYOUTRECALL

patches 18-22 are Andy's code that puts LAYOUTCOMMIT and LAYOUTRETURN in the same compound as CLOSE



Fred

