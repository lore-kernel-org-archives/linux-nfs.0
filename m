From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mounting /var/lib/nfs with noatime or relatime ?
Date: Thu, 20 Aug 2009 08:48:58 -0400
Message-ID: <1250772539.5352.20.camel@heimdal.trondhjem.org>
References: <4A8CF6C8.1050400@aixigo.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Harald Dunkel <harald.dunkel@aixigo.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44169 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370AbZHTMtA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 08:49:00 -0400
In-Reply-To: <4A8CF6C8.1050400@aixigo.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-20 at 09:10 +0200, Harald Dunkel wrote:
> Hi folks,
> 
> NFS stores some small files in /var/lib/nfs, AFAICS.
> Can it cause any problems for the NFService, if /var is
> mounted with "relatime" or "noatime"? Does it increase
> NFS performance at all?

"relatime" and "noatime" shouldn't really affect NFS much. The files
in /var/lib/nfs are created and destroyed all the time by the statd
daemon, but the only time they are actually read is at boot time.

Cheers
  Trond

