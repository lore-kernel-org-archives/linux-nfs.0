Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 124-84-246-161.wendulka.net ([84.246.161.124]:46317 "EHLO
	ixit.cz" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752480AbaCGTgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 14:36:47 -0500
Received: from localhost (localhost [127.0.0.1])
	by ixit.cz (Postfix) with ESMTP id DEC1A126DCB
	for <linux-nfs@vger.kernel.org>; Fri,  7 Mar 2014 21:30:35 +0100 (CET)
Received: from ixit.cz ([127.0.0.1])
	by localhost (ixit.cz [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rcoQzH_VtvaP for <linux-nfs@vger.kernel.org>;
	Fri,  7 Mar 2014 21:30:35 +0100 (CET)
Received: from iXit?Group (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by ixit.cz (Postfix) with ESMTPSA id 0873E126DC6
	for <linux-nfs@vger.kernel.org>; Fri,  7 Mar 2014 21:30:35 +0100 (CET)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Fri, 07 Mar 2014 21:30:34 +0100
From: David Heidelberger <david.heidelberger@ixit.cz>
To: linux-nfs@vger.kernel.org
Subject: DNOTIFY to INOTIFY migration
Message-ID: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

in linux kernel is DNOTIFY actually marked as deprecated, with superior 
replacement INOTIFY.

Is any plan to migrate rpc.idmapd to INOTIFY? As I looked, it's just one 
file.

If there is some on-going porting, I'd like to test/report bugs/send 
patches, otherwise I'd like to try port it.

Thank you for answer
David Heidelberger (okias)
