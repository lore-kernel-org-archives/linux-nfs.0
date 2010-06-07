Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57123 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab0FGFdk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 01:33:40 -0400
Received: by bwz11 with SMTP id 11so865490bwz.19
        for <linux-nfs@vger.kernel.org>; Sun, 06 Jun 2010 22:33:38 -0700 (PDT)
Message-ID: <4C0C84B0.5010900@panasas.com>
Date: Mon, 07 Jun 2010 08:33:36 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs-all-2.6.35-rc2-2010-06-06 is out
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Howdy,

I've rebased the linux pnfs tree onto 2.6.35 with the tip tagged as
pnfs-all-2.6.35-rc2-2010-06-06
Development branches structure remains the same:
master (2.6.345-rc2)
		pnfs-submit
			pnfs
				pnfs-block
		pnfsd-files
			pnfsd
				spnfs
					spnfs-block
				pnfsd-lexp
					pnfs-submit-all
						pnfs-all
							pnfs-obj-all
								pnfs-exofs-all
									pnfs-block-all
										spnfs-all
											spnfs-block-all
												pnfs-all-latest

Let's try to get everything we want to test in the upcoming bakeathon into
the tree in a decent shape.

Cumulative diff against mainline can be generated as usual using:
$ git diff v2.6.35-rc2 pnfs-all-2.6.35-rc2-2010-06-06
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree
has been updated to reflect the latest tags.

Benny
