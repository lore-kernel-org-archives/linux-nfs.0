Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:16842 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbZCZAgr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2009 20:36:47 -0400
Received: by yx-out-2324.google.com with SMTP id 31so294027yxl.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2009 17:36:45 -0700 (PDT)
In-Reply-To: <49CA7D93.9050608@RedHat.com>
References: <49CA7D93.9050608@RedHat.com>
Date: Wed, 25 Mar 2009 19:36:45 -0500
Message-ID: <b314b0e60903251736i42b1113cj6aafc058d775b2c2@mail.gmail.com>
Subject: Re: Making crossmnt a default export option
From: spencer shepler <spencer.shepler@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 25, 2009 at 1:53 PM, Steve Dickson <SteveD@redhat.com> wrote:
> Hello,
>
> What would be the ramifications of turning on the crossmnt
> option on by default? Currently the the default is nocrossmnt.
>
> In my recent work with pseudo exports, it has become very apparent
> that having the crossmnt always set, especially with multi file
> system exports, allows mount to "just work"!
>
> So historically what is the reason for not allowing the clients
> to always cross file systems? Is it a security issue?
> And again, what would be the ramifications always allowing, by
> default, clients to cross file systems?

As Trond mentioned, the OpenSolaris client doesn't automatically
create mount points when crossing the server's filesystem boundaries
(for NFSv3).
NFSv4 support for that behavior is now present for OpenSolaris.

So the risk is running into clients that don't behave like the Linux
client and then "mv" will not be able to determine the appropriate
behavior when mv'ing files between those filesystems.

Spencer

>
> steved.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
