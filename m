Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25917 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab1EaF61 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 01:58:27 -0400
Message-ID: <4DE48380.4050209@panasas.com>
Date: Tue, 31 May 2011 08:58:24 +0300
From: Benny Halevy <bhalevy@panasas.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        "Rees, James" <rees@umich.edu>
Subject: Re: [PATCHSET final 00/32] pnfs-obj: pnfs-objects layout driver submission
References: <4DE28CFB.4060608@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
Content-Type: text/plain; charset=UTF-8
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've rebased the tree with this patchset to get pnfs-all-2.6.39
(tip at pnfs-all-2.6.39-2011-05-31)

And also rebased everything onto v3.0-rc1:
master
	nfs-upstream
		nfsd-upstream
			nfsd41-all
				pnfs-obj
					pnfs
						pnfsd-all
							pnfsd-lexp-all
								pnfsd-exofs-all
									pnfs-all-latest


Jim, what's the status of the blocks back-end and layout driver?
I'd like to add it back to the tree before the bakeathon if possible...

Benny

