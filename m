Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4939 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757166Ab0KJXBZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 18:01:25 -0500
Subject: Re: [PATCH 0/9] treewide: convert vprintk uses to %pV
From: Joe Perches <joe@perches.com>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        cluster-devel@redhat.com, linux-nilfs@vger.kernel.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTinhcbdm8YQOrFVdONODo6K6PcxHYtx5vqnap_3T@mail.gmail.com>
References: <cover.1289348757.git.joe@perches.com>
	 <AANLkTinhcbdm8YQOrFVdONODo6K6PcxHYtx5vqnap_3T@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 15:01:23 -0800
Message-ID: <1289430083.15905.106.camel@Joe-Laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-11-10 at 14:48 -0800, Luis R. Rodriguez wrote:
> When was this added upstream BTW? I ask for backport considerations.

commit 7db6f5fb65a82af03229eef104dc9899c5eecf33
Author: Joe Perches <joe@perches.com>
Date:   Sun Jun 27 01:02:33 2010 +0000

    vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
    
    Add the ability to print a format and va_list from a structure pointer
    
    Allows __dev_printk to be implemented as a single printk while
    minimizing string space duplication.
    
    %pV should not be used without some mechanism to verify the
    format and argument use ala __attribute__(format (printf(...))).
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>


