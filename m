Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758159Ab2CFCiO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 21:38:14 -0500
Message-ID: <4F557898.7040002@RedHat.com>
Date: Mon, 05 Mar 2012 21:38:16 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Malahal Naineni <malahal@us.ibm.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
References: <1330976165-19849-1-git-send-email-steved@redhat.com> <1330976165-19849-2-git-send-email-steved@redhat.com> <20120305212015.GA21904@us.ibm.com> <4F5559EA.7010206@RedHat.com> <1330993903.5407.3.camel@lade.trondhjem.org> <4F556007.2030603@RedHat.com> <1330995896.5407.8.camel@lade.trondhjem.org> <4F5569C5.1000100@RedHat.com> <20120306015230.GA4513@umich.edu> <20120306022505.GA32281@us.ibm.com>
In-Reply-To: <20120306022505.GA32281@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 09:25 PM, Malahal Naineni wrote:
> Jim Rees [rees@umich.edu] wrote:
>> I don't understand the backward compatibility issue.  Are there times when
>> you have a mount, and it's in /etc/mtab, but not in /proc/mounts?  I don't
>> see how that's possible.
> 
> No, but that is what NFS umount thinks due to slight differences in
> those two files. Happens only in NFSv4 world. 
Exactly... When /etc/mtab and /proc/mounts are not symbolically 
linked the v4 mount are written differently to both files as 
well as v3 mount are also written differently that v4 mounts...

steved.

