Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f173.google.com ([209.85.213.173]:50477 "EHLO
	mail-ye0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756363Ab3HFUHw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Aug 2013 16:07:52 -0400
Received: by mail-ye0-f173.google.com with SMTP id m14so129153yen.4
        for <linux-nfs@vger.kernel.org>; Tue, 06 Aug 2013 13:07:52 -0700 (PDT)
Message-ID: <52015795.9060003@gmail.com>
Date: Tue, 06 Aug 2013 16:07:49 -0400
From: Bryan Schumaker <bjschuma@gmail.com>
MIME-Version: 1.0
To: Brian De Wolf <bldewolf@csupomona.edu>
CC: Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS uses wrong domain in SETATTR
References: <20130718174155.0f189280@csupomona.edu>
In-Reply-To: <20130718174155.0f189280@csupomona.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Brian,

I'm sorry it took so long to reply to you, but you haven't been forgotten!  I've set up kerberos using freeipa on my own test system but I haven't been able to reproduce the bug you're seeing.  I had it working by using my kerberos domain set in /etc/idmap.conf and I saw the new domain go over the wire when I changed it in idmap.conf.  Do I need to do anything more to mimic your setup?

- Bryan

On 07/18/2013 08:41 PM, Brian De Wolf wrote:
> Hello,
> 
> Found another problem related to idmapping, I think.  One of our users
> reported chgrp had stopped working (under 3.4.44, coming from 3.2.11).
> I reproduced it under krb5i (I can send the cap if necessary).  The
> SETATTR call is failing because it is not using the domain as set in
> idmapd.conf, but the domain of the host instead.
> 
> So, for example, our domain is csupomona.edu.  Trying to run "chgrp
> csupomona testfile" should set the group to csupomona@csupomona.edu,
> but the NFS layer is sending csupomona@unx.csupomona.edu (the subdomain
> of the host).
> 
> The idmapper seems to know what's going on, as the -vvv output produces:
> 
> nfsidmap[3598]: key: 0x3df841e type: group value: 17730 timeout 600
> nfsidmap[3598]: libnfsidmap: using domain: csupomona.edu
> nfsidmap[3598]: libnfsidmap: loaded plugin /usr/lib64/libnfsidmap/nsswitch.so for method nsswitch
> 
> Am I missing some simple host configuration or is this a deeper issue?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

