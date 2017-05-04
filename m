Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39572 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752839AbdEDNeT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 09:34:19 -0400
Date: Thu, 4 May 2017 15:34:14 +0200
From: Karel Zak <kzak@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
Message-ID: <20170504133414.ytfdumdeuhh5txkw@ws.net.home>
References: <20170504104045.6sh3dqofcii6kk2e@ws.net.home>
 <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
 <15169.1493903211@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <15169.1493903211@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 04, 2017 at 02:06:51PM +0100, David Howells wrote:
> Karel Zak <kzak@redhat.com> wrote:
> > The very basic mount(2) problem is that you have to parse
> > /proc/self/mountinfo to get information about the mounted filesystem.
> > It seems that your read() is also one way communication.
> > 
> > What we really need is to have a way how to specify *what* you want to
> > read. The error message is not enough, I want to know the finally used
> > mount options, mount ID, etc. It would be nice to have something like
> > 
> > 
> >    fsmount(mfd, AT_FDCWD, "/mnt", 0);
> > 
> >    write(mfd, "o");
> >    read(mfd, ....);     // read mount options
> > 
> >    write(mdf, "i");
> >    read(mfd, ....);     // read mount ID
> > 
> > 
> > but it seems ugly. Maybe introduce another function like 
> > 
> >     fsinfo(mdf, "o", buf, bufsz)
> > 
> > to get mount options (etc.) and to avoid separate write & read.
> 
> What is it you're trying to do?  Just read back the state of the new mount?

 ...read back the state of the new mount, because for example mount
 options can be modified by FS driver. It would be also nice to have
 API to get state of arbitrary mount without parsing mountinfo (the
 file is huge on some systems).

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
