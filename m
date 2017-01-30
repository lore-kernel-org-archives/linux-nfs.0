Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45428 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754009AbdA3TRT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 14:17:19 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Matthieu Herrb" <matthieu.herrb@laas.fr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: problem with open(name, O_RDWR|O_CREAT|O_EXCL, 0666) on NetApp
 servers
Date: Mon, 30 Jan 2017 13:55:37 -0500
Message-ID: <2D5DF759-27DB-4E09-AC05-423B44BE645D@redhat.com>
In-Reply-To: <20170130142511.GC25669@paperthin-usb.laas.fr>
References: <20170105142439.GB9922@paperthin-usb.laas.fr>
 <45F25643-F51D-4CA0-AC7D-55B6D6D6FE22@redhat.com>
 <20170130142511.GC25669@paperthin-usb.laas.fr>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 30 Jan 2017, at 9:25, Matthieu Herrb wrote:

> On Tue, Jan 24, 2017 at 11:48:33AM -0500, Benjamin Coddington wrote:
>> Hi Matthieu, are you willing to test this one:
>>
>> http://marc.info/?l=linux-nfs&m=148527567624411&w=2
>>
>
> Hi,
>
> sorry for the delay in answering. This patch does fix the problem for
> my  configuration.

Thanks for the test.  This patch went into linux in commit
a430607b2ef7c3be090f88c71cfcb1b3988aa7c0.

Ben
