Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26914 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163667AbdDXAhP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Apr 2017 20:37:15 -0400
Date: Mon, 24 Apr 2017 03:36:33 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [bug report] sunrpc: don't check for failure from mempool_alloc()
Message-ID: <20170424003633.uy6it47t3rnxjhq3@mwanda>
References: <20170421195153.vzfthyjiaatc7t7k@mwanda>
 <87shkyrc28.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87shkyrc28.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Another option would be to add a comment to rpc_run_task() to say that
it returns error pointers on error.  Otherwise the callers will start
checking for NULL because you can't tell from the context.

regards,
dan carpenter

