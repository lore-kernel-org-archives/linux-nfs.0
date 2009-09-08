From: Steve Dickson <SteveD@redhat.com>
Subject: Re: umount -a -f -t nfs doesn't work when a file has been written
 and "-l" option is needed
Date: Tue, 08 Sep 2009 09:40:31 -0400
Message-ID: <4AA65ECF.2070701@RedHat.com>
References: <1252139498.14467.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbZIHNkr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 09:40:47 -0400
In-Reply-To: <1252139498.14467.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/05/2009 04:31 AM, Pacho Ramos wrote:
> I suffer the following problem with nfs since a lot of time, now, I am
> using nfs-utils-1.2.0, but older versions were affected too.
> 
> When I write a file on a mounted nfs filesystem and server goes down, I
> am unable to umount it even with "-f" option, it simply hangs. On the
> other hand, if no file was written (for example, it was simply read)
> there is no problem and "umount -f" works as expected.
I believe 'umount -f' waits for all the async or sync (I can't remember)
RPC tasks to complete before returning... That's the reason for the hang.

> 
> Seems that I need to run "umount -l" for being able to unmount it, even
> when I expected that "-f" should be enough.
Hopefully you will be rebooting soon since kernel structures (ala the
super block) are not cleaned up with 'umount -l'. Which could make the
system somewhat unstable. 

> 
> Is this the proper behavior or something is going wrong?
Its the known behaviour... whether its correct or not is up to
interpretation... ;-) Meaning, 'umount -f' probably should
not hang waiting for I/O to finish, but error-ing on the "lets 
do everything we can not to corrupt data" is not a bad stand either...

steved.

