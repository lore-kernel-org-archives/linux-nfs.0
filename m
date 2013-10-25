Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6625 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753478Ab3JYPRQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 11:17:16 -0400
Message-ID: <526A8BAB.8040704@RedHat.com>
Date: Fri, 25 Oct 2013 11:18:03 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] mountd: disabling turning off TCP listeners (v2)
References: <1382638633-6710-1-git-send-email-steved@redhat.com> <20131024144507.72aa34a8@tlielax.poochiereds.net> <526978BF.7020202@RedHat.com> <20131025074316.2affe9e9@tlielax.poochiereds.net> <526A62C1.6060803@RedHat.com> <20131025142012.GC20497@fieldses.org>
In-Reply-To: <20131025142012.GC20497@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25/10/13 10:20, J. Bruce Fields wrote:
>> I ideally it would be best not to have mountd at all on NFSv4-only server.
>> > Basically, have the kernel get its exports like it gets it ID mappings.
>> > Until that day comes, which I hope fill be soon, the TCP listener 
>> > only effects v3 mounts and we definitely want people to use TCP
>> > with v3. 
> I'm not sure if we want to do that, but note one thing we'll need to do
> before then is solve the namespace problems.  (We don't currently have a
> good way to run the usermode helper in the right container.)

Sorry for not keeping up on the container work and possibly asking
dumb question... but there can be different exports per container?
I thought it was just different IPs per container....

If so, how does that work today? 

steved.
 
