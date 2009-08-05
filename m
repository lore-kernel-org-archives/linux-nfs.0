From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/5] new statd [take 1]
Date: Wed, 5 Aug 2009 13:18:07 -0400
Message-ID: <20090805171807.GA9944@fieldses.org>
References: <20090804180334.21944.64404.stgit@matisse.1015granger.net> <618BB409-0166-46AA-84DD-A9A67259AA38@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54722 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934719AbZHERSI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 13:18:08 -0400
In-Reply-To: <618BB409-0166-46AA-84DD-A9A67259AA38@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2009 at 09:51:05AM -0400, Chuck Lever wrote:
> The big patch didn't make it through the mailing list, apparently.  I  
> didn't receive any kind of bounce message.
>
> Does anyone know who moderates this list and if there is a size limit?

I've had good luck with email to postmaster@vger.kernel.org for help
with this kind of problem in the past.

--b.

>
>
> On Aug 4, 2009, at 2:06 PM, Chuck Lever wrote:
>
>> Hi Steve-
>>
>> Here are some man page patches and the one big patch that adds the new
>> IPv6-capable statd.  I'd like to start socializing these changes to
>> expedite the new statd into mainline nfs-utils.
>>
>> ---
>>
>> Chuck Lever (5):
>>      nfs(5): update nfs(5) with details about IPv6 support
>>      nfs-utils: introduce new statd implementation
>>      statd: change default state dir to /var/lib/nfs/statd
>>      nfs(5): Remove trailing blanks
>>      nfs(5): Add description of lookupcache mount option
>>
>>
>> .gitignore                    |    4
>> Makefile.am                   |    4
>> aclocal/libcap.m4             |   15 +
>> aclocal/libsqlite3.m4         |   33 ++
>> aclocal/libtirpc.m4           |    2
>> configure.ac                  |   16 +
>> utils/Makefile.am             |    7
>> utils/mount/nfs.man           |  377 ++++++++++++------
>> utils/new-statd/Makefile.am   |  102 +++++
>> utils/new-statd/file.c        |  779 ++++++++++++++++++++++++++++++++ 
>> ++++++
>> utils/new-statd/hostname.c    |  520 +++++++++++++++++++++++++
>> utils/new-statd/main.c        |  319 ++++++++++++++++
>> utils/new-statd/nlmcall.c     |  525 ++++++++++++++++++++++++++
>> utils/new-statd/sm-notify.c   |  155 ++++++++
>> utils/new-statd/sm-notify.man |  286 ++++++++++++++
>> utils/new-statd/sm_inter.x    |  107 +++++
>> utils/new-statd/smncall.c     |  774 ++++++++++++++++++++++++++++++++ 
>> ++++++
>> utils/new-statd/start-statd   |   12 +
>> utils/new-statd/statd.h       |  135 +++++++
>> utils/new-statd/statd.man     |  388 +++++++++++++++++++
>> utils/new-statd/svc.c         |  841 ++++++++++++++++++++++++++++++++ 
>> +++++++++
>> utils/statd/Makefile.am       |    9
>> utils/statd/sm-notify.man     |   12 -
>> utils/statd/statd.man         |   10
>> 24 files changed, 5282 insertions(+), 150 deletions(-)
>> create mode 100644 aclocal/libcap.m4
>> create mode 100644 aclocal/libsqlite3.m4
>> create mode 100644 utils/new-statd/Makefile.am
>> create mode 100644 utils/new-statd/file.c
>> create mode 100644 utils/new-statd/hostname.c
>> create mode 100644 utils/new-statd/main.c
>> create mode 100644 utils/new-statd/nlmcall.c
>> create mode 100644 utils/new-statd/sm-notify.c
>> create mode 100644 utils/new-statd/sm-notify.man
>> create mode 100644 utils/new-statd/sm_inter.x
>> create mode 100644 utils/new-statd/smncall.c
>> create mode 100644 utils/new-statd/start-statd
>> create mode 100644 utils/new-statd/statd.h
>> create mode 100644 utils/new-statd/statd.man
>> create mode 100644 utils/new-statd/svc.c
>>
>> -- 
>> Chuck Lever <chuck.lever@oracle.com>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
