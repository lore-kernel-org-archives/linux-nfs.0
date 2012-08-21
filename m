Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:54027 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757240Ab2HUM7O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 08:59:14 -0400
Date: Tue, 21 Aug 2012 08:59:05 -0400
From: Jim Rees <rees@umich.edu>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4: ssh + unlink(~/.Xauthority) delays
Message-ID: <20120821125905.GA16550@umich.edu>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <k0vgkt$mm0$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sven Geggus wrote:

  Hello,
  
  I'm about to setup a Linux based fileserver for home directories and a
  couple of Linux clients with kerberos and NFS4 (no NFS3 for security
  reasons).
  
  The whole stuff is currently based on debian stable (with a backported
  current NFS userland 1.2.5) and a recent vanilla kernel (3.5.2).
  
  So far I have the NFS4 Server up and running as well as a couple of clients
  with NFS4+autofs mounted home directories.
  
  All this stuff mostly works now, but unfortunately I ran into some strange
  bahaviour now.
  
  When I ssh from one machine to another the system hangs (a delay of up to 60
  seconds) while running xauth.
  
  Replacing xauth by a wrapper script I have been able to trace this behaviour
  to a hang of an unlink("/home/<user>/.Xauthority") system call.
  
  So the question is what cases hangs in NFS4 based Linux systems in general
  an in this particular case?

No, the question is why did X put that file in your home directory.  That's
not where it belongs.  I've got this in my .xinitrc:

setenv XAUTHORITY /tmp/Xauthority`id -u`
