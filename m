Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out01.mta.xmission.com ([166.70.13.231]:51994 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345Ab2KOGPK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Nov 2012 01:15:10 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel\@openvz.org" <devel@openvz.org>
References: <20121106124035.GA20522@infradead.org>
	<20121106130705.GC6718@fieldses.org>
	<20121106131018.GA12211@infradead.org>
	<20121106133605.GD6718@fieldses.org>
	<20121107183355.GA7421@fieldses.org> <50A0B562.2090807@parallels.com>
	<20121114210112.GA539@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9092E0A40@SACEXCMBX04-PRD.hq.netapp.com>
	<20121114214236.GB539@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9092E0AE9@SACEXCMBX04-PRD.hq.netapp.com>
	<20121114215426.GC539@fieldses.org>
Date: Wed, 14 Nov 2012 22:14:50 -0800
In-Reply-To: <20121114215426.GC539@fieldses.org> (J. Bruce Fields's message of
	"Wed, 14 Nov 2012 16:54:26 -0500")
Message-ID: <87obize6jp.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before connecting local transports
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Wed, Nov 14, 2012 at 09:51:33PM +0000, Myklebust, Trond wrote:
>> On Wed, 2012-11-14 at 16:42 -0500, J. Bruce Fields wrote:
>> > Simo's patches use them for upcalls to svcgssd.  Those will always be
>> > done from server threads.
>> 
>> Any reason why you can't set that up when you start nfsd?
>
> Oh, right, I was thinking of the upcalls themselves--right, the connect
> we should be able to do on server start, I agree.
>
>> 
>> > > If not, then let's just move
>> > > the AF_LOCAL connection back into the process context and out of rpciod.
>> > 
>> > Remind me how this helps?
>> 
>> rpciod shares the 'init' process net namespace and chroot properties.
>> If, however you call bind() from the (containerised) process that was
>> used to start nfsd, then you will be using filesystem root (and net
>> namespace) of that container.
>
> Got it.

If you can move the connect and bind into the server start that does
sound like a very good and maintainable solution.  I suspect it might
even be a smidge better for error handling.

Is there ever a reason to reconnect one of these sockets?

Eric
