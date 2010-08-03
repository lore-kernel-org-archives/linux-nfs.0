Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:46371
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754466Ab0HCUN3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 16:13:29 -0400
Date: Tue, 3 Aug 2010 22:13:18 +0200
From: Michael Guntsche <mike@it-loops.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberos auth Problem with nfs3/4
Message-ID: <20100803201318.GA1623@gibson.comsick.at>
References: <20100803154556.GA6262@gibson.comsick.at>
 <20100803194342.GE31579@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100803194342.GE31579@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03 Aug 10 15:43, J. Bruce Fields wrote:
> On Tue, Aug 03, 2010 at 05:45:56PM +0200, Michael Guntsche wrote:
> > Hi,
> > 
> > I recently tried re-enabling a kerberos setup here after running with
> > sec=sys for a while. Now the problem is that mount the export with
> > sec=krb5 just hangs.
> > 
> > To rule everything out I tried mount from the server itself.
> > 
> > mount gibson:/export /mnt
> > 
> > The mount just hangs and does not return.
> > This is happening on a debian sid system with nfs-utils 1.2.2 installed.
> 
> You might try the following (in upstream nfs-utils)?
> 
> --b.
> 
> commit 6ca440c2661dccb05ae74ffb65817e9c30f05c8a
> Author: Steve Dickson <steved@redhat.com>
> Date:   Mon Mar 8 11:22:46 2010 -0500

Hello Bruce,

Yes, this fixed the problem. I recompiled with the patch applied and
installed the new binaries on the server. Now mounting both nfs3 and
nfs4 with sec=krb5 works again. Will there a 1.2.3 release in the near
future, otherwise I will file a bug with debian to ask them to include
the patch in their package.

Thank you very much for the quick fix.

Kind regards,
Michael
