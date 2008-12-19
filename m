From: "Thomas Garner" <thomas536@gmail.com>
Subject: Re: more nfsv4 lockups w/ nexenta
Date: Fri, 19 Dec 2008 14:38:53 -0500
Message-ID: <9ef864c50812191138n5d6f42e2w5ef066f14e1c3620@mail.gmail.com>
References: <9ef864c50812110940o7ab17a2dvc83ac7653ad6dd21@mail.gmail.com>
	 <1229018528.6463.23.camel@heimdal.trondhjem.org>
	 <9ef864c50812111330v1c9dc200s49dacb5504bbfeca@mail.gmail.com>
	 <9ef864c50812190834p7a63d572s3bd99f964254cc@mail.gmail.com>
	 <1229710786.7789.138.camel@heimdal.trondhjem.org>
	 <9ef864c50812191036s35f30e5bia33b8024fec4d42e@mail.gmail.com>
	 <1229713906.7789.159.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:19448 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbYLSTiz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2008 14:38:55 -0500
Received: by nf-out-0910.google.com with SMTP id d3so162238nfc.21
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2008 11:38:54 -0800 (PST)
In-Reply-To: <1229713906.7789.159.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not super familiar with how to get dmesg to print out absolutely
everything if it's missing something. I tried `dmesg -s 900000 >
messages_dmesg.7` after running another sysrq, but this still looks to
me to still be cut off:

http://s120158928.onlinehome.us/messages_dmesg.7.gz

> The syslog trace seems incomplete, though. Can you see more information
> if you use
>
>        dmesg -s 90000
>
> Trond
