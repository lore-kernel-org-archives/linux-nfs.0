Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 28dayslater.mr.itd.umich.edu ([141.211.12.118]:54555 "EHLO
	28dayslater.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752882Ab1IYOXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Sep 2011 10:23:51 -0400
Date: Sun, 25 Sep 2011 10:13:01 -0400
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.5 released.
Message-ID: <20110925141301.GB5021@umich.edu>
References: <4E7DD35D.9080800@RedHat.com>
 <20110925183930.69b33573@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110925183930.69b33573@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NeilBrown wrote:

  On Sat, 24 Sep 2011 08:55:57 -0400 Steve Dickson <SteveD@redhat.com> wrote:
  
  > New Features in this release:
  > 
  >    * With the addition of the blkmapd daemon, the client 
  >      now supports every pNFS layout type. 
  > 
  >    * The usual assorted bug fixes. 
  > 
  > The tarball can only be found at Sourceforge.net since 
  > master.kernel.org is still down:
  > 
  >   http://sourceforge.net/projects/nfs
  > 
  > [ Maybe we should start thinking about putting the rpms on linux-nfs.org?? ]
  > 
  > The git tree is at:
  >    git://linux-nfs.org/nfs-utils
  > 
  > The change log is also only on Sourceforge.net:
  > 
  > http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.5/Changelog-1.2.5/download
  > 
  
  I've packaged this up for openSUSE so it should appear in openSUSE:Factory
  and probably openSUSE:Tumbleweed in a day or two.
  
  Only oddity I noticed is that the configure script doesn't check for
  libdevmapper.h so I get a complaint when compiling instead of when
  configuring.  I don't know if that is a good thing or a bad thing, but I
  thought I would mention it.

Sorry, I'm not good with automake.  The dependency is from blkmapd on
libdevmapper so there should be a check on both the header and the library,
contingent on nfsv41.  I'll see if I can cook up a patch.  Thanks for
catching this.
