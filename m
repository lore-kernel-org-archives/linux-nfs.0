Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:35714 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964914AbcHaQg1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 12:36:27 -0400
Received: by mail-it0-f48.google.com with SMTP id e124so54108144ith.0
        for <linux-nfs@vger.kernel.org>; Wed, 31 Aug 2016 09:36:27 -0700 (PDT)
MIME-Version: 1.0
From: Matt Garman <matthew.garman@gmail.com>
Date: Wed, 31 Aug 2016 11:36:25 -0500
Message-ID: <CAJvUf-BsCHCQZkWu8iKMbQTESANfrLjtH8uMqtzdUNcj1SmJ9Q@mail.gmail.com>
Subject: gss context cache and nfsv4
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I'm trying to understand the nuances of GSS security contexts with
regards to NFSv4 with sec=krb5 under Linux.  How does the in-kernel
caching of these contexts work, i.e. what is the mechanism?  And
specifically,

- How long do the in-kernel context caches live?
- Is there any way to query the in-kernel context caches?
- Is it possible for an individual user to have *multiple* in-kernel
context caches?


A simple example, for discussion:

Say host "testhost" is an NFSv4 (sec=krb5p) client.  In particular,
the NFS mount is for user home directories.  If I login to "testhost"
and run "klist", I see I have two tickets, the TGT and the NFS service
ticket for the home directory mount.  Furthermore, my KRB5CC
environment variable is set, and points to
/tmp/krb5cc_uid_randomstring.  So far, so good, no surprises.

Now, if I delete the /tmp/krb5cc file, or run kdestroy, then run
klist, it says "klist: No credentials cache found (ticket cache
FILE:/tmp/krb5cc_uid_whatever)".  Also not surprising.  However, I
still have access to my home directory.  Now if I just do nothing on
that terminal, and wait long enough, eventually I'll get "Permission
Denied" on my home directory.

That's somewhat surprising but readily explained by the in-kernel
credentials cache.  Also explicitly explained by the NFSv4 FAQ[1]:

6. I am accessing an NFSv4 mount via Kerberos and then I do a
kdestroy, but I am still able to access the NFS data. Why?

The kernel code caches the gssapi context that was negotiated using
the Kerberos credentials. Destroying the credentials does not destroy
the context in the kernel. We plan to change this behavior when moving
to use the new key ring kernel support to store credentials and
contexts.


How long will this in-kernel context persist?  I have tried to
determine this experimentally, but it appears to be non-deterministic
(or I haven't designed the right experiment).  It almost seems like if
you keep "using" the in-kernel context (e.g. continuously create and
destroy random files on the Kerberized NFS share), that it lasts
longer.  (As opposed to just sitting idle at the terminal.)


Likewise, let's say I have two separate ssh sessions into "testhost".
In this case, I'll have two /tmp/krb5cc_uid_random files.  Do I also
have two separate in-kernel context caches, or just one?  What happens
if I run kdestroy on one terminal, but not the other?  How does that
affect the in-kernel cache(s)?


[1] http://www.citi.umich.edu/projects/nfsv4/linux/faq/

Thanks,
Matt
