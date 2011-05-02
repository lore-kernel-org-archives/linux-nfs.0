From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: sharing some files (and not folders) over NFS
Date: Mon, 02 May 2011 10:40:23 -0400
Message-ID: <1304347223.7830.8.camel@lade.trondhjem.org>
References: <416818.76742.qm@web111712.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: nfs <linux-nfs@vger.kernel.org>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4024 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759337Ab1EBOkY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2011 10:40:24 -0400
In-Reply-To: <416818.76742.qm-gl49SJLIJaiZZBmlwP4mLPu2YVrzzGjVVpNB7YpNyf8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-05-02 at 07:34 -0700, Mahmood Naderan wrote:
> Hi,
> Is it possible to share passwd, group and shadow files over nfs?
> Since a shared folder needs to be defined in /etc/fstab (on the destination), I wonder how can I do that for files?

Diskless/NFSroot systems do this all the time.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

