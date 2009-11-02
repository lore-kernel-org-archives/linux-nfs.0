From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] NLM server can not process retransmited request correctly
Date: Mon, 2 Nov 2009 15:09:56 -0500
Message-ID: <20091102200956.GC19271@fieldses.org>
References: <4AEEA622.6000705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>, mingo@elte.hu
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43067 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932368AbZKBUIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 15:08:25 -0500
In-Reply-To: <4AEEA622.6000705@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 02, 2009 at 05:28:02PM +0800, Mi Jinlong wrote:
> Hi Trond et al:
> 
> When i test the nfslock of NFSv3 at RHEL5.3GA (kernel: 2.6.18-128.el5),
> NLM server can not process client's retransmited request correctly.
> 
> Steps of my test likes followed:
>            client                          server
>              |                                |
>       step1  |           open file            |
>       open   |------------------------------->|
>              |              ok                |
>              |<-------------------------------|
>              |                                | step2
>              |                             -> | <-  service nfslock stop
>              |                                |
>       step3  | WL1: write lock request{0, 0}  |
>       fcntl  |------------------------------->|
>              |                                |
>              |    WL1_re: WL1 retransmit      |
>              |------------------------------->|
>              |                                |
>              |       WL1.reply   ENOLCK       |
>              |<-------------------------------|
>              |                                | step4
>              |                             -> | <- service nfslock start
>              |                                |
>       step5  | WL2: write lock request{0, 0}  |
>       fcntl  |------------------------------->|
>              |                                |
>              |        WL1_re.reply OK         |
>              |<-------------------------------|
>              |       WL2.reply EBLOCKD        |
>              |<-------------------------------|
>              V                                V
> 
>    Client can not acquire for write lock any more after step4.
> 
> Reason:
>    Server reply ENOLCK for WL1 to client because nfslock service stoped,

I don't completely understand that part: is it because the monitor call
to statd fails?

>    but it can not distinguish retransmited request with normal request, 
>    so it reply OK for WL1_re to client after nfslock service start. But 
>    fcntl client called will return when it receive WL1.reply, WL1_re.reply
>    will be droped at Client. So that, the lock between client and server
>    is different. When client send a some lock request to server again,
>    it will get a EBLOCKD error from Server.

But, OK, I get the idea, and generic DRC code shared by nfsd and nlm
makes sense to me; thanks for looking into this.

--b.
