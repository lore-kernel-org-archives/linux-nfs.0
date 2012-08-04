Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676Ab2HDCAs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Aug 2012 22:00:48 -0400
Date: Fri, 3 Aug 2012 22:00:39 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
Message-ID: <20120803220039.743fe1f0@corrin.poochiereds.net>
In-Reply-To: <20120804000819.GB25558@fieldses.org>
References: <20120804000819.GB25558@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 3 Aug 2012 20:08:19 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> I'm getting
> 
> 	# mount -tnfs -onfsvers=4 pip1:/exports /mnt/
> 
> (OK, admittedly that's with 3.6.0-rc1 + a few experimental patches, but
> I doubt they're related.)
> 
> Also:
> 
> 	[root@pip2 ~]# modprobe nfs4
> 	[root@pip2 ~]# lsmod|grep nfs4
> 	[root@pip2 ~]# 
> 
> --b.

I hit the same problem...

Try removing /usr/lib/modprobe.d/nfs.conf (assuming you're running
Fedora).

-- 
Jeff Layton <jlayton@redhat.com>
