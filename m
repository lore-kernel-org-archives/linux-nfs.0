Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44755 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757259Ab1ERQMk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 12:12:40 -0400
Date: Wed, 18 May 2011 12:12:39 -0400
To: Taousif_Ansari@DELLTEAM.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: Performance Issue with multiple dataserver
Message-ID: <20110518161239.GA16835@fieldses.org>
References: <4DD2A084.1040905@moving-picture.com>
 <20110518080106.1159c5b8@notabene.brown>
 <4DD39D39.7010805@moving-picture.com>
 <A1A98FD909DC5248811A65C5D18E9C761DF69B1F18@BLRX7MCDC202.AMER.DELL.COM>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A1A98FD909DC5248811A65C5D18E9C761DF69B1F18@BLRX7MCDC202.AMER.DELL.COM>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

You sent this message as a reply to an unrelated message, which is
confusing to those of us with threaded mail readers.

On Wed, May 18, 2011 at 05:24:45PM +0530, Taousif_Ansari@DELLTEAM.com wrote:
> I have done pNFS setup with single Dataserver and Two Dataserver and ran the IOzone tool on both, I found that the performance with multiple dataservers is less than the performance with single dataservers.

What are you using as the server, and what as the client?

--b.

> 
> Here are some numbers, which were captured by the IOzone tool.
> 
> 
> 							  4	  8	 16	 32	 64	 128	 256	 512	1024	<== Record Length in KB
> With Single Dataserver:
> Read operation for file size 1 MB-		66415	66359	63630	70358	86223	70256	66047	66068	68489	<== IO kB/sec
> Write operation for file size 1 MB-		18827	16920	18846	17039	18896	17009	17173	19206	17947	<== IO kB/sec
> 
> With Two Dataservers :
> Read operation for file size 1 MB-		36882	381198	38150	38084	38749	33663	34398	37313	37847	<== IO kB/sec
> Write operation for file size 1 MB-		5461	4661	5586	4870	5227	4922	4214	5572	4658	<== IO kB/sec
> 
> 
> Can somebody tell me What could be the issue....
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
