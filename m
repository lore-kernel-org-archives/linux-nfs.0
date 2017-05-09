Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35426 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751471AbdEISkc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 14:40:32 -0400
Received: by mail-qt0-f175.google.com with SMTP id n4so8568656qte.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 11:40:31 -0700 (PDT)
Message-ID: <1494355229.2659.15.camel@redhat.com>
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
From: Jeff Layton <jlayton@redhat.com>
To: Karel Zak <kzak@redhat.com>, David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Date: Tue, 09 May 2017 14:40:29 -0400
In-Reply-To: <20170504133414.ytfdumdeuhh5txkw@ws.net.home>
References: <20170504104045.6sh3dqofcii6kk2e@ws.net.home>
         <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
         <15169.1493903211@warthog.procyon.org.uk>
         <20170504133414.ytfdumdeuhh5txkw@ws.net.home>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-05-04 at 15:34 +0200, Karel Zak wrote:
> On Thu, May 04, 2017 at 02:06:51PM +0100, David Howells wrote:
> > Karel Zak <kzak@redhat.com> wrote:
> > > The very basic mount(2) problem is that you have to parse
> > > /proc/self/mountinfo to get information about the mounted filesystem.
> > > It seems that your read() is also one way communication.
> > > 
> > > What we really need is to have a way how to specify *what* you want to
> > > read. The error message is not enough, I want to know the finally used
> > > mount options, mount ID, etc. It would be nice to have something like
> > > 
> > > 
> > >    fsmount(mfd, AT_FDCWD, "/mnt", 0);
> > > 
> > >    write(mfd, "o");
> > >    read(mfd, ....);     // read mount options
> > > 
> > >    write(mdf, "i");
> > >    read(mfd, ....);     // read mount ID
> > > 
> > > 
> > > but it seems ugly. Maybe introduce another function like 
> > > 
> > >     fsinfo(mdf, "o", buf, bufsz)
> > > 

Not sure that it's any prettier, but you could use an ioctl to switch
between different read requests:

ioctl(mfd, FSOPEN_READ_OPTIONS);
read(mfd, ....);

ioctl(mfd, FSOPEN_READ_MOUNT_ID);
read(mfd, ....);

> > > to get mount options (etc.) and to avoid separate write & read.
> > 
> > What is it you're trying to do?  Just read back the state of the new mount?
> 
>  ...read back the state of the new mount, because for example mount
>  options can be modified by FS driver. It would be also nice to have
>  API to get state of arbitrary mount without parsing mountinfo (the
>  file is huge on some systems).
> 


-- 
Jeff Layton <jlayton@redhat.com>
