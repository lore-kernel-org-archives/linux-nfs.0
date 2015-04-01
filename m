Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:36237 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbDAS7t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 14:59:49 -0400
Received: by yhjf44 with SMTP id f44so14867197yhj.3
        for <linux-nfs@vger.kernel.org>; Wed, 01 Apr 2015 11:59:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150401185146.GE3040@fieldses.org>
References: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
	<1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
	<20150401175437.GD3040@fieldses.org>
	<1427911337.1794160.248190485.1F161545@webmail.messagingengine.com>
	<20150401185146.GE3040@fieldses.org>
Date: Wed, 1 Apr 2015 14:59:48 -0400
Message-ID: <CAHQdGtT2ved_4xRQMyxuWfHAr8mci+unxfXsgv3YX7cJ4NCRBQ@mail.gmail.com>
Subject: Re: file xfer over NFSv4 with 'sync' ~300X slower than with 'async' ?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: lyndat3@your-mail.com, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 1, 2015 at 2:51 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Apr 01, 2015 at 11:02:17AM -0700, lyndat3@your-mail.com wrote:
>> > There's no maximum sync/async ratio.  You could make that ratio lower or
>> > higher by varying dd's block size, for example.
>> >
>> > The way I'd look at it, your dd of a 100MB file above is doing 3072
>> > writes, and taking about 8*60/3072 =~ .16 seconds per write.
>> >
>> > That does sound high.  Things to look at to understand why might include
>> > the round-trip ping time to the server, and the time for the server's
>> > disk to do a synchronous write.
>> >
>>
>> After comments from one of the nfs client maintainers, it turns out the slowness issue is simply one of not-quite-MIS-configuration.
>>
>> As helpfully commented here
>>
>>   http://serverfault.com/questions/499174/etc-exports-mount-option/500553#500553
>>
>> , IIUC there are two *separate* syncs to consider -- at the server, and at the client.
>>
>> 'sync' on the EXPORT, and 'async' on the MOUNT is the sane approach; That config also appears to return the performance.
>>
>> The many recommendations online to use 'sync' for data integrity are IIUC for sync on the server.
>
> Yes.  This is a common source of confusion.  In retrospect maybe the
> export sync/async option should have had a different name from the
> client mount option.--b.
>

Do we still need a server 'async' export option? Who is still using
NFSv2 for any type of performance-critical work?

Trond
