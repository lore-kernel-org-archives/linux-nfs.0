Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44648 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752977AbcLFR0m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 12:26:42 -0500
Date: Tue, 6 Dec 2016 12:26:41 -0500
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove
 nfs-config.service
Message-ID: <20161206172641.GA31197@fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 02, 2016 at 02:58:27PM +1100, NeilBrown wrote:
> This is an RFC series.  A little voice at the back of my head keeps
> telling me that I'm over-engineering, but there isn't really that much
> new code, and I think the result has a lot to recommend it.
> 
> But please tell me if I'm wrong.
> 
> - Various daemons (not all) are enhance to accept configuration
>   information from /etc/nfs.conf
> - the conffile reader is enhanced to support include files, and
>   particularly to be able to include /etc/sysconf/X or /etc/defaults/X
>   files usefully

Currently those files are actually sourced by a shell, right?  So in
theory people could be doing tricky things in there that would no longer
be supported.  Probably unlikely, though, OK....

> - nfs-config.service is removed, because it isn't really needed with
>   the above.
> - documentation for all the above is provided, including a new
>   nfs.systemd man page which gives the bigger picture.

Still looks pretty good to me.

I'm a little worried about user interface churn.  We're not done yet
explaining that people have to run nfs-config.service after changing
things, soon we'll start telling them oh, never mind about that and oh,
by the way, you may want to start migrating your configuration to
/etc/nfs.conf....

But nfs.conf they can ignore and at worst they're going to get an error
trying to run nfs-config.service that they can ignore, so, OK, it
doesn't sound so bad.

--b.

> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (15):
>       Add man-page describing /etc/nfs.conf
>       conffile: add bool support
>       Add /etc/nfs.conf support to rpc.nfsd
>       Add /etc/nfs.conf support for mountd.
>       Add /etc/nfs.conf support for statd
>       Add /etc/nfs.conf support for sm-notify
>       conffile: free image of config file after parsing
>       conffile: split loading of file into a separate function.
>       conffile: add support for include files.
>       conffile: strip "quotes" from values in conf file.
>       conffile: ignore setting of empty string
>       conffile: allow $name expansion of tag values.
>       statd: allow --no-notify to be passed via environment variable.
>       systemd: Remove the nfs-config.service
>       Add nfs.systemd man page
> 
> 
>  configure.ac                     |    6 -
>  support/include/conffile.h       |    2 
>  support/nfs/conffile.c           |  147 +++++++++++++++++++++---------
>  systemd/Makefile.am              |    5 +
>  systemd/README                   |   22 +++-
>  systemd/nfs-blkmap.service       |    3 -
>  systemd/nfs-config.service.in    |   13 ---
>  systemd/nfs-idmapd.service       |    6 -
>  systemd/nfs-mountd.service       |    6 -
>  systemd/nfs-server.service       |    7 -
>  systemd/nfs.conf.man             |  186 ++++++++++++++++++++++++++++++++++++++
>  systemd/nfs.systemd.man          |  167 ++++++++++++++++++++++++++++++++++
>  systemd/rpc-gssd.service.in      |    7 -
>  systemd/rpc-statd-notify.service |    6 -
>  systemd/rpc-statd.service        |    7 -
>  systemd/rpc-svcgssd.service      |    6 -
>  utils/mountd/mountd.c            |   36 +++++++
>  utils/mountd/mountd.man          |   34 +++++++
>  utils/nfsd/nfsd.c                |   36 +++++++
>  utils/nfsd/nfsd.man              |   49 +++++++++-
>  utils/statd/sm-notify.c          |   11 ++
>  utils/statd/sm-notify.man        |   27 ++++++
>  utils/statd/statd.c              |   25 +++++
>  utils/statd/statd.man            |   40 ++++++++
>  24 files changed, 737 insertions(+), 117 deletions(-)
>  delete mode 100644 systemd/nfs-config.service.in
>  create mode 100644 systemd/nfs.conf.man
>  create mode 100644 systemd/nfs.systemd.man
> 
> --
> Signature
