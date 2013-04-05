Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:55226 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161308Ab3DEMse (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 08:48:34 -0400
Date: Fri, 5 Apr 2013 14:48:22 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 monitoring tool
Message-ID: <20130405124822.GB25618@ics.muni.cz>
References: <20121015163851.GO5412@ics.muni.cz>
 <20121015174305.GA26840@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20121015174305.GA26840@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon, Oct 15, 2012 at 01:43:05PM -0400, J. Bruce Fields wrote:
> > is there any NFSv4 monitoring tool, that can be run on NFSv4 server (running
> > NFSv4.0 + GSS) and that reports statistics per connected client? I would like
> > to see amount of transfered data for each client, latency of RPC calls, rate
> > of requests.
> > 
> > nfsstat on server does not distinguish individual clients. 
> > nfswatch does not support NFSv4
> > 
> > I didn't find anything else. Do I need to create the tool by myself or is
> > there free of paid tool thad does the job?
> 
> We don't gather such statistics, unfortunately.  I agree that it would
> be useful, and would be happy to talk about possible implementations

so we decided to implement this using systemtap tool and it works ok. But if
NFS server could provide statistics by itself, it would be far better.

-- 
Luká¹ Hejtmánek
