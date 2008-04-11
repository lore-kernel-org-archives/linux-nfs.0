From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: implement option checking when remounting NFS	filesystems
Date: Fri, 11 Apr 2008 16:14:38 -0400
Message-ID: <47FFC6AE.8080609@redhat.com>
References: <1207937413-16189-1-git-send-email-jlayton@redhat.com>	 <47FFB9B3.1020703@redhat.com> <1207942347.14621.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758895AbYDKUOl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2008 16:14:41 -0400
In-Reply-To: <1207942347.14621.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2008-04-11 at 15:19 -0400, Peter Staubach wrote:
>   
>> Jeff Layton wrote:
>>     
>>> When remounting an NFS or NFS4 filesystem, the new NFS options are not
>>> respected, yet the remount will still return success. This patch adds
>>> a remount_fs sb op for NFS that checks any new nfs mount options against
>>> the existing ones and fails the mount if any have changed.
>>>
>>> This is only implemented for string-based mount options since doing
>>> this with binary options isn't really feasible.
>>>       
>> What about respecting the new options as makes sense and rejecting
>> those which absolutely can't be changed dynamically?
>>     
>
> If we were to do this, then how should superblocks that are shared
> between multiple mountpoints behave?

Do you mean if those other mountpoints were mounted with explicit
options and this remount might affect those options?

Isn't the same problem that we potentially have today?

    Thanx...

       ps
