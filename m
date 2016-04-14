Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:4578 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbcDNEOW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2016 00:14:22 -0400
Date: Thu, 14 Apr 2016 06:14:17 +0200
From: YuGiOhJCJ Mailing-List <yugiohjcj-mailinglist@laposte.net>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: linux-nfs@vger.kernel.org
Subject: Re: Sometimes all the applications using sqlite do not work
 correctly
Message-Id: <20160414061417.1cbbe93f9f070d57d1133f25@laposte.net>
In-Reply-To: <20160413174439.GA2808@fieldses.org>
References: <20160407010927.bf07f12fa3f62b1586dd11ad@laposte.net>
	<20160407181422.GB30676@fieldses.org>
	<20160408004839.247958f8c43329122b48d75f@laposte.net>
	<20160411210939.447af7a06255f9ec8b491cc2@laposte.net>
	<20160413174439.GA2808@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Apr 2016 13:44:39 -0400
bfields@fieldses.org (J. Bruce Fields) wrote:

> On Mon, Apr 11, 2016 at 09:09:39PM +0200, YuGiOhJCJ Mailing-List wrote:
> > On Fri, 8 Apr 2016 00:48:39 +0200
> > YuGiOhJCJ Mailing-List <yugiohjcj-mailinglist@laposte.net> wrote:
> > 
> > > > So when the problem happens, restarting the server fixes the problem?
> > > 
> > > Indeed, that's it.
> > > 
> > > > It's probably the kernel version that's most important.  So it might be
> > > > interesting to know what your kernel version was before and what it is
> > > > now.
> > > 
> > > My Linux kernel was 3.18.20 before and is still 3.18.20 now.
> > > I have not changed of kernel since the problem happens.
> > > 
> > > > Also: what's your NFS server?  Was it upgraded at the same time, or was
> > > > only your client upgraded?
> > > 
> > > I have not upgraded the server and not upgraded the client.
> > > They are still the same: nfs-utils-1.2.8.
> > 
> > It happened again today.
> > 
> > Output on mumble:
> > $ mumble 
> > CELT bitstream 8000000b from libcelt0.so.0.7.0
> > CELT bitstream 80000010 from libcelt0.so.0.11.0
> > Locale is "en_US" (System: "en_US")
> > TextToSpeech: Compiled without support for speech-dispatcher
> > SQL Query failed "CREATE TABLE IF NOT EXISTS `servers` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT, `hostname` TEXT, `port` INTEGER DEFAULT 64738, `username` TEXT, `password` TEXT)" 
> ...
> > ALSAAudioInput: Releasing ALSA Mic.
> > ALSAAudioOutput: Destroyed
> > SQL Query failed "PRAGMA journal_mode = DELETE" 
> > -1 "database is locked Unable to execute statement" 
> > SQL Query failed "VACUUM" 
> > -1 "database is locked Unable to fetch row"
> > 
> > Output on xmoto:
> > $ xmoto 
> > fatal exception : xmDb: database is locked
> > 
> > No Output on firefox but I am unable to show bookmarks which means that there is a problem to access the sqlite database.
> > 
> > I have just restarted the NFS server like that:
> > $ bash /etc/rc.d/rc.nfsd restart
> > 
> > And the client works now perfectly again with applications using sqlite.
> > 
> > So I guess that there is a problem with the NFS server (not the client).
> > Is there something I could check like processes running on the server when the problem happens?
> > What information could be useful to understand what happens when I get the problem?
> 
> Are there any warnings in the client or server's logs?
> 
> --b.

I am not sure where all these logs are located.
I found the "/var/log/nfsd/" directory on the server but is is empty.
The script running the nfs server is here:
http://ftp.slackware.com/pub/slackware/slackware-14.1/source/n/nfs-utils/rc.nfsd

I see no options used for logs.

Reading the man of nfsd, I see these two options:
$ man nfsd
[...]
-d  or  --debug
              enable logging of debugging messages
[...]
-s  or  --syslog
              By default, rpc.nfsd logs error messages (and debug messages, if
              enabled)  to  stderr.  This option makes rpc.nfsd log these mes‐
              sages to syslog instead. Note  that  errors  encountered  during
              option  processing  will still be logged to stderr regardless of
              this option.
[...]

I guess I should replace in the script this line:
/usr/sbin/rpc.nfsd 8
by this line:
/usr/sbin/rpc.nfsd -ds 8
in order to see logs from the server.

Is it correct?

About the client logs, I have no idea how to activate them.

Any idea?

I saw that my server root partition was full (usage: 100%).
I removed some useless files in the /tmp directory and now I am not full anymore (usage: 98%).
Does NFS need a write access on the server in order to work correctly?
In this case, that could be a reason of my problem.
