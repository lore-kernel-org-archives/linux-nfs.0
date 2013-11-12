Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280Ab3KLQXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 11:23:41 -0500
Message-ID: <52825648.5090907@RedHat.com>
Date: Tue, 12 Nov 2013 11:24:40 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
References: <1384037221-7224-1-git-send-email-steved@redhat.com> <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com> <52811CBB.3070204@RedHat.com> <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com> <5281290B.6000201@RedHat.com> <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com> <52814876.7080604@RedHat.com> <A59DDCD0-5622-4497-A93E-80493EDCED27@oracle.com> <5281618A.1050604@RedHat.com> <784A1C68-59DA-4248-AF91-BAF472CDD37E@oracle.com>
In-Reply-To: <784A1C68-59DA-4248-AF91-BAF472CDD37E@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/11/13 11:09, Chuck Lever wrote:
>> In the past, if admins want rpc.gssd in the mount path they had to configure it.
>> > Now we are silently adding, yet another, daemon to the mount path and if 
>> > rpc.gssd starts falling on its face, I think it will be difficult to debug,
>> > since the daemon is not expected to be there...
> Our only real choice here is to fix gssd.  Anything else is punting the problem down the road.
> 
No. The last there was a daemon was involved in all NFS client mounts 
(at least that I can remember) was when lockd was a user level daemon.
The main reason it was ported to the kernel was to get ride of the
bottle neck it caused... Now we adding similar bottle neck back??

Architecturally, put a daemon in the direct NFS mount path just does 
not make sense... IMHO...

steved.
