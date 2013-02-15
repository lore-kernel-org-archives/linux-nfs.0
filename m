Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440Ab3BOVpt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 16:45:49 -0500
Message-ID: <511EAC8B.3050403@RedHat.com>
Date: Fri, 15 Feb 2013 16:45:47 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: V4 unmount causes a GETATTR
References: <511E5838.2020103@RedHat.com> <20130215182531.GB19923@fieldses.org>
In-Reply-To: <20130215182531.GB19923@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 15/02/13 13:25, J. Bruce Fields wrote:
> On Fri, Feb 15, 2013 at 10:46:00AM -0500, Steve Dickson wrote:
>> Hello,
>>
>> I have not tracked down as to the exact reason, 
>> but it appears umount of v4 file system cause the
>> directory to be revalidating causing the  GETATTR. 
>>
>> Is this revalidation really necessary on an unmount? 
> 
> I don't know, maybe not.  But even if it's not, there are other things
> (like cleaning up state) that the client will likely try to do on
> unmount.  In the presence of delegations it could have dirty data that
> it's required to write back even if applications don't currently hold
> any open files.
Understood with dirty data... but what I as seeing was a v4 mount and
then a reboot with no activity on the mount point... 

> 
> So I don't think we can promise umount will work without the network.
Again with open files (aka activity on the mount point) I agree but
with no activity or open files, I'm think that GETATTR is simply not
necessary... 

steved.
