Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38124 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754500AbcDMRol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2016 13:44:41 -0400
Date: Wed, 13 Apr 2016 13:44:39 -0400
To: YuGiOhJCJ Mailing-List <yugiohjcj-mailinglist@laposte.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Sometimes all the applications using sqlite do not work correctly
Message-ID: <20160413174439.GA2808@fieldses.org>
References: <20160407010927.bf07f12fa3f62b1586dd11ad@laposte.net>
 <20160407181422.GB30676@fieldses.org>
 <20160408004839.247958f8c43329122b48d75f@laposte.net>
 <20160411210939.447af7a06255f9ec8b491cc2@laposte.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160411210939.447af7a06255f9ec8b491cc2@laposte.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 11, 2016 at 09:09:39PM +0200, YuGiOhJCJ Mailing-List wrote:
> On Fri, 8 Apr 2016 00:48:39 +0200
> YuGiOhJCJ Mailing-List <yugiohjcj-mailinglist@laposte.net> wrote:
> 
> > > So when the problem happens, restarting the server fixes the problem?
> > 
> > Indeed, that's it.
> > 
> > > It's probably the kernel version that's most important.  So it might be
> > > interesting to know what your kernel version was before and what it is
> > > now.
> > 
> > My Linux kernel was 3.18.20 before and is still 3.18.20 now.
> > I have not changed of kernel since the problem happens.
> > 
> > > Also: what's your NFS server?  Was it upgraded at the same time, or was
> > > only your client upgraded?
> > 
> > I have not upgraded the server and not upgraded the client.
> > They are still the same: nfs-utils-1.2.8.
> 
> It happened again today.
> 
> Output on mumble:
> $ mumble 
> CELT bitstream 8000000b from libcelt0.so.0.7.0
> CELT bitstream 80000010 from libcelt0.so.0.11.0
> Locale is "en_US" (System: "en_US")
> TextToSpeech: Compiled without support for speech-dispatcher
> SQL Query failed "CREATE TABLE IF NOT EXISTS `servers` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT, `hostname` TEXT, `port` INTEGER DEFAULT 64738, `username` TEXT, `password` TEXT)" 
...
> ALSAAudioInput: Releasing ALSA Mic.
> ALSAAudioOutput: Destroyed
> SQL Query failed "PRAGMA journal_mode = DELETE" 
> -1 "database is locked Unable to execute statement" 
> SQL Query failed "VACUUM" 
> -1 "database is locked Unable to fetch row"
> 
> Output on xmoto:
> $ xmoto 
> fatal exception : xmDb: database is locked
> 
> No Output on firefox but I am unable to show bookmarks which means that there is a problem to access the sqlite database.
> 
> I have just restarted the NFS server like that:
> $ bash /etc/rc.d/rc.nfsd restart
> 
> And the client works now perfectly again with applications using sqlite.
> 
> So I guess that there is a problem with the NFS server (not the client).
> Is there something I could check like processes running on the server when the problem happens?
> What information could be useful to understand what happens when I get the problem?

Are there any warnings in the client or server's logs?

--b.
