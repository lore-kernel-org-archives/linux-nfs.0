From: Anton Starikov <ant.starikov@gmail.com>
Subject: Re: NFS silent death
Date: Sat, 19 Dec 2009 22:18:11 +0100
Message-ID: <60E7C084-8B89-4F6E-88D8-C3C41B1AC416@gmail.com>
References: <143DD9C8-CD7D-4D18-8295-D9ADBD8A0972@gmail.com> <1240866287.8818.89.camel@heimdal.trondhjem.org> <38C9A462-2199-4CA7-9EEC-050400D71C56@gmail.com> <E15883FF-13BE-4444-A14A-01F85ACEDA00@fys.uio.no> <E196D821-13E7-4CF6-8D8C-92B7CC432801@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Anton Starikov <ant.starikov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:59174 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbZLSVSP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Dec 2009 16:18:15 -0500
Received: by ey-out-2122.google.com with SMTP id d26so1053020eyd.19
        for <linux-nfs@vger.kernel.org>; Sat, 19 Dec 2009 13:18:14 -0800 (PST)
In-Reply-To: <E196D821-13E7-4CF6-8D8C-92B7CC432801@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

Quick question.

Is this issue fixed by now

On Apr 28, 2009, at 12:25 AM, Anton Starikov wrote:
>>>> 
>>>> Hmm... My guess is that you are deadlocked because rpciod appears to be
>>>> hanging on an idmapper upcall due to an NFSv4 open() call. At the same
>>>> time, since /etc/passwd and /etc/group are on an NFSv3 partition, the
>>>> idmapper will need to use rpciod in order to read them.
>>>> 
>>>> We therefore apparently need to move the idmapper upcall out of the
>>>> rpciod part of the open() call. I'll look into that...

Thanks,

Anton.
