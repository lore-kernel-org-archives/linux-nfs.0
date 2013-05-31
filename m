Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755767Ab3EaVMg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 May 2013 17:12:36 -0400
Message-ID: <51A91241.7090703@RedHat.com>
Date: Fri, 31 May 2013 17:12:33 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Bryan Schumaker <bjschuma@netapp.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 05/13] NFSv4.2: Added NFS v4.2 support to the NFS client
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com> <1368719808-14584-6-git-send-email-SteveD@redhat.com> <51A7BBEB.60005@netapp.com>
In-Reply-To: <51A7BBEB.60005@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 30/05/13 16:51, Bryan Schumaker wrote:
>> +#if defined(CONFIG_NFS_V4_2)
>> > +#define NFS4_MAX_MINOR_VERSION 2
>> > +#else
>> >  #if defined(CONFIG_NFS_V4_1)
>> >  #define NFS4_MAX_MINOR_VERSION 1
>> >  #else
>> >  #define NFS4_MAX_MINOR_VERSION 0
>> >  #endif /* CONFIG_NFS_V4_1 */
>> > +#endif /* CONFIG_NFS_V4_2 */
> Could this be done with a #elif so we don't need the nested endif-s?
Sure... 

steved.
