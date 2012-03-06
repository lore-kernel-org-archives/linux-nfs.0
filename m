Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:55895 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758166Ab2CFBwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 20:52:42 -0500
Date: Mon, 5 Mar 2012 20:52:30 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
Message-ID: <20120306015230.GA4513@umich.edu>
References: <1330976165-19849-1-git-send-email-steved@redhat.com>
 <1330976165-19849-2-git-send-email-steved@redhat.com>
 <20120305212015.GA21904@us.ibm.com>
 <4F5559EA.7010206@RedHat.com>
 <1330993903.5407.3.camel@lade.trondhjem.org>
 <4F556007.2030603@RedHat.com>
 <1330995896.5407.8.camel@lade.trondhjem.org>
 <4F5569C5.1000100@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F5569C5.1000100@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I don't understand the backward compatibility issue.  Are there times when
you have a mount, and it's in /etc/mtab, but not in /proc/mounts?  I don't
see how that's possible.
