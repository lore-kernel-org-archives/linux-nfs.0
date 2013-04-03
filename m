Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:59965 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932295Ab3DCT5k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Apr 2013 15:57:40 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 03 Apr 2013 15:57:36 -0400
From: David Quigley <dpquigl@davequigley.com>
To: "Myklebust, Trond" <trond.myklebust@netapp.com>
Cc: Steve Dickson <steved@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 01/19] Security: Add hook to calculate context based on
 a negative dentry.
In-Reply-To: <1364945729.3026.7.camel@leira.trondhjem.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
 <1364939160-20874-2-git-send-email-SteveD@redhat.com>
 <1364945729.3026.7.camel@leira.trondhjem.org>
Message-ID: <a3ffb6cefc84dad5602a1e5d04093645@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/02/2013 19:35, Myklebust, Trond wrote:
> On Tue, 2013-04-02 at 17:45 -0400, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> There is a time where we need to calculate a context without the
>> inode having been created yet. To do this we take the negative 
>> dentry and
>> calculate a context based on the process and the parent directory 
>> contexts.
>>
>
> Can you remind me again why this is needed? Basing security decisions 
> on
> the namespace seems just seems to run against the basic selinux 
> concept.
> Is it for apparmor and tomoyo support in LNFS?

The thing is we aren't creating it based on the namespace. The negative 
dentry has a reference to its parent which is the label being used for 
the computation. The problem is there is no way for us to do this 
calculation in NFS because the place it needs to be done is lacking the 
actual inode so instead we use the process and the parent label. If 
there is a transition in place it would act on the parent label and 
process label anyway. Its not like we're deciding that /usr/foo/bar gets 
labeled with bar_t but instead we're saying that process foo created a 
file in a directory labeled foo_t so it becomes bar_t. Alternatively if 
no transition is in place we'd instead say that because foo is labeled 
foo_t we're creating a file underneath that so it gets labeled foo_t.
