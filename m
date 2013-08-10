Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.xtronics.com ([139.146.185.26]:60810 "EHLO
	smtp.xtronics.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184Ab3HJTn6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Aug 2013 15:43:58 -0400
Message-ID: <520697DC.1030500@xtronics.com>
Date: Sat, 10 Aug 2013 14:43:24 -0500
From: Karl Schmidt <karl@xtronics.com>
MIME-Version: 1.0
To: Christian Kujau <lists@nerdbynature.de>
CC: Ben Hutchings <ben@decadent.org.uk>, 714974@bugs.debian.org,
        jfs-discussion@lists.sourceforge.net,
        Jonathan McDowell <noodles@earth.li>, linux-nfs@vger.kernel.org
Subject: Re: [Jfs-discussion] NFS 'readdir loop' error on JFS
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
In-Reply-To: <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2013 02:28 AM, Christian Kujau wrote:
> Interesting stuff. Out of curiosity I just tried this myself, both client
> & server are virtual machines running Debian/stable (3.2.0-4-amd64) and I
> was able to reproduce this. A test case would be:
>

I still haven't rebooted that machine - last chance to ask for any test info - as it looks like you 
have a test case anyway.

I haven't lost any data that I know of  - just programs complaining etc.

IMO, at one time, jfs was really a better choice ( good set of tools). Even in a few cases where 
hardware failed the jfs tools worked well. Today with everyone banging on ext4 it has become the 
better choice. ( I don't think IBM is interested in supporting jfs - no idea if they are phasing out 
jfs2? ).




--------------------------------------------------------------------------------
Karl Schmidt                                  EMail Karl@xtronics.com
Transtronics, Inc.                              WEB http://secure.transtronics.com
3209 West 9th Street                             Ph (785) 841-3089
Lawrence, KS 66049                              FAX (785) 841-0434

The world runs on individuals pursuing their separate interests.
The great achievements of civilization have not come from
government bureaus. Einstein didn’t construct his theory under
order from a bureaucrat. Henry Ford didn’t revolutionize the
automobile industry that way.
--------------------------------------------------------------------------------
