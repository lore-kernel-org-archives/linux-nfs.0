Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754217Ab3EaVLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 May 2013 17:11:54 -0400
Message-ID: <51A91212.7010901@RedHat.com>
Date: Fri, 31 May 2013 17:11:46 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/13] lnfs: 3.10-rc2 release
References: <1369241446-7680-1-git-send-email-SteveD@redhat.com> <1369943609.3111.4.camel@leira.trondhjem.org>
In-Reply-To: <1369943609.3111.4.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 30/05/13 15:53, Myklebust, Trond wrote:
> Bryan found a problem with the NFSv4.2 enabling patch above: the
> callback channel needs to recognise minor version 2 CB_COMPOUND. There
> are several places in the current callback code where people have hacked
> the hard coded value '1' for the minor version field... :-(
> 
> Bryan is working on a fix for us that I will just apply on top of the
> existing labeled NFS branch.
Thank you!

steved.
