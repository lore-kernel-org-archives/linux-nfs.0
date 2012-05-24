Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:43798 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab2EXAQx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2012 20:16:53 -0400
Message-ID: <4FBD7DE8.9090002@panasas.com>
Date: Thu, 24 May 2012 03:16:40 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Does our Kernel PNFSD-Server supports recurring layout_get with open_state_id
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Benny hi

If I remember/understand correctly, there is a mode in the RFC errata
about the layout forgetful-model and a client sending a layout_get with
an open_state_id after he already had previous state (layouts) on the file.

As I understood this is an indication to the server that client has
"forgotten" all it's layouts on a file, and Server can assume their
return.

Is my understanding correct?

If Yes:
	Did we implement the internal return of all layouts, if above
	open_state_id is encountered?
	I thought we did but I can't find this code.

Currently, I always set ROC so there is no leak. But theoretically
ROC does not have to be set. I'm doing some heavy lifting of
layout_return, and I want to make sure I have not missed a spot.

If I'm correct that it is needed, and it's missing:
My suggestion for now is that we always set ROC, disregarding FS so not to
leak layouts and therefor inode-refs, until such time that we implement it.

Thanks
Boaz
