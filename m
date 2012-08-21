Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:51980 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758022Ab2HUROX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 13:14:23 -0400
Date: Tue, 21 Aug 2012 13:07:59 -0400
From: Jim Rees <rees@umich.edu>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4: ssh + unlink(~/.Xauthority) delays
Message-ID: <20120821170759.GA13076@umich.edu>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
 <20120821125905.GA16550@umich.edu>
 <k10bib$1fi$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <k10bib$1fi$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sven Geggus wrote:

  Jim Rees <rees@umich.edu> wrote:
  
  > No, the question is why did X put that file in your home directory.  That's
  > not where it belongs.  I've got this in my .xinitrc:
  > 
  > setenv XAUTHORITY /tmp/Xauthority`id -u`
  
  I agree, that ~/.Xauthority is probably not the best place for this file,
  but it is the default (at least in Debian).
  
  If it is expected behaviour that this will not work correctly with shared
  Homedirectories, I wonder why this did not cause me any trouble with NFS3
  for many years.

Are you sure it didn't cause you any trouble?  You were giving root access
to anyone who could snoop the Xauthority file off the wire.  That's the main
reason you don't want it in your home dir.  As to why that's still the
default, laziness I guess.

  Anyway I did not yet figure out how to globally change the XAUTHORITY
  Variable in kdm and ssh :(

I don't use kdm.  For ssh:

% cat ~/.ssh/environment
XAUTHORITY=/tmp/Xauthority1234

You might also have to fix /etc/ssh/sshd_config.
