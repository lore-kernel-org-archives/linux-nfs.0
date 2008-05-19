From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Mon, 19 May 2008 10:48:06 -0400
Message-ID: <20080519144806.GB7622@fieldses.org>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Alexander Borghgraef <alexander.borghgraef.rma@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53641 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754910AbYESOsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 10:48:08 -0400
In-Reply-To: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 14, 2008 at 02:32:16PM +0200, Alexander Borghgraef wrote:
> Hi all,
> 
> I've been posting this on every linux support forum I thought
> relevant, with no useful response. I suspect it's an nfs problem, so
> now I'm trying this list. The problem is this: ever since upgrading
> from Fedora 6 to 8, I've been experiencing periodic kmail/contact
> crashes. After running for some time, kmail pops an error window:
> 
>   Error opening /home/myhome/Mail/sent-mail/cur; either this is not a
> valid maildir folder, or you do not have
>   sufficient access permissions.
> 
> Sent-mail is just an example, it happens to random mail directories.
> Shortly after this, kmail crashes with the error message:
> 
>   KMail encountered a fatal error and will terminate now. The error
> was: Could not sync maildir folder.
> 
> So I did an ls of an affected mail directory, which resides on an nfs
> filesystem on a fileserver, and I found this rather disquieting
> result:

You're doing the "ls" from the client, though, not the server, right?

> 
>   aborghgr@mypc~$ ls -l Mail/inbox/
>   ls: cannot access Mail/inbox/cur: No such file or directory
>   total 8
>   d????????? ? ?        ?          ?                ? cur
>   drwx------ 2 aborghgr slocate 4096 2005-07-08 13:23 new
>   drwx------ 2 aborghgr slocate 4096 2008-04-24 10:24 tmp
> 
> The cur directory (or other files to which this has happened)is not
> permanently lost: moving its parent directory for example restores all
> of the files, and simply waiting also solves the problem. Still, it
> makes working with kmail impossible, and also raises concerns about
> the stability of the filesystem in general. The people at the kdepim
> list said that a user-space program such as kmail could not possibly
> corrupt the filesystem like that, so it has to be a bug in nfs. Any
> ideas? I'm using Fedora 8, the 2.6.24.4-64.fc8 kernel and kmail 1.9.9
> on kde 3.5.9-5.fc8. The nfs fileserver runs Fedora Core 3 with the
> 2.6.9-1.667 kernel (old machine).

Out of curiosity--what's the filesystem on the server?  (I just wonder
if this could be due to poor time resolution, so if e.g. switching from
ext3 to xfs would work around the problem.)

--b.
