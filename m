From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Got error -10052 from the server on DESTROY_SESSION. Session has
 been destroyed regardless...
Date: Tue, 08 Jun 2010 19:13:43 +0300
Message-ID: <4C0E6C37.3040504@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23241 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753504Ab0FHQNp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 12:13:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 2.6.35-rc2-pnfs I get:

Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...

at end of cthon test. And it has hard time umounting. After some seconds it is able to umount
Am investigating. Has any one seen this?

Boaz

