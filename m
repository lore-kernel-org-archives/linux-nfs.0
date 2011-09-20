Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab1ITQQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 12:16:58 -0400
Message-ID: <4E78BC72.40303@RedHat.com>
Date: Tue, 20 Sep 2011 12:16:50 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] statd: Decouple statd's state directory from the
 NFS state directory
References: <1316531020-25071-1-git-send-email-steved@redhat.com> <20110920154011.GA6959@infradead.org>
In-Reply-To: <20110920154011.GA6959@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/20/2011 11:40 AM, Christoph Hellwig wrote:
> On Tue, Sep 20, 2011 at 11:03:40AM -0400, Steve Dickson wrote:
>> To allow greater flexibility to where statd's state is kept,
>> statd's state path can now be decoupled from the normal
>> NFS state directory.
>>
>> In configure.ac, the NSM_STATD_PATH definition will now define
>> the path to where the state information is kept. The default
>> value, /var/lib/nfs, can be redefined with the --with-statdpath
>> flag.
> 
> What is thje rationale for this?  And who would want to move it at
> compile time, not at run time?
It all has to do with statd not running as root... 

During the rpm installation, a state directory is created and 
the uid/gid are set to rpcuser id. When statd fires up, those
uid/gids are obtained and used to set the process's uid/gid so
the daemon does not run as root..

The default NFS state directory is /var/lib/nfs. Since other
processes, like mountd and exportfs, read and write to that,
we don't want to muck around with its ownership. So a statd 
directory is created and the ownership of that directory 
is mucked with.
 
steved.
 
