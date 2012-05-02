Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38664 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756261Ab2EBTrS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 May 2012 15:47:18 -0400
Received: by wibhj6 with SMTP id hj6so5105712wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 May 2012 12:47:17 -0700 (PDT)
Message-ID: <4FA18F41.7030901@tonian.com>
Date: Wed, 02 May 2012 22:47:13 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Zack Perry <zack.perry@sbcglobal.net>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: To start testing Linux pNFS server?
References: <1335818012.19482.YahooMailClassic@web181020.mail.ne1.yahoo.com>
In-Reply-To: <1335818012.19482.YahooMailClassic@web181020.mail.ne1.yahoo.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi, sorry for the late reply, and thanks Bruce!
The linux-pnfs tree is here:
git://linux-nfs.org/~bhalevy/linux-pnfs.git

What layout type are you interested to test?
Currently, the block layout back-end is not in an operational state and unfortunately
it's not actively maintained.

For the files layout, as Bruce mentioned, you can use the gfs2-based server that does
parallel reads, but writes only via the MDS, and the pnfsd-lexp (local export) testing
back end that exports a local file system over pnfs, playing both the MDS and a single DS
on the server.

The objects layout can be tested using the pnfsd-exofs back end, which is the most complete
implementation right now.  Again, as Bruce correctly pointed out :)
Boaz Harrosh <bharrosh@panasas.com> would be able to help you with that.

Benny

On 2012-04-30 23:33, Zack Perry wrote:
> Hi Bruce,
> 
> Thanks for your suggestion.
> 
> Zack
> 
>>
>> My impression is that the most likely to work possibilities
>> are either the exofs-based or gfs2-based servers.  Boaz Harosh
>> might be able to help with the latter.  I don't know if the wiki
>> instructions are up to date.  You probably need to build a kernel
>> from Benny's git tree in either case.
>>
>> --b.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
