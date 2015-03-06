Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752786AbbCFQxc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2015 11:53:32 -0500
Message-ID: <54F9DB83.7050004@RedHat.com>
Date: Fri, 06 Mar 2015 11:53:23 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?WmJpZ25pZXcgSsSZZHJ6ZWpld3NraS1Tem1law==?=
	<zbyszek@in.waw.pl>
CC: Andrei Borzenkov <arvidjaar@gmail.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH] systemd: Have rpc-statd-notify.service
 Require network.target
References: <1425407803-5278-1-git-send-email-steved@redhat.com> <20150303220657.6ba6011b@opensuse.site> <20150303191803.GK3058@in.waw.pl> <54F62994.9020203@RedHat.com> <20150303225132.GL3058@in.waw.pl>
In-Reply-To: <20150303225132.GL3058@in.waw.pl>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/03/2015 05:51 PM, Zbigniew Jędrzejewski-Szmek wrote:
> On Tue, Mar 03, 2015 at 04:37:24PM -0500, Steve Dickson wrote:
>>
>>
>> On 03/03/2015 02:18 PM, Zbigniew Jędrzejewski-Szmek wrote:
>>> On Tue, Mar 03, 2015 at 10:06:57PM +0300, Andrei Borzenkov wrote:
>>> Indeed. From the man page:
>>> -m retry-time
>>>     Specifies the length of time, in minutes, to continue retry‐
>>>     ing  notifications to unresponsive hosts.  If this option is
>>>     not specified, sm-notify attempts to send notifications  for
>>>     15  minutes.   Specifying  a  value of 0 causes sm-notify to
>>>     continue sending notifications to unresponsive  peers  until
>>>     it is manually killed.
>>>
>>>     Notifications  are retried if sending fails, the remote does
>>>     not respond, the remote's NSM service is not registered,  or
>>>     if  there  is  a  DNS  failure  which  prevents the remote's
>>>     mon_name from being resolved to an address.
>>>
>>> So rpc-statd-notify.service should be fine with being started before
>>> the network is up at all.
>> Right... that's the point... we want the service to fork and keep trying
>> in the background.... 
> ...so like Andrei wrote, the dependency on network.target can be removed
> (I wasn't sure if it was clear what I meant).
I did miss the fact you guys were saying because of the 15min retry
network.target is not needed... But, in reality, a network is needed/wanted
so leaving it in will document that fact w/out causing any delay.

steved.
