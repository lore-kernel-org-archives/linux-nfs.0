From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/2] vfs: ensure that dentries are revalidated on open
	(try #2)
Date: Wed, 18 Nov 2009 05:19:06 +0100
Message-ID: <20091118041906.GB1395@ucw.cz>
References: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, ebiederm@xmission.com,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:39540 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbZKRI5g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Nov 2009 03:57:36 -0500
In-Reply-To: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

> This is the second attempt to fix this problem. The first one attempted
> to fix this in procfs, but Eric Biederman pointed out that file bind
> mounts have a similar problem. This set attempts to fix the issue at a
> higher level, in the generic VFS layer.
> 
> In certain situations, when it knows that they are valid, the path
> walking code will skip revalidating dentries that it finds in the cache.
> This causes problems with filesystems such as NFSv4 and CIFS that depend
> on the d_revalidate routine to do opens during lookup.

...and it allows bypassing directory permissions. Could we fix both
here?
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
