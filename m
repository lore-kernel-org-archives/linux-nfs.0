Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp3.ugent.be ([157.193.49.127]:44605 "EHLO smtp3.UGent.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451Ab1FGRM6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 13:12:58 -0400
Received: from localhost (mcheck3.ugent.be [157.193.71.89])
	by smtp3.UGent.be (Postfix) with ESMTP id 2194E148327
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2011 19:04:59 +0200 (CEST)
Received: from smtp3.UGent.be ([157.193.49.127])
	by localhost (mcheck3.ugent.be [157.193.43.11]) (amavisd-new, port 10024)
	with ESMTP id 3URvSzs-+aCc for <linux-nfs@vger.kernel.org>;
	Tue,  7 Jun 2011 19:04:58 +0200 (CEST)
Received: from [172.16.0.2] (78-20-75-230.access.telenet.be [78.20.75.230])
	(Authenticated sender: lukclaes)
	by smtp3.UGent.be (Postfix) with ESMTPSA id B5DD11482F9
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2011 19:04:58 +0200 (CEST)
Message-ID: <4DEE5A60.8000402@debian.org>
Date: Tue, 07 Jun 2011 19:05:36 +0200
From: Luk Claes <luk@debian.org>
To: linux-nfs@vger.kernel.org
Subject: Re: What RPM meets the libgssapi requirement on Fedora?
References: <4DEE57AD.8050408@candelatech.com>
In-Reply-To: <4DEE57AD.8050408@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

In Debian it's called libgssglue as it was also renamed upstream quite a
while ago.

Cheers

Luk

On 06/07/2011 06:54 PM, Ben Greear wrote:
> ./configure
> ....
> checking pkg-config is at least version 0.9.0... yes
> checking for RPCSECGSS... yes
> checking for GSSAPI... configure: error: Package requirements (libgssapi
>>= 0.11) were not met:
> 
> No package 'libgssapi' found
> 
> I tried:
> 
> [root@fs3 linux-2.6.38.x64-dbg]# yum install libgssapi-devel
> Loaded plugins: presto, refresh-packagekit
> Setting up Install Process
> Nothing to do
> 
> This is on Fedora 13...
> 
> Thanks,
> Ben
> 

