Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51778 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031096Ab2COQCN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 12:02:13 -0400
Received: by eekc41 with SMTP id c41so1690812eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 15 Mar 2012 09:02:12 -0700 (PDT)
Subject: Re: NFS4 without id mapper
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <1331659764.3419.23.camel@lade.trondhjem.org>
Date: Thu, 15 Mar 2012 17:02:10 +0100
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <1B997EC7-7E1B-4508-9DFC-5AF491CF348E@gmail.com>
References: <66B6E4EA-A94C-4FD9-87C1-A110B0AB3D71@gmail.com> <1331659764.3419.23.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 13, 2012, at 6:29 PM, Myklebust, Trond wrote:

> On Tue, 2012-03-13 at 17:21 +0100, Anton Starikov wrote:
>> Hi,
>> 
>> I have probably stupid question, but is there a way to use NFS-4 in old-fashoned way without any idmapper involved? Assuming setup with auth=sys/none and no root squash.
> 
> The Linux client can do it, but not the Linux server. Sorry...


Hm, can you point me, where can I find information about disabling idmapper?

Thanks, 
Anton

> 
> Cheers
>  Trond
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

