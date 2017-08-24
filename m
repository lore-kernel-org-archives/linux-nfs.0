Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36360 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753025AbdHXTvu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 15:51:50 -0400
Date: Thu, 24 Aug 2017 15:51:50 -0400
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Pull request for pynfs
Message-ID: <20170824195150.GC21609@fieldses.org>
References: <047901d31558$dadb5930$90920b90$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <047901d31558$dadb5930$90920b90$@mindspring.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the delay--I've taken that patch, thanks!

(BTW, for future reference the URL I need is
https://github.com/ffilz/pynfs.git.)

--b.

On Mon, Aug 14, 2017 at 04:55:48PM -0700, Frank Filz wrote:
> Bruce,
> 
> Please pull from https://github.com/ffilz/pynfs/commits/master
> 
> This patch fixes CSESS29 to issue the invalid CREATE_SESSION inside a valid
> session so that the SEQUENCE op will renew the lease on the clientid. This
> test may take sufficient time on some servers to have the unconfirmed
> clientid expire, requiring setting a long lease period for testing that
> impacts the overall run time.
> 
> Thanks
> 
> Frank
> 
> 
> ---
> This email has been checked for viruses by Avast antivirus software.
> https://www.avast.com/antivirus
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
