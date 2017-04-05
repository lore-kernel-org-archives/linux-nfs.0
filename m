Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay2.pub.mailoutpod1-wdc1.one.com ([104.37.35.57]:18118
        "EHLO mailrelay2.pub.mailoutpod1-wdc1.one.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933457AbdDEKyj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Apr 2017 06:54:39 -0400
Subject: Re: Bug#852395: unblock: gssproxy/0.5.1-2
To: 852395@bugs.debian.org, Daniel Pocock <daniel@pocock.pro>,
        Robbie Harwood <rharwood@club.cc.cmu.edu>
References: <148524180980.26332.422684345851896222.reportbug@kirtar>
 <8ed20c71-d7e2-72e1-a8ce-c913f8e0fffd@thykier.net>
 <17e5fbd0-9bb1-d7fa-6056-8adbda8a1f4d@pocock.pro>
 <e157cdda-35b6-8643-7d9f-da79faec56f7@thykier.net>
 <e157cdda-35b6-8643-7d9f-da79faec56f7@thykier.net>
 <5df78805-b791-0a5e-3dcb-99792d78c3bd@thykier.net>
 <f4e3252f-0115-954d-5749-c330c6905b75@pocock.pro>
 <87o9wwcz8j.fsf@notabene.neil.brown.name>
Cc: Debian kernel team <debian-kernel@lists.debian.org>, daf@debian.org
From: Niels Thykier <niels@thykier.net>
Message-ID: <a2f29e78-6652-e184-16c8-e68d49c639c6@thykier.net>
Date: Wed, 05 Apr 2017 10:37:00 +0000
MIME-Version: 1.0
In-Reply-To: <87o9wwcz8j.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown:
> On Sun, Mar 05 2017, Daniel Pocock wrote:
> 
>> [...]
> 
> Yes, they can.
> The systemd unit files are designed so that svcgssd will only be started
> if gssproxy didn't start - and gssproxy is tried first.
> 
> If you use something other than systemd, similar logic would be needed.
> 
> NeilBrown
> 
> 
> [...]

Hi,

@Neil: Thanks for the clarification. :)  I am taking you and linux-nfs
off again (BCC'ed) as I assumed the rest follows from here are less like
to be relevant for you.

@Robbie: Can you clarify what happens for people who have chosen to use
sysvinit as init system?  Will they end up with gssproxy or svcgssd or a
broken NFS?

Thanks,
~Niels


