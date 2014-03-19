Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:55313 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965071AbaCSNY3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 09:24:29 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 19 Mar 2014 07:24:28 -0600
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B733EC9003E
	for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2014 09:24:21 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2JDOPpY9306422
	for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2014 13:24:25 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2JDOOMM027671
	for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2014 09:24:25 -0400
Date: Wed, 19 Mar 2014 08:24:24 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Mauricio Tavares <raubvogel@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Exporting partition mounted inside another
Message-ID: <20140319132423.GA18831@us.ibm.com>
References: <CAHEKYV7JKuYaQv7c+CEtUZN+AXgR0XamphEtD+on1kw7FSiakg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHEKYV7JKuYaQv7c+CEtUZN+AXgR0XamphEtD+on1kw7FSiakg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mauricio Tavares [raubvogel@gmail.com] wrote:
>     I have in my NFSv4 server a directory called /exports where I
> place everything I want to export:
> 
> /dev/vg1/logs            19.7G    651.0M     19.0G   3% /export/logs
> /dev/vg1/home           196.9G    163.8G     32.9G  83% /export/home
> /dev/vg1/pickles        504.0G     62.7G    441.2G  12% /export/home/pickles
> /dev/vg1/stuff           98.4G     21.9G     76.5G  22% /export/public
> 
> Note that user pickles does have a lot of crap, so he gets to have his
> own partition. My own home dir is in /export/home/raub. Now, I export
> them as:
> 
> spindizzy> cat /etc/exports
> /export 10.0.0.0/24(ro,fsid=0,no_subtree_check,sync)
> /export/logs 10.0.0.21/24(rw,insecure,root_squash,no_subtree_check,sync)
> /export/home 10.0.0.0/24(rw,insecure,root_squash,no_subtree_check,sync)
> /export/public 10.0.0.0/24(ro,insecure,root_squash,no_subtree_check,sync)
> spindizzy>

You didn't export /export/home/pickles file system. Export that by
listing it in /etc/exports. Also, look at (crossmnt or no_hide options)

> 
> and mount /export/user using automount,
> 
> cat /etc/auto.home
> #
> # File: /etc/auto.home
> #
> *   -fstype=nfs4,hard,intr,rsize=8192,wsize=8192 fileserver:/home/&
> 
> When I try to automount (say by logging in as saif user) pickles'
> homedir, it does not mount /dev/vg1/pickles. Instead, it just mounts
> it as if only existed in /dev/vg1/home/pickles in the fileserver:
> 
> fileserver:/home/raub     197G  164G   33G  84% /home/raub
> fileserver:/home/pickles  197G  164G   33G  84% /home/pickles
> 
> Sounds like I misconfigured my /etc/exports, but how?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

