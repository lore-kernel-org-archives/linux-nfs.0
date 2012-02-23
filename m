Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:53019 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032Ab2BWPnC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 10:43:02 -0500
Message-ID: <4F465E76.4000201@steve-ss.com>
Date: Thu, 23 Feb 2012 16:42:46 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Subject: Re: NFSv4 client restriction
References: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com> <20120223010111.GA19432@fieldses.org> <4F45E63B.9090608@steve-ss.com> <4F464A4A.10403@fifthhorseman.net>
In-Reply-To: <4F464A4A.10403@fifthhorseman.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/23/2012 03:16 PM, Daniel Kahn Gillmor wrote:
> On 02/23/2012 02:09 AM, steve wrote:
>> It is not recommended to use the pseudoroot fsid=0 stuff for Linux.
>>
>> See the nfs wiki: 'The linux implementation allows you to designate a
>> real filesystem as the pseudofilesystem, identifying that export with
>> the fsid=0 option; we no longer recommend this. Instead, on any recent
>> linux distribution, just list exports in /etc/exports exactly as you
>> would for NFSv2 or NFSv3.'
> I believe the last time this came up, i asked for a rationale or
> explanation.  The only reason given [0] was from J. Bruce Fields:
I've never got to the bottom of this one either. I only know that it works.
>>> The main problem with the fsid=0 trick is that your v3 and v4 clients
>>> end up with different paths.
But if say, you're exporting /home and have /home bind mounted to your 
pseudoroot, then the paths are exactly the same. You still mount -t nfsx 
server:/home /client/somewhere for x=3 or x=4. No?
> So, if you have no v3 clients, i don't think there is any reason to
> avoid fsid=0 if it makes things cleaner for you.  And removing fsid=0
> will require you to change /etc/fstab (or your automounter config) in
> all of your clients.
Please accept my apologies for butting in on this. I'm simply trying to 
get some facts together.
Cheers,
Steve
