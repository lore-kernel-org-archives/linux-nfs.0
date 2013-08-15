Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:47446 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758844Ab3HORdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 13:33:50 -0400
Received: by mail-qc0-f175.google.com with SMTP id s11so543944qcv.20
        for <linux-nfs@vger.kernel.org>; Thu, 15 Aug 2013 10:33:49 -0700 (PDT)
Message-ID: <520D0F23.5070201@gmail.com>
Date: Thu, 15 Aug 2013 13:25:55 -0400
From: Bryan Schumaker <bjschuma@gmail.com>
MIME-Version: 1.0
To: Brian De Wolf <bldewolf@csupomona.edu>
CC: Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS uses wrong domain in SETATTR
References: <20130718174155.0f189280@csupomona.edu> <52015795.9060003@gmail.com> <20130806195327.71323541@csupomona.edu>
In-Reply-To: <20130806195327.71323541@csupomona.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/06/2013 10:53 PM, Brian De Wolf wrote:
> On Tue, 6 Aug 2013 13:07:49 -0700
> Bryan Schumaker <bjschuma@gmail.com> wrote:
> 
>> Hi Brian,
>>
>> I'm sorry it took so long to reply to you, but you haven't been
>> forgotten!  I've set up kerberos using freeipa on my own test system
>> but I haven't been able to reproduce the bug you're seeing.  I had it
>> working by using my kerberos domain set in /etc/idmap.conf and I saw
>> the new domain go over the wire when I changed it in idmap.conf.  Do
>> I need to do anything more to mimic your setup?
>>
> 
> Thanks for responding!  It seems like DNS might be where the wrong
> kerberos domain is coming from.  Is your test client in the same domain
> as your kerberos realm?  My clients aren't, and the subdomain they're
> in is what is sent in the NFS requests.
> 
> I was able to test this by preferring files for hosts in nsswitch.conf
> and overriding the host's name in /etc/hosts.  Normally the host is
> under unx.csupomona.edu.  Moving the host to csupomona.edu in hosts
> (and rebooting) causes chgrp to start working.  When I revert the
> nsswitch and hosts changes chgrp keeps working until another reboot.
> 
> I hope this helps you reproduce this issue.  Let me know if there is
> any other information you need.
> 

Have you made sure to reboot or restart idmapd after making changes to /etc/idmap.conf?  The only time I've been able to reproduce this is when the config file has been changed but not reloaded.

Bryan

