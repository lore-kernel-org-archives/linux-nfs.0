Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:20137 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823Ab3J2NAv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 09:00:51 -0400
Message-ID: <526FB180.1060003@netapp.com>
Date: Tue, 29 Oct 2013 09:00:48 -0400
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com> <1382972247-1108-5-git-send-email-bjschuma@netapp.com> <20131029073558.GA10889@infradead.org>
In-Reply-To: <20131029073558.GA10889@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 29 Oct 2013 03:35:58 AM EDT, Christoph Hellwig wrote:
> On Mon, Oct 28, 2013 at 10:57:26AM -0400, Anna Schumaker wrote:
>> This patch adds in the SEEK operation used by clients doing an llseek on
>> a file to find either hole or data sections in a file.  I'm faking the
>> "allocated" status right now, since I haven't quite figured out how to
>> tell if a range is allocated on disk yet.
>>
>> This patch is missing correctly determining the "allocated" status of
>> the HOLE / DATA range.  I expect I'll need to learn all about how fiemap
>> works before properly setting these values.
>
> What is the definition of allocated in this context?  Specificly how
> does it different from meaning of allocated as used by SEEK_DATA?

 From what I can tell, I think the allocated flag will just tell the 
clients if all the blocks exist on disk or not.  Is there a way to have 
a hole with allocated blocks?  Or maybe it's supposed to represent 
partially allocated blocks?  I checked the draft, and it doesn't 
actually say what they expect allocated to represent...

>
> Going out to fiemap is something we should absolutely avoid.
>


