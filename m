Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28430 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932087Ab1EYNiy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 09:38:54 -0400
Message-ID: <4DDD0675.9080900@panasas.com>
Date: Wed, 25 May 2011 16:39:01 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 20/26] pnfs-obj: osd raid engine read/write implementation
References: <4DDA8C3D.5080706@panasas.com> <1306168699-11685-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306168699-11685-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Benny hi!

I've implemented and tested the new schema we talked about with
max IO sizes and pg_test. (Just for debugging I removed the check
for bsize in the pnfs case). It works grate.

If you have anything send it so I can test it. Meanwhile you
can SQUASH this one as well, it will not hurt. (Sent as reply
to this mail)

I have couple more nit patches, that remove or move some prints
if that's OK? I'll send them as reply to the patches they go
into. Do you want to send one more clean round (V8). before
linux-next?

Boaz

