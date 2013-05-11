Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:41000 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756416Ab3EKC4e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:56:34 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andreas Radke <a.radke@arcor.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 ACL issues since 3.0.72 leading to corrupt files (xfs)
Date: Sat, 11 May 2013 02:56:33 +0000
Message-ID: <1368240992.2998.6.camel@leira.trondhjem.org>
References: <20130510215553.0a1130be@laptop64.home>
In-Reply-To: <20130510215553.0a1130be@laptop64.home>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-05-10 at 21:55 +0200, Andreas Radke wrote:
> I'm running a server with a NFSv4 share drive that also hosts a Mail
> directory I provide with dovecot IMAP server. Dovecot has ACL plugin
> disabled.
> 
> Since the 4 NFSv4 ACL related commits in kernel 3.0.72 (and all other
> stable kernels) all kernels until the recent stable releases give such
> errors when changing :

Which 4 NFSv4 acl related commits?

Have you bisected in order to figure out which one is the culprit? If
not, how do you know that this is related to NFSv4 acl changes?

> imap(andyrtr):
> Error:maildir_file_do(/mnt/share/andyrtr/Mail/.Mailinglisten.Linux-stable/cur/msg.MFVZBC:2,):
> Filename keeps changing
>
> These are file system errors. I need to run xfs_repair on the drive
> and then need to stay with an outdated kernel.
>
> I think this is a serious regression. Can somebody confirm it and 
> tell me if this should be reported somewhere to a bug tracker 
> against nfs/xfs/... and how to solve this?
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
