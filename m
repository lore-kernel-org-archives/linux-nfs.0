Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:45788 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab1JaXYh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 19:24:37 -0400
Message-ID: <4EAF2E09.9080000@panasas.com>
Date: Mon, 31 Oct 2011 16:23:53 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Brent Welch <welch@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 1/8] pnfs-obj: Remove redundant EOF from objlayout_io_state
References: <4EAF146D.5060507@panasas.com>  <1320097506-734-1-git-send-email-bharrosh@panasas.com> <1320099857.10028.6.camel@lade.trondhjem.org> <4EAF2521.2010204@panasas.com>
In-Reply-To: <4EAF2521.2010204@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/31/2011 03:45 PM, Boaz Harrosh wrote:
>>
> 
> In files-type reads in a "condense" layout. You should be careful

I meant dense layout. 

And in that case I think only the MDS knows the actual file-size. Because at
any given time a DS can never tell if it is the last one in the stripe, and
neither can any given client.

> because in striping it is common place to have eof on some DSs because
> of file holes even though there are more bits higher on in the file
> at other DSs. You should check to return back only the answer from the
> highest logical read DS. (Or I'm wrong in my interpretation?)
> 
> Thanks
> Boaz

