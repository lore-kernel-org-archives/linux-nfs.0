From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/5] NFS: set transport defaults after mount option
	parsing is finished
Date: Thu, 12 Jun 2008 12:57:37 -0400
Message-ID: <1213289857.14478.10.camel@localhost>
References: <20080612163416.13197.92911.stgit@manray.1015granger.net>
	 <20080612163756.13197.37893.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53088 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752224AbYFLQ5k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 12:57:40 -0400
In-Reply-To: <20080612163756.13197.37893.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-06-12 at 12:37 -0400, Chuck Lever wrote:
> Address some unfortunate mount option parsing behavior by setting certain
> transport-based defaults *after* option parsing is complete.
> 
>  o  Some options don't obey the "rightmost wins" rule.  Jeff Layton
>     noticed that specifying the "proto=" mount option after the "retrans"
>     or "timeo" options will cause the retrans and timeo values to be
>     overwritten with default settings.
> 
>     Allow these options to be specified in any order without unexpectedly
>     reverting retrans and timeo to their default.
> 
>  o  I've received several reports that text-based mounting through
>     firewalls that block UDP fails, even if "proto=tcp" is specified.
> 
>     If a user specifies "proto=tcp" via the legacy mount API, the mount
>     command also uses TCP to contact the server's mount daemon.  Ditto
>     for "proto=udp".  We want the kernel's mount option to emulate this
>     behavior; however, we still want the default mount protocol to be UDP
>     if no transport options were specified.

Why is it necessary to set these defaults in nfs_parse_mount_options?
This is quite unrelated to parsing of the mount string.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
