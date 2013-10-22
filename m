Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:42788 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024Ab3JVM4U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 08:56:20 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: Jim Rees <rees@umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
Date: Tue, 22 Oct 2013 12:56:18 +0000
Message-ID: <249B6AE5-BE15-4503-819E-C81C55CC7EFD@netapp.com>
References: <52659D69.1020609@candelatech.com>
 <4682F017-7329-4690-B336-233DB50537F0@netapp.com>
 <5265BECD.1060601@candelatech.com> <20131022002051.GA13539@umich.edu>
 <5265EE9B.9070505@candelatech.com>
In-Reply-To: <5265EE9B.9070505@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Are you sure you don't have any firewall rules (remember ip6tables != iptables) blocking nfs, mount, portmap, etc?

We should be able to narrow things down when we see the outputs I asked for (rpcdebug, mount -v).

-dros

On Oct 21, 2013, at 11:18 PM, Ben Greear <greearb@candelatech.com>
 wrote:

> On 10/21/2013 05:20 PM, Jim Rees wrote:
>> Possibly dumb question, are you sure your srcaddr option works for all
>> protocols involved, including portmap, mount, and nfs?
> 
> Well, I'm not sure, but it has been working pretty well so far.  I
> could have missed something when porting to the 3.9 kernel, as these
> problems appear to be regressions since older code was working...
> 
> Thanks,
> Ben
> 
> 
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 

