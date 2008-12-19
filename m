From: "Thomas Garner" <thomas536@gmail.com>
Subject: Re: more nfsv4 lockups w/ nexenta
Date: Fri, 19 Dec 2008 13:36:57 -0500
Message-ID: <9ef864c50812191036s35f30e5bia33b8024fec4d42e@mail.gmail.com>
References: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21@mail.gmail.com>
	 <1229018528.6463.23.camel@heimdal.trondhjem.org>
	 <9ef864c50812111330v1c9dc200s49dacb5504bbfeca@mail.gmail.com>
	 <9ef864c50812190834p7a63d572s3bd99f964254cc@mail.gmail.com>
	 <1229710786.7789.138.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:5738 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbYLSSg7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2008 13:36:59 -0500
Received: by ik-out-1112.google.com with SMTP id c29so238760ika.5
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2008 10:36:57 -0800 (PST)
In-Reply-To: <1229710786.7789.138.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> As far as I can see from your tcpdump, there is no NFS network activity
> at all, so the recovery thread is obviously hung. What does
> 'echo t > /proc/sysrq-trigger' tell you that the thread is doing?

Here you go:

http://s120158928.onlinehome.us/messages_sysrq.7.gz
