Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:61797 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753623AbbESNc1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2015 09:32:27 -0400
Message-ID: <555B3B5D.7040601@fb.com>
Date: Tue, 19 May 2015 09:32:13 -0400
From: Josef Bacik <jbacik@fb.com>
MIME-Version: 1.0
To: Govindarajulu Varadarajan <_govind@gmx.com>, <linux-btrfs@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC: <clm@fb.com>, <dsterba@suse.cz>
Subject: Re: btrfs: kernel BUG at mm/page-writeback.c:2286!
References: <alpine.LNX.2.03.1505191317300.21108@ws.cisco>
In-Reply-To: <alpine.LNX.2.03.1505191317300.21108@ws.cisco>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/19/2015 03:55 AM, Govindarajulu Varadarajan wrote:
> Hi all
>
> I am seeing the following crash on my btrfs filesystem with nfs export.
> If I disable the nfs share and reboot, I do not hit the crash. Look like
> the crash happens on btrfs with nfs export.
>
> Is this a known issue? Has anyone else faced this? Let me know if you
> need more
> information.
>

Somebody else is unlocking the page while we have it locked (by somebody 
else I mean somebody other than in this particular code path, so could 
totally still be us, it's just not obvious.)  What are your mount 
options?  Are you capable of building your own kernel?  A git bisect 
would be good to try and find where the problem was introduced, seems 
like it's easy to reproduce.  I'll look through our recent commits and 
see if anything pops out.  Thanks,

Josef

