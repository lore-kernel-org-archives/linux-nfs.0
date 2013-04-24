Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758459Ab3DXWMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 18:12:45 -0400
Message-ID: <517858D1.5000406@RedHat.com>
Date: Wed, 24 Apr 2013 18:12:33 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 04/17] Security: Add hook to calculate context based on
 a negative dentry.
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com> <1366834683-29075-5-git-send-email-SteveD@redhat.com> <20130424220258.GO20275@fieldses.org>
In-Reply-To: <20130424220258.GO20275@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/04/13 18:02, J. Bruce Fields wrote:
> n Wed, Apr 24, 2013 at 04:17:50PM -0400, Steve Dickson wrote:
>> > From: David Quigley <dpquigl@davequigley.com>
>> > 
>> > There is a time where we need to calculate a context without the
>> > inode having been created yet. To do this we take the negative dentry and
>> > calculate a context based on the process and the parent directory contexts.
> How can we get review from security/selinux folks?  I can't apply these
> without....
Its my understand they have been reviewed a number times... And they have not
change since I've working on these patches... 

steved.
