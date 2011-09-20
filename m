Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:21654 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab1ITQhA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 12:37:00 -0400
Subject: Re: [PATCH 1/1] statd: Decouple statd's state directory from the NFS state directory
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110920161932.GA10040@infradead.org>
Date: Tue, 20 Sep 2011 12:33:36 -0400
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <3424DCA2-4869-4A07-ADE8-7BF0C545AF8C@oracle.com>
References: <1316531020-25071-1-git-send-email-steved@redhat.com> <20110920154011.GA6959@infradead.org> <4E78BC72.40303@RedHat.com> <20110920161932.GA10040@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 20, 2011, at 12:19 PM, Christoph Hellwig wrote:

> On Tue, Sep 20, 2011 at 12:16:50PM -0400, Steve Dickson wrote:
>>> What is thje rationale for this?  And who would want to move it at
>>> compile time, not at run time?
>> It all has to do with statd not running as root... 
>> 
>> During the rpm installation, a state directory is created and 
>> the uid/gid are set to rpcuser id. When statd fires up, those
>> uid/gids are obtained and used to set the process's uid/gid so
>> the daemon does not run as root..
>> 
>> The default NFS state directory is /var/lib/nfs. Since other
>> processes, like mountd and exportfs, read and write to that,
>> we don't want to muck around with its ownership. So a statd 
>> directory is created and the ownership of that directory 
>> is mucked with.
> 
> Shouldn't the configure option then be about running statd non-root
> and all things required for it?  E.g. do the set*uid, creating the
> new dir with the right owner and permissions, and using it?

I agree that these days we would choose command line options or build-time settings instead of reading the ownership of our state directory, but it's an ancient formal administrative interface.  

We're not creating anything new here, just making it easier for distros to customize.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




