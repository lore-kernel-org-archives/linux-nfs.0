Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642AbaHSOHC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2014 10:07:02 -0400
Message-ID: <53F35A03.1070306@RedHat.com>
Date: Tue, 19 Aug 2014 10:06:59 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] start-statd: clean up output when systemd is
 not installed
References: <1408286648-19031-1-git-send-email-vapier@gentoo.org> <53F23223.5090904@RedHat.com> <1649346.61nAovKFdn@vapier>
In-Reply-To: <1649346.61nAovKFdn@vapier>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/18/2014 07:57 PM, Mike Frysinger wrote:
> On Mon 18 Aug 2014 13:04:35 Steve Dickson wrote:
>> On 08/17/2014 10:44 AM, Mike Frysinger wrote:
>>> If you don't have systemd, then this script dumps:
>>> /usr/sbin/start-statd: line 8: systemctl: command not found
>>>
>>> This isn't terribly useful since we ultimately fall back to running
>>> the daemon ourselves, so probe for systemd's existence before we try
>>> to use it.
>>>
>>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>>
>> Committed... but I used 'rpm -q systemd' instead of 'systemctl --help'
>> to test for the existences of systemd
>>
>>  # First try systemd if it's installed.
>> -if systemctl --help >/dev/null 2>&1; then
>> +if rpm -q systemd > /dev/null 2>&1; then
>>      # Quit only if the call worked.
>>      systemctl start rpc-statd.service && exit
> 
> what about all the other distros not using rpm ?  my version was distro 
> agnostic.
Good point... I just committed your original version... Thanks!

steved.

