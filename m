Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:48700 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752203Ab0I0SD7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 14:03:59 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1P0Hhp-0004af-Sf
	for linux-nfs@vger.kernel.org; Mon, 27 Sep 2010 13:41:38 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Making svcgssd more Cluster friendly
Date: Mon, 27 Sep 2010 13:41:35 -0400
Message-Id: <1285609297-3424-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I'm basically reposting Eberhard's patches to svcgssd in
format that makes them easlier to review.

They basically add a -p argument which allows the setting 
of the principle used to get the machine creds, instead of
using the principle in the keytab... I think its a good
idea.. Anything that make svcgssed easier to work with
I'm a fan of! ;-) 

Eberhard Kuemmerle (2):
  svcgssd: Adding a <-p principal> flag
  Added the -p <principal> flag to the svcgssd manpage

 utils/gssd/gss_util.c  |    4 ++--
 utils/gssd/gss_util.h  |    2 +-
 utils/gssd/gssd.h      |    1 -
 utils/gssd/svcgssd.c   |   28 ++++++++++++++++++++--------
 utils/gssd/svcgssd.man |    6 ++++--
 5 files changed, 27 insertions(+), 14 deletions(-)

-- 
1.7.2.3

