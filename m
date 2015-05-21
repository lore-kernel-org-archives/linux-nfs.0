Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:57141 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503AbbEUIjh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2015 04:39:37 -0400
Date: Thu, 21 May 2015 14:09:24 +0530 (IST)
From: Govindarajulu Varadarajan <_govind@gmx.com>
To: Josef Bacik <jbacik@fb.com>
cc: Govindarajulu Varadarajan <_govind@gmx.com>, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, clm@fb.com,
        dsterba@suse.cz
Subject: Re: btrfs: kernel BUG at mm/page-writeback.c:2286!
In-Reply-To: <555B3B5D.7040601@fb.com>
Message-ID: <alpine.LNX.2.03.1505211407010.19285@ws.cisco>
References: <alpine.LNX.2.03.1505191317300.21108@ws.cisco> <555B3B5D.7040601@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 May 2015, Josef Bacik wrote:

> On 05/19/2015 03:55 AM, Govindarajulu Varadarajan wrote:
>> Hi all
>> 
>> I am seeing the following crash on my btrfs filesystem with nfs export.
>> If I disable the nfs share and reboot, I do not hit the crash. Look like
>> the crash happens on btrfs with nfs export.
>> 
>> Is this a known issue? Has anyone else faced this? Let me know if you
>> need more
>> information.
>> 
>
> Somebody else is unlocking the page while we have it locked (by somebody else 
> I mean somebody other than in this particular code path, so could totally 
> still be us, it's just not obvious.)  What are your mount options?  Are you 
> capable of building your own kernel?  A git bisect would be good to try and 
> find where the problem was introduced, seems like it's easy to reproduce. 
> I'll look through our recent commits and see if anything pops out.  Thanks,
>

Yes, I can do git bisect. But, now that I have deleted the file with csum error
I do not see the crash any more. Sorry.

Is there any was to introduce
"BTRFS info (device sdf): csum failed ino 1154 extent 4434247680 csum 1388825687 wanted 0 mirror 0"?
