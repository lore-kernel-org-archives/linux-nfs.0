Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:31480 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757741Ab3DBXfd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2013 19:35:33 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "Linux FS devel list" <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 01/19] Security: Add hook to calculate context based on
 a negative dentry.
Date: Tue, 2 Apr 2013 23:35:29 +0000
Message-ID: <1364945729.3026.7.camel@leira.trondhjem.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
	 <1364939160-20874-2-git-send-email-SteveD@redhat.com>
In-Reply-To: <1364939160-20874-2-git-send-email-SteveD@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 17:45 -0400, Steve Dickson wrote:
> From: David Quigley <dpquigl@davequigley.com>
> 
> There is a time where we need to calculate a context without the
> inode having been created yet. To do this we take the negative dentry and
> calculate a context based on the process and the parent directory contexts.
> 

Can you remind me again why this is needed? Basing security decisions on
the namespace seems just seems to run against the basic selinux concept.
Is it for apparmor and tomoyo support in LNFS?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
