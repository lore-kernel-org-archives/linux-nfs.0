Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:25418 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab3KNDOD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 22:14:03 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: please proof-read: updates to nfs.man for some missing options.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131114031253.GA9522@umich.edu>
Date: Wed, 13 Nov 2013 22:13:56 -0500
Cc: NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1AF110D7-1CE6-491B-85C6-F6A2692F93B6@oracle.com>
References: <20131114140244.6f7c0094@notabene.brown> <20131114031253.GA9522@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 13, 2013, at 10:12 PM, Jim Rees <rees@umich.edu> wrote:

> NeilBrown wrote:
> 
>  +.BR addr= ip-address
>  +This option is rarely used but can provide an explicit IP address of
>  +the NFS server in cases where the server is multi-homed.
>  +.TP 1.5i
> 
> I would change "rarely used" to "usually not needed." Also I think you have
> this option in here twice.

I actually think mount.nfs may strip this option out of the list if a user specifies it.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




