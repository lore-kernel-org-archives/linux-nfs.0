Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36339 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbbEGPAG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 11:00:06 -0400
Received: by pdea3 with SMTP id a3so43532662pde.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 08:00:05 -0700 (PDT)
Message-ID: <554B7DED.2000403@gmail.com>
Date: Thu, 07 May 2015 22:59:57 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>, kinglongmee@gmail.com
Subject: Re: [PATCH 3/3] osd_login: add --disable-osdlogin for configure osd_login
References: <552E8FE8.1070601@gmail.com> <554B73D8.40007@RedHat.com>
In-Reply-To: <554B73D8.40007@RedHat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/7/2015 10:16 PM, Steve Dickson wrote:
> On 04/15/2015 12:20 PM, Kinglong Mee wrote:
>> Eino reports, 
>> Configure using the following command
>>
>>     ./configure --prefix=/home/username/installs/tmp --exec-prefix=/home/username/installs/tmp
>>
>> When running "make install" most of the packages are put under /home/username/installs/tmp, but for some reason the install script tries to put osd_login under /sbin, which results in an error:
>>
>>     Making install in osd_login
>>     make[2]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>>     make[3]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>>         /usr/bin/mkdir -p '/sbin'
>>         /usr/bin/install -c osd_login '/sbin'
>>         /usr/bin/install: cannot remove ‘/sbin/osd_login’: Permission denied
>>         make[3]: *** [install-dist_sbinSCRIPTS] Error 1 
>>
>> Reported-by: Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> I changed this just a bit... Instead of disabling it, I change
> it to enable the installation which is 'no' by default.
> 
> Committed... 
> 
> steved.
>  
>> ---
>>  configure.ac      | 7 +++++++
>>  utils/Makefile.am | 5 ++++-
>>  2 files changed, 11 insertions(+), 1 deletion(-)
>>
>> diff --git a/configure.ac b/configure.ac
>> index d4301a2..33a2f57 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -216,6 +216,13 @@ AC_ARG_ENABLE(nfsdcltrack,
>>  	enable_nfsdcltrack=$enableval,
>>  	enable_nfsdcltrack="yes")
>>  
>> +AC_ARG_ENABLE(osdlogin,
>> +	[AC_HELP_STRING([--disable-osdlogin],
>> +			[disable osd_login scripts @<:@default=no@:>@])],
>> +	enable_osdlogin=$enableval,
>> +	enable_osdlogin="yes")
>> +	AM_CONDITIONAL(CONFIG_OSD_LOGIN, [test "$enable_osdlogin" = "yes" ])
>> +
>>  dnl Check for TI-RPC library and headers
>>  AC_LIBTIRPC
>>  
>> diff --git a/utils/Makefile.am b/utils/Makefile.am
>> index b892dc8..6dd4a57 100644
>> --- a/utils/Makefile.am
>> +++ b/utils/Makefile.am
>> @@ -25,6 +25,10 @@ if CONFIG_NFSDCLTRACK
>>  OPTDIRS += nfsdcltrack
>>  endif
>>  
>> +if CONFIG_OSD_LOGIN
>> +OPTDIRS += osd_login
>> +endif
>> +
>>  SUBDIRS = \
>>  	exportfs \
>>  	mountd \
>> @@ -32,7 +36,6 @@ SUBDIRS = \
>>  	nfsstat \
>>  	showmount \
>>  	statd \
>> -	osd_login \
>>  	$(OPTDIRS)
>>  
>>  MAINTAINERCLEANFILES = Makefile.in

Miss updating of utils/Makefile.am in your tree.

http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commitdiff;h=3e28fe73af023bf42e0d654146bfb9314b4d8438

thanks,
Kinglong Mee
