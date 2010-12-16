Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:46713 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849Ab0LPXYl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 18:24:41 -0500
Received: by qyk12 with SMTP id 12so107832qyk.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Dec 2010 15:24:40 -0800 (PST)
Message-ID: <4D0A9FB6.7040503@gmail.com>
Date: Thu, 16 Dec 2010 18:24:38 -0500
From: Ric Wheeler <ricwheeler@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Steve Dickson <SteveD@redhat.com>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net> <4D0A6503.7010901@RedHat.com> <20101216230524.GA16760@infradead.org> <4D0A9D5A.1070708@gmail.com> <20101216231626.GA24880@infradead.org>
In-Reply-To: <20101216231626.GA24880@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 12/16/2010 06:16 PM, Christoph Hellwig wrote:
> On Thu, Dec 16, 2010 at 06:14:34PM -0500, Ric Wheeler wrote:
>> This is not us trying to block anything, just do an orderly testing of changes.
>>
>> Why do three "waves" of pNFS related changes and refactor code all at once?
> Because some forces seem to force pnfs into the kernel despite neither
> beeing ready nor overly useful.  If you look at the userbase of the
> Linux NFS client a robust XDR encode/decoder without buffer overflows is
> a lot more important than a partially working pNFS client.

I think that the pNFS features are actually quite useful and do have a pull with 
the user base. Not to knock the XDR work but I would put it behind the current 
churn.

If you look at the number of pNFS commits from the NFS developers, clearly pNFS 
is important to many of them (and/or their employers of course :))

Ric

