Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:54708 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756896Ab3J2Bwr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 21:52:47 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Anand Avati <aavati@redhat.com>
CC: Wheeler Ric <rwheeler@redhat.com>,
        Dr Fields James Bruce <bfields@redhat.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dickson Steve <steved@redhat.com>
Subject: Re: XATTRs in NFS?
Date: Tue, 29 Oct 2013 01:52:45 +0000
Message-ID: <AF4F68CE-DF98-47E6-89CC-D052F79591B2@netapp.com>
References: <20131028180838.GG31322@fieldses.org>
 <526EC3F7.3090601@gmail.com> <526EFFCC.2060506@redhat.com>
 <18F0636D-7CE0-42C1-9249-325DF69516D4@netapp.com>
 <526F0893.5030700@redhat.com>
 <A7C1B206-12CD-4958-9528-A8D9C9847011@netapp.com> <526F0E49.10801@redhat.com>
In-Reply-To: <526F0E49.10801@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2013, at 9:24 PM, Anand Avati <aavati@redhat.com> wrote:

> On 10/28/2013 06:26 PM, Myklebust, Trond wrote:
> 
>> 
>> That battle may have been fought and won within the glusterfs community, but why should we wave the white flag without a discussion? I don't see how what he described above has anything to do with user defined attributes. He's describing how he wants to export quota information and xtime through a private xattr interface that is currently unique to glusterfs. How is that not a private syscall interface?
>> 
> 
> Exposing quota informtion is use "from the top". Note the other point I mention about using NFS volumes as "gluster bricks" where we store xattrs as dumb and persistent key/values associated with file/dir inodes (fresh/stale info for replication, hash ranges for dirs, quota acconting info per-dir, xtime per dir).

>> Which of the mainstream filesystems have their own private xattr namespaces like the above?
>> 
> 
> Why should NFS need to worry? As long as it acts like a pass-through (like every other call it supports).

We need to worry because we don't know what side-effects your private interface will have. How does it affect our caching model? How do we debug any problems that arise? Are there any security implications that we need to know about?

Trond