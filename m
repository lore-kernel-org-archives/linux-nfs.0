Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40405 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161544Ab3DEM6e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 08:58:34 -0400
Date: Fri, 5 Apr 2013 08:58:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 monitoring tool
Message-ID: <20130405125833.GA1194@fieldses.org>
References: <20121015163851.GO5412@ics.muni.cz>
 <20121015174305.GA26840@fieldses.org>
 <20130405124822.GB25618@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130405124822.GB25618@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 05, 2013 at 02:48:22PM +0200, Lukas Hejtmanek wrote:
> Hello,
> 
> On Mon, Oct 15, 2012 at 01:43:05PM -0400, J. Bruce Fields wrote:
> > > is there any NFSv4 monitoring tool, that can be run on NFSv4 server (running
> > > NFSv4.0 + GSS) and that reports statistics per connected client? I would like
> > > to see amount of transfered data for each client, latency of RPC calls, rate
> > > of requests.
> > > 
> > > nfsstat on server does not distinguish individual clients. 
> > > nfswatch does not support NFSv4
> > > 
> > > I didn't find anything else. Do I need to create the tool by myself or is
> > > there free of paid tool thad does the job?
> > 
> > We don't gather such statistics, unfortunately.  I agree that it would
> > be useful, and would be happy to talk about possible implementations
> 
> so we decided to implement this using systemtap tool and it works ok. But if
> NFS server could provide statistics by itself, it would be far better.

Sure.  If you have a detailed description of the statistics that you're
gathering (and/or the systemtap scripts), that could help make sure we
capture what you need.

--b.
