Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:59315 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754700AbaHAOOz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2014 10:14:55 -0400
Message-ID: <53DBA0E6.8010505@opengridcomputing.com>
Date: Fri, 01 Aug 2014 09:15:02 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: bfields@fieldses.org
CC: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: remove rdma_create_qp() failure recovery logic
References: <20140731202606.12144.2363.stgit@build.ogc.int>
In-Reply-To: <20140731202606.12144.2363.stgit@build.ogc.int>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tested over cxgb4 and mlx4.

Steve.
