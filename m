Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:56489 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab3EUSzS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 May 2013 14:55:18 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: RE: [PATCH 07/13] NFSv4: Introduce new label structure
Date: Tue, 21 May 2013 18:55:05 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA92878A146@SACEXCMBX04-PRD.hq.netapp.com>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
  <1368719808-14584-8-git-send-email-SteveD@redhat.com>
 <1369077151.6115.22.camel@leira.trondhjem.org> <519BC29E.6080803@RedHat.com>
In-Reply-To: <519BC29E.6080803@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Steve Dickson [mailto:SteveD@redhat.com]
> Sent: Tuesday, May 21, 2013 2:53 PM
> To: Myklebust, Trond
> Cc: David P. Quigley; Linux NFS list; Linux FS devel list; Linux Security List;
> SELinux List
> Subject: Re: [PATCH 07/13] NFSv4: Introduce new label structure
> 
> 
> 
> On 20/05/13 15:12, Myklebust, Trond wrote:
> >> diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
> >> > index 788128e..78d25b5 100644
> >> > --- a/include/uapi/linux/nfs4.h
> >> > +++ b/include/uapi/linux/nfs4.h
> >> > @@ -25,7 +25,7 @@
> >> >  #define NFS4_MAXNAMLEN		NAME_MAX
> >> >  #define NFS4_OPAQUE_LIMIT	1024
> >> >  #define NFS4_MAX_SESSIONID_LEN	16
> >> > -
> >> > +#define NFS4_MAXLABELLEN	2048
> > Why does this belong in the uapi?
> >
> Where do you want it?

Just put it in the kernel-only include/linux/nfs4.h

Thanks
  Trond
