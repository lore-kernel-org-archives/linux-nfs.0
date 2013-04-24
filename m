Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:35821 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758514Ab3DXWOS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 18:14:18 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 24 Apr 2013 18:14:16 -0400
From: David Quigley <dpquigl@davequigley.com>
To: Steve Dickson <steved@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>, <eparis@redhat.com>,
        <sds@tycho.nsa.gov>
Subject: Re: [PATCH 04/17] Security: Add hook to calculate context based on
 a negative dentry.
In-Reply-To: <517858D1.5000406@RedHat.com>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
 <1366834683-29075-5-git-send-email-SteveD@redhat.com>
 <20130424220258.GO20275@fieldses.org> <517858D1.5000406@RedHat.com>
Message-ID: <faf7db0bcd9b208c201a652c718c720c@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/24/2013 18:12, Steve Dickson wrote:
> On 24/04/13 18:02, J. Bruce Fields wrote:
>> n Wed, Apr 24, 2013 at 04:17:50PM -0400, Steve Dickson wrote:
>>> > From: David Quigley <dpquigl@davequigley.com>
>>> >
>>> > There is a time where we need to calculate a context without the
>>> > inode having been created yet. To do this we take the negative 
>>> dentry and
>>> > calculate a context based on the process and the parent directory 
>>> contexts.
>> How can we get review from security/selinux folks?  I can't apply 
>> these
>> without....
> Its my understand they have been reviewed a number times... And they 
> have not
> change since I've working on these patches...
>
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

That is correct. They have been acked in the past and haven't changed 
at all since then. I have contacted Eric Paris about reviewing them 
anyway so you can have a more recent ack on the patches.

Dave
