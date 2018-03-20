Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:43085 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752142AbeCTLJH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 07:09:07 -0400
Subject: Re: running NFS in LXC
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
 <6860CF8E-9790-4456-82D3-86A6A29E90BE@redhat.com>
 <8af7b137-0698-0c12-abc5-1cdd86c53a91@aixigo.de>
 <F9942544-0C31-4618-BF73-292FF4265C31@redhat.com>
 <20180215154516.GB9999@fieldses.org>
From: Harald Dunkel <harald.dunkel@aixigo.de>
Message-ID: <a44bbfe5-b40e-620b-4dfb-ecc5380e4bae@aixigo.de>
Date: Tue, 20 Mar 2018 12:09:05 +0100
MIME-Version: 1.0
In-Reply-To: <20180215154516.GB9999@fieldses.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi JB,

On 02/15/18 16:45, J. Bruce Fields wrote:
> 
> Harald is talking about LXC, and there are still a few problems there.
> 
> Jeff, do you object to going back to our plan B for reboot recovery (the
> daemon)?  The usermode helper containerization seems stalled and I have
> to admit I'm probably not going to take it on myself.  That might be the
> only knfsd-in-a-container obstacle left.
> 

I have no clue about plan B, but it would be very nice if this feature
(running NFServer in a container) could be completed.


Regards
Harri
