From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: umount -a -f -t nfs doesn't work when a file has been written
	and "-l" option is needed
Date: Sat, 12 Sep 2009 16:01:07 +0100
Message-ID: <20090912150107.GE5858@ZenIV.linux.org.uk>
References: <1252139498.14467.12.camel@localhost> <4AA65ECF.2070701@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pacho-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37998 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678AbZILPBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Sep 2009 11:01:06 -0400
In-Reply-To: <4AA65ECF.2070701-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2009 at 09:40:31AM -0400, Steve Dickson wrote:
> On 09/05/2009 04:31 AM, Pacho Ramos wrote:
> > I suffer the following problem with nfs since a lot of time, now, I am
> > using nfs-utils-1.2.0, but older versions were affected too.
> > 
> > When I write a file on a mounted nfs filesystem and server goes down, I
> > am unable to umount it even with "-f" option, it simply hangs. On the
> > other hand, if no file was written (for example, it was simply read)
> > there is no problem and "umount -f" works as expected.
> I believe 'umount -f' waits for all the async or sync (I can't remember)
> RPC tasks to complete before returning... That's the reason for the hang.
> 
> > 
> > Seems that I need to run "umount -l" for being able to unmount it, even
> > when I expected that "-f" should be enough.
> Hopefully you will be rebooting soon since kernel structures (ala the
> super block) are not cleaned up with 'umount -l'. Which could make the
> system somewhat unstable. 

Um...  Not really.  The damn thing is detached from the namespace and
left alone until it's not busy anymore.  At that point it's hit with the
rest of umount() (i.e. with filesystem driver being told to shut it down).

So it won't go away in that case, but you shouldn't get any instability from
that - from the VFS POV nothing nasty has happened, from the NFS client
code POV... well, it's not being unmounted yet, as far as NFS code cares.
Just a mounted fs from a stuck server...
