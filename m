Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49841 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370Ab3JVPcS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 11:32:18 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "<steved@redhat.com>" <steved@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
Date: Tue, 22 Oct 2013 15:32:16 +0000
Message-ID: <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
 <1382454148.9794.72.camel@willson.li.ssimo.org>
In-Reply-To: <1382454148.9794.72.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 22, 2013, at 11:02 AM, Simo Sorce <simo@redhat.com> wrote:

> On Tue, 2013-10-22 at 10:22 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> This is an RFC patchset, which will be used for testing.
>> 
>> This patchset requires the "SUNRPC: destroy gss_cred and context on Kerberos credential destruction" kernel patchset.
>> 
>> We need to do a lot of testing to ensure that once kdestroy and gss-ctx
>> gss_user_destroy is called, all existing buffered
>> writes using the 'destroyed gss credential + context' are serviced.
>> 
>> Differences from version 1:
>> 
>> - moved from nfstgt_login and nfstgt_logout to gsskeyd.
>> - gsskeyd automatically creates gss-ctx key on kinit and destroys the gss-ctx
>> key on kdestroy.
>> 
>> gsskeyd will need to act differently for different krb5 credential caches.
> 
> Why ?

Just need different parsing to know which directory to poll. 
> 
>> For example, some versions of gssd store FILE credentials in FILE:/tmp/krb5cc_<UID>
>> while this code, written for fedora 19 uses FILE:/run/user/<UID>/krb5cc/tgt.
> 
> This is incorrect, Fedora 19 use DIR type ccaches, so you should
> reference a cache withing the dir type, which will notmally be something
> like: DIR:/run/user/<uidnumber>/krb5cc for the whole collection or
> DIR::/run/user/<uidnumber>/krb5cc/txtXXXXXX for the sepcific cache.
> 
> However note that due to issues with DIR type caches we are moving to a
> new KEYRING based type of cache in F20, so assuming any specific type of
> cache is a dead start.

But I'm not assuming any kind of kerberos credential cache! I just coded to one type for this RFC.
Didn't you see my KEYRING based ccache comment below?

> 
>> As Trond suggested, if we keep gsskeyd separate from gssd, we could set up a
>> configuration file along the lines of the keytools' request-key.conf file to
>> allow both NFS and CIFS (and other filesystems) to install plugin handlers
>> for kinit/kdestroy events.
> 
> Given in many cases (the desirable ones at least) kerberos credentials
> are not inited via kinit, but rather by things like pam_krb5, sssd, or
> directly imported via sshd, I am trying to understand how you are going
> to address the majority of these cases.

All of these cases use a kerberos credential cache which if is of type FILE the gsskeyd can poll inotify and if it is of type KEY: then gsskeyd adds the gss-ctx key to the Kerberos keyring (that is the theory :)) so the same code services kinit/pam_krb5

> 
> Should users put gsskeyd in their .profile/.bashrc files or something ?
> 
>> Else, we could have gssd be the process to poll inotify (given
>> that it already polls rpc_pipefs) and then just have it fork off the
>> subprocess if and when it sees an interesting event.
> 
> What is an 'interesting' event ?

TGT (used for NFS TGS) creation/destruction

> 
>> We need to investigate how this works when the kernel keyring is used for
>> Kerberos credentials. I believe that in this case gsskeyd can add the gss-ctx
>> key to the kerberos keyring, and it will get destroyed along with all other
>> keys at kdestroy.
> 
> Is there any reason why you are doing this work with an utility that is
> separate from gssd or libkrb5 ?

Yes  - to allow both NFS and CIFS (and other filesystems) to install plugin handlers for kerberos credential cache creation/destruction events.

But, having gssd do it is fine, or having a client plugin in libkrb5 is also fine.

> 
> I think the only sensible way to handle something like this is by adding
> support directly in libkrb5, I do not see something external ever
> working reliably.

I agree that I should persue a libkrb5 approach.

> I am not against it for testing purposes, but then does it need to be
> committed to nfs-utils ?

Did you not see the "This is an RFC patchset"? I'm not asking for a commit to nfs-utils, but "request for comments" which you just did!  Thanks :)

-->Andy

> 
> Simo.
> 
>> Andy Adamson (2):
>>  GSSD add cc_name to upcall
>>  ANDROS: update gsskeyd to use new /run/user/UID/krb5cc/tgt cache file
>> 
>> Weston Andros Adamson (1):
>>  WIP: Add gsskeyd
>> 
>> configure.ac            |   1 +
>> utils/Makefile.am       |   2 +-
>> utils/gssd/gssd_proc.c  |  37 ++++-
>> utils/gssd/krb5_util.c  |   2 +-
>> utils/gssd/krb5_util.h  |   1 +
>> utils/gsskeyd/gsskeyd.c | 371 ++++++++++++++++++++++++++++++++++++++++++++++++
>> 6 files changed, 408 insertions(+), 6 deletions(-)
>> create mode 100644 utils/gsskeyd/gsskeyd.c
>> 
> 
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 

