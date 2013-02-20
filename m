Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964827Ab3BTQWQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2013 11:22:16 -0500
Message-ID: <5124F835.3040904@RedHat.com>
Date: Wed, 20 Feb 2013 11:22:13 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/14] lnfs: 3.8-rc7 release
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com> <20130218195834.GA3391@fieldses.org> <512395D7.5010205@RedHat.com> <20130219151808.GE3391@fieldses.org> <51239CFF.9000600@RedHat.com> <20130219205608.GB14606@fieldses.org> <5124F1EA.2090902@RedHat.com> <20130220155933.GI14606@fieldses.org>
In-Reply-To: <20130220155933.GI14606@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20/02/13 10:59, J. Bruce Fields wrote:
>> Speaking of servers... Do you think its about time to rpc.nfsd the
>> > ability to enable 4.x versions?
> 	echo "+4.2" >/proc/fs/nfsd/versions
So you are saying it not time to teach rpc.nfsd how to do set 4.X versions?

steved.
