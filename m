Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34785 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932198AbbJMNd5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2015 09:33:57 -0400
Received: by oiak8 with SMTP id k8so9423286oia.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2015 06:33:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151013122128.GD10632@dot.dmz.freshdot.net>
References: <20151013122128.GD10632@dot.dmz.freshdot.net>
Date: Tue, 13 Oct 2015 09:33:56 -0400
Message-ID: <CAHQdGtRUrWuahu7iQbQQLUeB_ZPFoqFLTXFhHa0pCuKGp9ycWA@mail.gmail.com>
Subject: Re: CAP(abilities) and NFS mounted storage
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2015 at 8:21 AM, Sander Smeenk <ssmeenk@freshdot.net> wrote:
> Hi,
>
> I'm struggling with a permission issue involving NFS-mounted storage and
> a certain set of capabilities set by cap_set_flags(). The behaviour
> differs for local storage versus NFS mounted storage.
>
> I have this structure on local storage (spinning disks):
> | # namei -l /opt/home/sites/t/test/dir/structure/.htaccess
> | f: /opt/home/sites/t/test/dir/structure/.htaccess
> | drwxr-xr-x root      root                 /
> | drwxr-xr-x root      root                 opt
> | drwxr-x--x root      root                 home
> | drwx--x--x root      root                 sites
> | drwx--x--x root      root                 t
> | drwx------ http-test http-linux_http-test test
> | drwx--x--x http-test http-linux_http-test dir
> | drwx------ http-test http-linux_http-test structure
> | -rw------- http-test http-linux_http-test .htaccess
>
> And this same structure on NFS-mounted storage:
> | # namei -l /mnt/home/sites/t/test/dir/structure/.htaccess
> | f: /mnt/home/sites/t/test/dir/structure/.htaccess
> | drwxr-xr-x root      root                 /
> | drwxr-xr-x root      root                 mnt
> | drwxr-x--x root      root                 home
> | drwx--x--x root      root                 sites
> | drwx--x--x root      root                 t
> | drwx------ http-test http-linux_http-test test
> | drwx--x--x http-test http-linux_http-test dir
> | drwx------ http-test http-linux_http-test structure
> | -rw------- http-test http-linux_http-test .htaccess
>
> The NFS server is a NetApp filer (-sec=sys,rw=clientip,root=clientip).
> I tried this with a Linux server too (rw,no_root_squash,no_subtree_check).
> The client is always a Linux machine (rw,vers=3,tcp,bg).
>
> I made a little C program to illustrate the issue. It drops privileges
> to www-data and tries to access the file specified with a certain set of
> capabilties[*].
>
> This works for local storage, fails on NFS:
>
> LOCAL:
> | # ./capset /opt/home/sites/t/test/dir/structure/.htaccess
> | euid:33 uid:33 egid:33 gid:33
> | Process capabilities: = cap_dac_read_search,cap_setgid,cap_setuid,cap_sys_nice+ep;
> | Access: success!
>
> NFS:
> | # ./capset /mnt/home/sites/t/test/dir/structure/.htaccess
> | euid:33 uid:33 egid:33 gid:33
> | Process capabilities: = cap_dac_read_search,cap_setgid,cap_setuid,cap_sys_nice+ep;
> | Access: error (13): Permission denied
>
> The source for capset can be seen pasted at https://8n1.org/10831/12f0
> Lines >=42
>
> I've experimented with different capabilties, but CAP_DAC_OVERRIDE is
> not enough. I'd very much like to hear if it is possible for this to
> work on NFS like it does on local storage.

This will not work on NFS. The server, which enforces permissions, has
no way to know what capabilities your process has on the client.

Cheers
  Trond
