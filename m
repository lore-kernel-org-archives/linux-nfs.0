Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3.conversis.de ([213.203.208.210]:53370 "EHLO
	mail3.conversis.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbbFRMOM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 08:14:12 -0400
Received: from [192.168.0.100] (ip-88-152-83-45.hsi03.unitymediagroup.de [88.152.83.45])
	by mail3.conversis.de (Postfix) with ESMTP id 80D8515702D0
	for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 13:48:25 +0200 (CEST)
Message-ID: <5582B009.9090901@conversis.de>
Date: Thu, 18 Jun 2015 13:48:25 +0200
From: Dennis Jacobfeuerborn <dennisml@conversis.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS server startup hangs for 60 seconds
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
when I start nfs-server.service on a CentOS 7 system it takes 60 seconds
until the nfsd finally is up. Looking at the process list I see a
process 'systemd-tty-ask-password-agent' running which goes away after
the 60 seconds the startup requires soI suspect something in the startup
process is trying to get a password.

Does anyone have an idea what the reason could be for this and how I can
get rid of this delay?

Regards,
  Dennis
