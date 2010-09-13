Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57866 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751867Ab0IMKQg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 06:16:36 -0400
Message-ID: <4C8DF9FE.5020506@panasas.com>
Date: Mon, 13 Sep 2010 12:16:30 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file layout
 driver
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>	<1283450419-5648-9-git-send-email-iisaman@netapp.com>	<1284147111.10062.74.camel@heimdal.trondhjem.org> <AANLkTi=6vcQC1k28B=aKJbN=jRBipoff3+79BpgLxtXw@mail.gmail.com>
In-Reply-To: <AANLkTi=6vcQC1k28B=aKJbN=jRBipoff3+79BpgLxtXw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-11 00:11, Fred Isaman wrote:
> On Fri, Sep 10, 2010 at 12:31 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
>> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>>
>>> This driver just registers itself and supplies trivial mount/umount functions.
>>>
>>> Signed-off-by: TBD - melding/reorganization of several patches
>>> ---
>>>  fs/nfs/Kconfig          |    5 +++
>>>  fs/nfs/Makefile         |    3 ++
>>>  fs/nfs/nfs4filelayout.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++
>>>  include/linux/nfs_fs.h  |    1 +
>>>  4 files changed, 98 insertions(+), 0 deletions(-)
>>>  create mode 100644 fs/nfs/nfs4filelayout.c
>>>
>>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>>> index 5f1b936..980f2dc 100644
>>> --- a/fs/nfs/Kconfig
>>> +++ b/fs/nfs/Kconfig
>>> @@ -82,6 +82,11 @@ config NFS_V4_1
>>>
>>>         If unsure, say N.
>>>
>>> +config PNFS_FILE_LAYOUT
>>> +     tristate
>>> +     depends on NFS_FS && NFS_V4_1
>>> +     default m
>>
>> Should be 'default y', otherwise it has an implicit dependency on
>> CONFIG_MODULES.
>>
> 
> The idea was that normally the driver would compile as a module, and
> use loading/unloading of it to control whether pnfs is supported.
> 
> Is there a way to do this that does not introduce the implicit dependency?
> 

The explicit dependency on NFS_FS does the trick for you (as it is currently in the
pnfs tree), so the default is set to m iff NFS_FS==m

Benny
