Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36968 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865Ab1KNQaF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 11:30:05 -0500
Message-ID: <1321288188.2632.12.camel@lade.trondhjem.org>
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: tigran.mkrtchyan@desy.de
Cc: NeilBrown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Date: Mon, 14 Nov 2011 18:29:48 +0200
In-Reply-To: <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	 <1321056809.8733.2.camel@lade.trondhjem.org>
	 <20111112144953.GA3740@infradead.org>
	 <20111113145400.6c7a9be3@notabene.brown>
	 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2011-11-13 at 14:45 +0100, Tigran Mkrtchyan wrote: 
> I have a server which runs on top of hadoop. The problem with hadoop
> is that there is no way to have persistent file handles. I am
> currently working on a way to do that - either simulate them or add a
> support for unique file id to hadoop. If linux client will support
> volatile file handles then I can stop inventing some workarounds.

So if we add a broken hack to the client then you can stop adding broken
hacks to the server? Sounds like you will still have a broken hacky
setup to me.

The idea of adding file ids to hadoop sounds like a better solution.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

