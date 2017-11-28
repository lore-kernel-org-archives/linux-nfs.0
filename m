Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58350 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753230AbdK1Pz7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Nov 2017 10:55:59 -0500
Date: Tue, 28 Nov 2017 10:55:58 -0500
To: Orion Poplawski <orion@nwra.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Strange NFS4 permission problem
Message-ID: <20171128155558.GA3828@fieldses.org>
References: <c2dadd74-4981-5069-84f1-325ff2babd03@nwra.com>
 <a21c58c0-29b2-5053-8ab9-0991a8e8610e@nwra.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a21c58c0-29b2-5053-8ab9-0991a8e8610e@nwra.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 28, 2017 at 07:47:57AM -0700, Orion Poplawski wrote:
> On 11/27/2017 04:28 PM, Orion Poplawski wrote:
> > I have a kerberized NFS4 setup using EL7.4 that has been working for quite a
> > long time.  Today I started having trouble with permissions from some clients.
> >  I haven't been able to figure out what changed.
> > 
> > It appears though that some requests are being sent as root as so permission
> > to access is denied.
> 
> 
> This appears to be caused by BitDefender anti-virus.

Thanks for following up.--b.
