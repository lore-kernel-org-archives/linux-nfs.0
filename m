Return-Path: linux-nfs-owner@vger.kernel.org
Received: from csamuel.org ([74.50.50.137]:39200 "EHLO csamuel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab2DRAze (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 20:55:34 -0400
Message-ID: <4F8E0EFF.4090007@csamuel.org>
Date: Wed, 18 Apr 2012 10:46:55 +1000
From: Chris Samuel <chris@csamuel.org>
MIME-Version: 1.0
To: Andreas Dilger <adilger@whamcloud.com>
CC: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
        Al Viro <viro@ZenIV.linux.org.uk>, dchinner@redhat.com,
        LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        Alex Elder <elder@kernel.org>, Anton Altaparmakov <anton@tuxera.com>,
        Ben Myers <bpm@sgi.com>, Chris Mason <chris.mason@oracle.com>,
        cluster-devel@redhat.com, "David S. Miller" <davem@davemloft.net>,
        fuse-devel@lists.sourceforge.net,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Joel Becker <jlbec@evilplan.org>,
        KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, Mark Fasheh <mfasheh@suse.com>,
        Miklos Szeredi <miklos@szeredi.hu>, ocfs2-devel@oss.oracle.com,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "Theodore Ts'o" <tytso@mit.edu>, xfs@oss.sgi.com
Subject: Re: [PATCH 00/19 v5] Fix filesystem freezing deadlocks
References: <1334592845-22862-1-git-send-email-jack@suse.cz> <C9A0E2F0-ED57-40D6-9F75-5D72D45D21F0@dilger.ca> <20120417004329.GE6734@dastard> <141752A3-EDF1-4ABC-919D-4170B0455948@whamcloud.com>
In-Reply-To: <141752A3-EDF1-4ABC-919D-4170B0455948@whamcloud.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17/04/12 15:10, Andreas Dilger wrote:

> (which IMHO would prevent nearly every Gnome system from freezing unless these
> apps have changed their behaviour in more recent releases).

It would also affect current KDE desktops as they tend to use MySQL for
Akonadi & Nepomuk, plus anyone using Chromium (and presumably Chrome):

samuel@eris:/tmp$ sudo lsof | grep deleted | awk '{print $1}' | sort |
uniq -c
[sudo] password for samuel:
     32 chromium-
      1 dovecot
      5 imap-logi
      5 mysqld

I would be surprised if you could find many systems that didn't have
files in this situation.

-- 
 Chris Samuel  :  http://www.csamuel.org/  :  Melbourne, VIC
