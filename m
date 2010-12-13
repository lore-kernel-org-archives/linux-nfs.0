Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.cc.ic.ac.uk ([155.198.5.155]:48532 "EHLO
	smtp1.cc.ic.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666Ab0LMTP7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Dec 2010 14:15:59 -0500
Message-ID: <4D0670E7.9040008@imperial.ac.uk>
Date: Mon, 13 Dec 2010 19:15:51 +0000
From: Tim Watts <t.watts@imperial.ac.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NooB Assitance with debugging NFSv4 client requested
References: <4D024A8E.50407@imperial.ac.uk> <4D05F3E2.6090902@imperial.ac.uk> <4D0606D0.4010702@imperial.ac.uk> <20101213185514.GA2230@fieldses.org>
In-Reply-To: <20101213185514.GA2230@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce,

On 13/12/10 18:55, J. Bruce Fields wrote:
> On Mon, Dec 13, 2010 at 11:43:12AM +0000, Tim Watts wrote:
>> Hmm,
>>
>> Wonder if this is a clue (not noticed this before, but running
>> idmapd in the foreground, it just whined):
>>
>> rpc.idmapd: nfscb: read(/var/lib/nfs/rpc_pipefs/nfs/clnt0/idmap): No
>> such file or directory
>>
>> (Repeated several times).
>>
>> I'm veering towards this issue being an idmap problem.
>
> All permissions are enforced on the server side--the effect of an
> idmapper failure should just be that "ls -l" shows bad results (e.g.,
> "nobody" as the owner of every file) and that commands like "chown"
> fail.

Thanks very much for your reply.

Thanks for confirming the logic - I certainly now believe I have an 
issue with idmapd - sometimes the user will change to "nobody" and the 
group is good, and sometimes the reverse will happen.

We are using LDAP - with nscd - I might give myself a static /etc/passwd 
and /etc/groups entry to see if that makes the problem go away.

I'll run idmapd in debug plus under strace to see what's happening.


> If you're actually being prevented from performing normal filesystem
> operations, then the most likely culprit is with gssd and krb5.

I think I *may* have discovered the cause, eventually.

I have a couple of bash functions that maintain a user kerb principle 
and a root one - the root one being in /tmp/krb5cc_<uid>_root - and the 
bash function switches the env var to suit the mode I want to be in.

Seems that having two files of the form /tmp/krb5cc_<uid>* might be 
confusing something, so I have made the root one have a totally non 
conforming name to see if that was the cause.

> Might be worth filing a bug with ubuntu.

I did - it got classified under "nfs4_acl_tools"(!). I don't think 
Ubuntu are big on NFSv4 and I'm happy to try to get to the bottom of 
this, but it's pretty new to me (I've run a lot of NFSv3 before though).

> rpc.gssd debugging you've tried.  Sniffing client/server and client/kdc
> traffic with wireshark might also show some more information.

Yes - that would be worth doing.

> I dunno.  Maybe strace rpc.gssd during the failure?

Yes - might be worth doing that too.

Luckily during the failure conditions, the desktop is usable enough so I 
can at least get around and look at stuff.

Many thanks for the pointers :)

Cheers

Tim

-- 
Tim Watts
Linux Sysadmin, High Energy Physics, Imperial College London
Tel: 020 759 47809
