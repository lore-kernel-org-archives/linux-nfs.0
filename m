Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:7964 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755117Ab3BLXSQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Feb 2013 18:18:16 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "Linux FS devel list" <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: RE: [PATCH 00/15] lnfs: 3.8-rc6 release
Date: Tue, 12 Feb 2013 23:18:13 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91F3CE6E2@sacexcmbx05-prd.hq.netapp.com>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
 <20130212231113.GQ10267@fieldses.org>
In-Reply-To: <20130212231113.GQ10267@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We definitely do need a 4.2 minor version label. As you said, that shouldn't be hard since 4.2 is basically 4.1 with new enhancements, and we already have all the minorversion machinery ready and working.

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Tuesday, February 12, 2013 6:11 PM
> To: Steve Dickson
> Cc: Myklebust, Trond; J. Bruce Fields; David P. Quigley; Linux NFS list; Linux FS
> devel list; Linux Security List; SELinux List
> Subject: Re: [PATCH 00/15] lnfs: 3.8-rc6 release
> 
> So originally I thought Dave was saying we'd try to get the label change
> attribute in the initial submission.  I guess it'll be coming later instead?
> 
> This is going to be a part of NFSv4.2, so shouldn't this really come with
> patches to implement minor version 2?  (Should be totally trivial as it doesn't
> have to do anything other than labeled NFS for now.)
> 
> If not, that's another reason why we don't want to recommend building this
> by default.  Though maybe advertising labeled NFS support in v4.1 won't
> cause a problem for any implementation in practice, I don't know.
> 
> --b.
