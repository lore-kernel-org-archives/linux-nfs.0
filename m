Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751677Ab3EUSxV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 14:53:21 -0400
Message-ID: <519BC29E.6080803@RedHat.com>
Date: Tue, 21 May 2013 14:53:18 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 07/13] NFSv4: Introduce new label structure
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>  <1368719808-14584-8-git-send-email-SteveD@redhat.com> <1369077151.6115.22.camel@leira.trondhjem.org>
In-Reply-To: <1369077151.6115.22.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 20/05/13 15:12, Myklebust, Trond wrote:
>> diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
>> > index 788128e..78d25b5 100644
>> > --- a/include/uapi/linux/nfs4.h
>> > +++ b/include/uapi/linux/nfs4.h
>> > @@ -25,7 +25,7 @@
>> >  #define NFS4_MAXNAMLEN		NAME_MAX
>> >  #define NFS4_OPAQUE_LIMIT	1024
>> >  #define NFS4_MAX_SESSIONID_LEN	16
>> > -
>> > +#define NFS4_MAXLABELLEN	2048 
> Why does this belong in the uapi?
> 
Where do you want it?

steved.
