From: Jeff Garzik <jeff@garzik.org>
Subject: Re: pynfs and server attributes?
Date: Mon, 10 Dec 2007 17:19:19 -0500
Message-ID: <475DBB67.4030001@garzik.org>
References: <475DAFF9.3090206@garzik.org> <Pine.BSO.4.64.0712101633470.15300@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Fredric Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54825 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbXLJWTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 17:19:20 -0500
In-Reply-To: <Pine.BSO.4.64.0712101633470.15300@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fredric Isaman wrote:
> On Mon, 10 Dec 2007, Jeff Garzik wrote:
> 
>> Is there a pynfs list somewhere?
>>
> 
> Not that I know of.
> 
> 
>> The pynfs tests for too-long strings, too-long reads and writes do not 
>> seem to take into account maxname, maxread and maxwrite attributes.
>>
>> I actually have to _increase_ the python "longname" test variable in 
>> order for the test to behave properly on my server :)
>>
>>     Jeff
> 
> 
> The fixed (but easily changeable) "longname" was intentional in order to 
> avoid test dependencies on GETATTR, and non-mandatory attributes at that.
> 
> Would making the length of longname a command line option be useful?


Definitely.  That, and the max-read and max-write attributes.

There is at least one test that issues a WARNING when my server returns 
128k (its max read size) rather than the requested 9000000 count.

I have not investigated that yet, but I was sorta assuming that my 
server was behaving correctly in that case.

	Jeff



