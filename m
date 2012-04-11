Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:50560 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760945Ab2DKTYy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2012 15:24:54 -0400
Message-ID: <4F85DA84.8010703@parallels.com>
Date: Wed, 11 Apr 2012 23:24:52 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
References: <20120410081612.65dd25fa@tlielax.poochiereds.net> <4F842BAE.2010804@parallels.com> <20120410093900.20209d00@tlielax.poochiereds.net> <4F84493C.1040303@parallels.com> <20120410144505.58bca0b9@corrin.poochiereds.net> <4F855864.8050509@parallels.com> <20120411074822.0054eb36@tlielax.poochiereds.net> <4F85825E.4060104@parallels.com> <20120411171919.GA29903@fieldses.org> <4F85C15D.5060408@parallels.com> <20120411182218.GB31025@fieldses.org>
In-Reply-To: <20120411182218.GB31025@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.04.2012 22:22, J. Bruce Fields написал:
>> >  What would happen, if we will have situation like below:
>> >  
>> >  	mountd A	mountd B
>> >  
>> >  	pid_ns		pid_ns
>> >  	|		  |
>> >  	mnt_ns		mnt_ns
>> >  	|		  |
>> >  	-----	net_ns ----
>> >  
>> >  Is it possible, BTW?
>> >  It yes, that is such construction valid?
> Looks like a mess, no.  I'd expect there to be only one rpc.mountd
> running per network namespace.

Then we have to prevent such situations somehow.
Or it is done already?
