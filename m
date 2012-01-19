Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:47847 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755432Ab2ASPuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 10:50:07 -0500
Date: Thu, 19 Jan 2012 16:49:51 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Michael Schwartzkopff <misch@schwartzkopff.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 and high-availability
Message-ID: <20120119154951.GV10362@ics.muni.cz>
References: <20120119135044.GS10362@ics.muni.cz>
 <201201191552.30691.misch@schwartzkopff.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <201201191552.30691.misch@schwartzkopff.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 19, 2012 at 03:52:30PM +0100, Michael Schwartzkopff wrote:
> Yes. You can setup a NFSv4 cluster using a cluster manager like pacemaker.
> 
> Last time I set it up there were some issues with locking and timeouts. I 
> don't know if this is already fixed. I'd have to try it myself again.

but this seems to be the mentioned server side HA mode. But can I move running
client to another server (with anoter different IP)?

-- 
Luká¹ Hejtmánek
