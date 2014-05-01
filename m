Return-Path: linux-nfs-owner@vger.kernel.org
Received: from st11p02mm-asmtpout002.mac.com ([17.172.220.237]:50169 "EHLO
	st11p02mm-asmtp002.mac.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750993AbaEAUDj convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2014 16:03:39 -0400
MIME-version: 1.0
Content-type: text/plain; charset=windows-1252
Received: from hobbes.nimgs.com ([184.188.181.148])
 by st11p02mm-asmtp002.mac.com
 (Oracle Communications Messaging Server 7u4-27.08(7.0.4.27.7) 64bit (built Aug
 22 2013)) with ESMTPSA id <0N4W00FIDVPZ15B0@st11p02mm-asmtp002.mac.com> for
 linux-nfs@vger.kernel.org; Thu, 01 May 2014 20:03:37 +0000 (GMT)
Subject: Re: idmap problems with chown as root
From: Craig Yoshioka <craigyk@me.com>
In-reply-to: <CAHQdGtTFtJYYkhnnxmpgtY7MapL49A1+2w6NBNy3o8NOKvbXWA@mail.gmail.com>
Date: Thu, 01 May 2014 13:03:30 -0700
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-id: <7EBFCEF4-8C76-4BF2-B04A-B70F811DCF0A@me.com>
References: <2541339C-AF61-4ED7-8F50-E4B3CA2C924F@me.com>
 <5362994C.8010900@RedHat.com>
 <CAHQdGtTFtJYYkhnnxmpgtY7MapL49A1+2w6NBNy3o8NOKvbXWA@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Does the following help on the client?
> 
> echo N >/sys/module/nfs/parameters/nfs4_disable_idmapping
> 

After restarting idmapd and remounting that did work.  Thanks.

It’s a good workaround until I can test the recent patch that stops mapping uid 0 to nobody.  


> -- 
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

