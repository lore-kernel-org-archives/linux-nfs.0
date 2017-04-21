Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51648 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425799AbdDUUBu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 16:01:50 -0400
Date: Fri, 21 Apr 2017 23:00:39 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: neilb@suse.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [bug report] sunrpc: don't check for failure from mempool_alloc()
Message-ID: <20170421200039.siyydkj2tomvitpr@mwanda>
References: <20170421195153.vzfthyjiaatc7t7k@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170421195153.vzfthyjiaatc7t7k@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> drivers/clk/x86/clk-pmc-atom.c:342 plt_clk_probe() warn: 'data->mclk_lookup' isn't an ERR_PTR

This one is not your fault.  I have a patch for this one.

regards,
dan carpenter
