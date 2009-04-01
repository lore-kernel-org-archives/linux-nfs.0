From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Wed, 01 Apr 2009 11:31:21 +0300
Message-ID: <49D32659.8040207@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229069-8636-1-git-send-email-bhalevy@panasas.com> <20090401043301.GA29339@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15004 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753469AbZDAIbZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 04:31:25 -0400
In-Reply-To: <20090401043301.GA29339@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 01, 2009, 7:33 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Sat, Mar 28, 2009 at 11:31:09AM +0300, Benny Halevy wrote:
>> Added CONFIG_NFSD_V4_1 and made it depend upon NFSD_V4 and EXPERIMENTAL
>> Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment
> 
> Stupid question: do we need CONFIG_NFSD_V4_1 at all?  How many people
> will want to build a kernel with v4.0 but not v4.1?

That's a good question.  I'd love to get rid of it
and it seems like like distros, at least RH are going to have it
configured-in anyway.

If the main reason to turn 4.1 support off is bugs affecting 4.0
then I'd much rather fix these bugs rather than hide them.

> 
> (And: do we have an interface that allows turning off 4.1 at run-time?
> That's more important than the config option.)

No, it's still on our todo list.  We haven't thought this completely
through, though.  Where would be the best place to implement that?
Should this be an export option or an nfsd tunable?

Benny

> 
> --b.
> 
>> At the moment we're expecting folks trying out nfs41 to
>> actively participate in the development process by helping us
>> debug issues and ideally send patches to fix problems.
>>
>> [trailing space fixed]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/Kconfig |    9 +++++++++
>>  1 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
>> index 503b9da..1f2f893 100644
>> --- a/fs/nfsd/Kconfig
>> +++ b/fs/nfsd/Kconfig
>> @@ -79,3 +79,12 @@ config NFSD_V4
>>  	  available from http://linux-nfs.org/.
>>  
>>  	  If unsure, say N.
>> +
>> +config NFSD_V4_1
>> +	bool "NFS server support for NFSv4.1 (DEVELOPER ONLY)"
>> +	depends on NFSD_V4 && EXPERIMENTAL
>> +	help
>> +	  This option enables support for minor version 1 of the NFSv4 protocol
>> +	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS server.
>> +
>> +	  Unless you're an NFS developer, say N.
>> -- 
>> 1.6.2.1
>>
