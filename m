Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:47806 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab3GHPwT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jul 2013 11:52:19 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Fwd: file system deprecation question
From: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 8 Jul 2013 11:52:14 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2D383E44-BBED-4AF8-965A-B2D51F145540@oracle.com>
References: <20130708154340.3855.54970@localhost.localdomain>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I asked a couple of filesystem/kernel higher-ups.

Client: A kernel message at module load time sounds like a good idea, along with a target date when we would consider a "go/no-go" decision for removing NFSv2.  I also agree we should solicit opinion from other Linux distributors.

For the server, similar arrangements for a kernel message might be made.  And a conversation with other NFS storage vendors (for example, at testing events) seems reasonable.


Begin forwarded message:

> From: Chris Mason <chris.mason@fusionio.com>
> Subject: Re: file system deprecation question
> Date: July 8, 2013 11:43:40 AM EDT
> To: Greg KH <gregkh@linuxfoundation.org>, Chuck Lever <chuck.lever@oracle.com>
> 
> Quoting Greg KH (2013-07-08 11:39:31)
>> On Mon, Jul 08, 2013 at 10:30:43AM -0400, Chuck Lever wrote:
>>> Thanks, I've copied Greg.
>>> 
>>> The idea is Linux would prevent the use of the oldest version of NFS.
>>> Only NFSv3 and later would be supported in the client.  The Linux NFS
>>> community doesn't want to bother with NFSv2 any more because they feel
>>> there are very few people using it due to its inherent limitations.
>>> 
>>> Recently Bryan Schumaker did some work to modularize the NFS client so
>>> code specific to each NFS protocol version has been moved to its own
>>> .ko.  I assume we would just move that code to the staging tree, but
>>> it may be more complicated than that.
>> 
>> Yes, you can remove drivers from the kernel tree through staging, but
>> really, it's just as easy for you to delete them entirely if you want to
>> from your directory.
>> 
>> Like Chris said, have them print a big nasty warning every time the
>> driver is loaded for a year or so, then remove it if no one complains.
>> But if someone is still using it, you really can't remove it.  Heck, we
>> still have filesystems that are way older than NFSv2 in the kernel
>> because they have users, I doubt you will be able to drop this code
>> anytime soon, sorry.
> 
> I go even farther than the warning, and after a few releases of the scary
> warning make them mount with -o iknownfsv2isgoingway
> 
> You'll also want rhel/suse on board. It doesn't help if its gone from
> mainline and they just port it into the enterprise distro.
> 
> -chris
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




