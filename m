From: Peter Staubach <staubach@redhat.com>
Subject: Re: Apparent race condition w/ NFSv3 mktemp+write+rename
Date: Tue, 24 Nov 2009 15:30:47 -0500
Message-ID: <4B0C4277.8050004@redhat.com>
References: <hehc8g$k8f$1@ger.gmane.org> <4B0C3BF8.1070904@redhat.com> <4B0C4116.10903@dyfis.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Charles Duffy <charles-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932833AbZKXUam (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 15:30:42 -0500
In-Reply-To: <4B0C4116.10903-7s4ginpmXnFeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Charles Duffy wrote:
> Peter Staubach wrote:
>> At the end, does /mnt/foobar exist and contain the string, "baz"?
>>   
> I'll follow up with that information with that after the issue is next
> reproduced. (The mv operation is replacing a prior instance of
> /mnt/foobar, so content will need to be inspected to determine whether
> it was successful).
> 
>> What mount options are being used on the client?
>>   
> rw,vers=3,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=<redacted>
> 

Hmmm.  This appears to be the defaults.

Does this take a very long time to run when it fails like this?

	Thanx...

		ps
