Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10213 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199Ab3KRQsO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Nov 2013 11:48:14 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Bruce Fields <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, Steve Dickson <steved@redhat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] gssd: don't let parent exit until child has a
 chance to scan directory once
Date: Mon, 18 Nov 2013 16:48:14 +0000
Message-ID: <B3D4C4F6-511B-4114-9C2F-196A08F3DD54@netapp.com>
References: <1384542931-18753-1-git-send-email-jlayton@redhat.com>
 <1384542931-18753-3-git-send-email-jlayton@redhat.com>
 <20131118163829.GC3203@fieldses.org>
In-Reply-To: <20131118163829.GC3203@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 18, 2013, at 11:38, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Nov 15, 2013 at 02:15:31PM -0500, Jeff Layton wrote:
>> With some proposed kernel changes, it won't even attempt to upcall
>> sometimes if it doesn't appear that gssd is running. This means that
>> we have a theoretical race between gssd starting up at boot time and
>> the init process attempting to mount kerberized filesystems.
>> 
>> Fix this by switching gssd to use mydaemon() and having the child
>> only release the parent after it has processed the directory once.
> 
> Makes sense to me, thanks--ACK.

We now appear to have 2 more or less identical copies of mydaemon in nfs-utils (one in utils/gssd/svcgssd.c and one in utils/idmapd/idmapd.c). Time to make it a common library function?

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

