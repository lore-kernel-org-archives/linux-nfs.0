Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53008 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754318Ab2JORnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 13:43:06 -0400
Date: Mon, 15 Oct 2012 13:43:05 -0400
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 monitoring tool
Message-ID: <20121015174305.GA26840@fieldses.org>
References: <20121015163851.GO5412@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121015163851.GO5412@ics.muni.cz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 15, 2012 at 06:38:51PM +0200, Lukas Hejtmanek wrote:
> Hello,
> 
> is there any NFSv4 monitoring tool, that can be run on NFSv4 server (running
> NFSv4.0 + GSS) and that reports statistics per connected client? I would like
> to see amount of transfered data for each client, latency of RPC calls, rate
> of requests.
> 
> nfsstat on server does not distinguish individual clients. 
> nfswatch does not support NFSv4
> 
> I didn't find anything else. Do I need to create the tool by myself or is
> there free of paid tool thad does the job?

We don't gather such statistics, unfortunately.  I agree that it would
be useful, and would be happy to talk about possible implementations

--b.
