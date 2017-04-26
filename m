Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:57765 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1032043AbdDZWrj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 18:47:39 -0400
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <glN-linux-nfs@m.gmane.org>)
        id 1d3Vid-0005md-Lu
        for linux-nfs@vger.kernel.org; Thu, 27 Apr 2017 00:47:31 +0200
To: linux-nfs@vger.kernel.org
From: scar <scar@drigon.com>
Subject: Re: rdma connection close/reopen every 5 mins
Date: Wed, 26 Apr 2017 15:47:17 -0700
Message-ID: <odr81f$k4m$1@blaine.gmane.org>
References: <odql2m$vup$1@blaine.gmane.org>
 <97258237-282D-4A72-9AEE-BC1B82DF8E1C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
In-Reply-To: <97258237-282D-4A72-9AEE-BC1B82DF8E1C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote on 04/26/2017 01:32 PM:
> If it's every 5 minutes, that's probably the RPC idle timeout
> that is closing the connection.
>
> So this should be entirely harmless.

Yes so far it seems harmless, but it is annoying and fills up the log 
with spam, plus it's not something I see when using NFS/TCP.

thanks

