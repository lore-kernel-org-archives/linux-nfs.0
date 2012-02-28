Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:44007 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932299Ab2B1Mq5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2012 07:46:57 -0500
Date: Tue, 28 Feb 2012 07:46:46 -0500
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: Harshula <harshula@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: "Using NFS over UDP on high-speed links such as Gigabit can
 cause silent data corruption."
Message-ID: <20120228124646.GA2528@umich.edu>
References: <1330406521.9157.16.camel@serendib>
 <20120228065218.7e110936@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120228065218.7e110936@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:

  On Tue, 28 Feb 2012 16:22:01 +1100
  Harshula <harshula@redhat.com> wrote:
  
  > Hi Steve,
  > 
  > The following openSUSE nfs-utils patch, warn-nfs-udp.patch, is not
  > included upstream:
  > 
  > https://build.opensuse.org/package/view_file?file=warn-nfs-udp.patch&package=nfs-utils&project=openSUSE%3AFactory&rev=8e3e60c70e8270cd4afa036e13f6b2bb
  > 
  > Please consider including it.
  > 
  > Thanks,
  > #
  > 
  
  I think that patch looks reasonable and clearly documenting the
  problems with UDP is a wonderful thing.
  
  It may be best to send it formally to steved and the list as a real
  [PATCH] with a real description and SoB line.

This feels like the wrong place to document this, since it affects anything
that uses udp, not just nfs.  It also seems like this should be solved in
the network layer with an adaptive frag time.  But I'm not volunteering to
do that.
