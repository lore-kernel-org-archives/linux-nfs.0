Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:48264 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab3JVDT0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 23:19:26 -0400
Message-ID: <5265EE9B.9070505@candelatech.com>
Date: Mon, 21 Oct 2013 20:18:51 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Weston Andros Adamson <dros@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
References: <52659D69.1020609@candelatech.com> <4682F017-7329-4690-B336-233DB50537F0@netapp.com> <5265BECD.1060601@candelatech.com> <20131022002051.GA13539@umich.edu>
In-Reply-To: <20131022002051.GA13539@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/21/2013 05:20 PM, Jim Rees wrote:
> Possibly dumb question, are you sure your srcaddr option works for all
> protocols involved, including portmap, mount, and nfs?

Well, I'm not sure, but it has been working pretty well so far.  I
could have missed something when porting to the 3.9 kernel, as these
problems appear to be regressions since older code was working...

Thanks,
Ben



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

