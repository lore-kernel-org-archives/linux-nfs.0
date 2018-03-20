Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44096 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751456AbeCTVsV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 17:48:21 -0400
Date: Tue, 20 Mar 2018 17:48:21 -0400
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
Message-ID: <20180320214821.GF4288@fieldses.org>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name>
 <878tasc3ag.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <878tasc3ag.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 16, 2018 at 10:44:23AM +1100, NeilBrown wrote:
> 
> nfs4_proc_exchange_id() can return -EINVAL if the server
> reported NFS4INVAL (which I have seen in a packet trace),

Can you say which server this was?  (One we can fix?)

--b.
