Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36555 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbbJOTt7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 15:49:59 -0400
Received: by obbrx8 with SMTP id rx8so73893930obb.3
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2015 12:49:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151015190945.GH49747@tonberry.usersys.redhat.com>
References: <20151015190945.GH49747@tonberry.usersys.redhat.com>
Date: Thu, 15 Oct 2015 15:49:58 -0400
Message-ID: <CAHQdGtSOiiSdUS5QJ-1rq3uKvhbLxPo50r9zUW3Gzw+N+cfKXQ@mail.gmail.com>
Subject: Re: Diskless client with NFSv4 root?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 15, 2015 at 3:09 PM, Scott Mayhew <smayhew@redhat.com> wrote:
>
> Is this something that is expected to work?  It pretty much deadlocks
> during boot.  I took a vmcore... the oldest RPC task (and the one that
> had the RPC transport locked) was a SETATTR that was waiting on an id
> mapper upcall, and the first task in the sending RPC wait queue was the
> OPEN of the /sbin/request-key program.
>
> If I disable id mapping on the NFS server then it looks like it works...
>

Yes, that is 100% expected behaviour. You get circular behaviour if
you try to use idmapped identities when starting the idmapper. :-)

In fact, if you look in the commit logs, you'll find that enabling
rootless NFSv4 was one of the justifications for adding the AUTH_SYS
non-idmapped mode on the client.

Cheers
  Trond
