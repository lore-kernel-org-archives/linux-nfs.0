Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:58499 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752932AbbC3OSf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 10:18:35 -0400
Message-ID: <55195B3B.40205@opengridcomputing.com>
Date: Mon, 30 Mar 2015 09:18:35 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
References: <20150324201849.2311.53599.stgit@manet.1015granger.net>
In-Reply-To: <20150324201849.2311.53599.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

Chelsio's QA regression tested this series on iw_cxgb4.  Tests out good.

Tests ran: spew, ffsb, xdd, fio, dbench, and cthon with both v3 and v4.

Thanks,

Steve.
