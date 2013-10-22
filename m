Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927Ab3JVPCa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 11:02:30 -0400
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
From: Simo Sorce <simo@redhat.com>
To: andros@netapp.com
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1382451757-3032-1-git-send-email-andros@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Oct 2013 11:02:28 -0400
Message-ID: <1382454148.9794.72.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-10-22 at 10:22 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> This is an RFC patchset, which will be used for testing.
> 
> This patchset requires the "SUNRPC: destroy gss_cred and context on Kerberos credential destruction" kernel patchset.
> 
> We need to do a lot of testing to ensure that once kdestroy and gss-ctx
> gss_user_destroy is called, all existing buffered
> writes using the 'destroyed gss credential + context' are serviced.
> 
> Differences from version 1:
> 
> - moved from nfstgt_login and nfstgt_logout to gsskeyd.
> - gsskeyd automatically creates gss-ctx key on kinit and destroys the gss-ctx
> key on kdestroy.
> 
> gsskeyd will need to act differently for different krb5 credential caches.

Why ?

> For example, some versions of gssd store FILE credentials in FILE:/tmp/krb5cc_<UID>
> while this code, written for fedora 19 uses FILE:/run/user/<UID>/krb5cc/tgt.

This is incorrect, Fedora 19 use DIR type ccaches, so you should
reference a cache withing the dir type, which will notmally be something
like: DIR:/run/user/<uidnumber>/krb5cc for the whole collection or
DIR::/run/user/<uidnumber>/krb5cc/txtXXXXXX for the sepcific cache.

However note that due to issues with DIR type caches we are moving to a
new KEYRING based type of cache in F20, so assuming any specific type of
cache is a dead start.

> As Trond suggested, if we keep gsskeyd separate from gssd, we could set up a
> configuration file along the lines of the keytools' request-key.conf file to
> allow both NFS and CIFS (and other filesystems) to install plugin handlers
> for kinit/kdestroy events.

Given in many cases (the desirable ones at least) kerberos credentials
are not inited via kinit, but rather by things like pam_krb5, sssd, or
directly imported via sshd, I am trying to understand how you are going
to address the majority of these cases.

Should users put gsskeyd in their .profile/.bashrc files or something ?

> Else, we could have gssd be the process to poll inotify (given
> that it already polls rpc_pipefs) and then just have it fork off the
> subprocess if and when it sees an interesting event.

What is an 'interesting' event ?

> We need to investigate how this works when the kernel keyring is used for
> Kerberos credentials. I believe that in this case gsskeyd can add the gss-ctx
> key to the kerberos keyring, and it will get destroyed along with all other
> keys at kdestroy.

Is there any reason why you are doing this work with an utility that is
separate from gssd or libkrb5 ?

I think the only sensible way to handle something like this is by adding
support directly in libkrb5, I do not see something external ever
working reliably.
I am not against it for testing purposes, but then does it need to be
committed to nfs-utils ?

Simo.

> Andy Adamson (2):
>   GSSD add cc_name to upcall
>   ANDROS: update gsskeyd to use new /run/user/UID/krb5cc/tgt cache file
> 
> Weston Andros Adamson (1):
>   WIP: Add gsskeyd
> 
>  configure.ac            |   1 +
>  utils/Makefile.am       |   2 +-
>  utils/gssd/gssd_proc.c  |  37 ++++-
>  utils/gssd/krb5_util.c  |   2 +-
>  utils/gssd/krb5_util.h  |   1 +
>  utils/gsskeyd/gsskeyd.c | 371 ++++++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 408 insertions(+), 6 deletions(-)
>  create mode 100644 utils/gsskeyd/gsskeyd.c
> 


-- 
Simo Sorce * Red Hat, Inc * New York

