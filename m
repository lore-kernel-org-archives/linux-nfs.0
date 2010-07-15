Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754814Ab0GOQ7B convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jul 2010 12:59:01 -0400
Subject: Re: newer Linux nfs client freeze under load to OpenSolaris server
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Scott Serr <scott@srcbin.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20031040.12221279212276848.JavaMail.root@mail>
References: <20031040.12221279212276848.JavaMail.root@mail>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 15 Jul 2010 12:58:43 -0400
Message-ID: <1279213123.10149.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-07-15 at 10:44 -0600, Scott Serr wrote:
> My Ubuntu 10.04 workstation automounts my OpenSolaris 2008.11 server.  This works and is stable for "light use."  If I hit it hard though with large "cp -a" reads or rsync/unison, then Linux locks up.  The system is non-responsive, the activity light on my switch shows very active until I force the power off on the box.  The activity light to NFS Server is calm during the Linux NFS Client activity.
> 
> I believe this happened when I ran Ubuntu 9.04.  It does not happen on 2 other boxes: Ubuntu 8.04 and Gentoo ~2009.  These other boxes are on the same switch 1Gb as the NFS Server, the problemed 10.04 workstation has 2 1Gb switches between.
> 
> I've tried nfs mount options vers=3 and udp and tcp, none seem to solve the problem.
> 
> I put another 100M switch between my 2 1Gb switches, this seems to work around the problem - no crashing.
> 
> Ideas?  Seems harsh that Linux would freeze.
> (I'll try with no switches next.)

Does this bugzilla look relevant?

     https://bugzilla.kernel.org/show_bug.cgi?id=16056

If so, would you mind testing the patch that I posted for it?

Cheers
  Trond
