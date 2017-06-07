Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751252AbdFGPwJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jun 2017 11:52:09 -0400
Date: Wed, 7 Jun 2017 17:52:02 +0200
From: Karel Zak <kzak@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: Ian Kent <raven@themaw.net>,
        autofs mailing list <autofs@vger.kernel.org>,
        linux-nfs@vger.kernel.org, util-linux@vger.kernel.org
Subject: Re: [autofs PATCH] Add -c option when calling /bin/umount - if
 supported.
Message-ID: <20170607155202.5zyzuvy6l3fsawkl@ws.net.home>
References: <87d1agd4cu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87d1agd4cu.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 07, 2017 at 10:32:49AM +1000, NeilBrown wrote:
> 
> The "-c" option has been supported by umount since util-linux 2.17.
> It tells umount that the path name is "canonical", meaning no
> symlinks or ".." etc.
> This is appropriate for autofs to use and it always uses canonical
> path names.
> The advantage of "-c" is that it means umount doesn't need to
> 'lstat()' the path so much.

It would be also nice to force systemd to use "umount -c" on shutdown
to avoid automount storm...

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
