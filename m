Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40818 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752166AbdJ3P3q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 11:29:46 -0400
Subject: Re: [PATCH] nfs-utils: display NFS RPC queue time for mountstats and
 nfs-iostat
To: Ryan Doyle <rdoyle@aconex.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <MEXPR01MB0711C64DC23E94EE366C5455A2590@MEXPR01MB0711.ausprd01.prod.outlook.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <60e01567-070d-c7db-b26f-b290df0d3cc0@RedHat.com>
Date: Mon, 30 Oct 2017 11:29:45 -0400
MIME-Version: 1.0
In-Reply-To: <MEXPR01MB0711C64DC23E94EE366C5455A2590@MEXPR01MB0711.ausprd01.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/29/2017 11:30 PM, Ryan Doyle wrote:
> Hi there
> 
> I've got a patch to display the NFS queue statistics for mountstats and nfsiostat exported in /proc/self/mountstats. The RTT and total execution time is currently displayed but I think it's also useful displaying how long the task was queued for too. If others agree, please feel free to apply it.

In the future please use the proper format for posting
a patch that is described in 
    https://www.kernel.org/doc/html/v4.12/process/submitting-patches.html

Basically, inline the patch, have a subject and description
section and a proper Signed-off-by: line. But since I 
found another bug while testing your patch and I'm about
to make a release I'll go ahead and add the Signed-off-by: line

Patch committed! 

steved.
