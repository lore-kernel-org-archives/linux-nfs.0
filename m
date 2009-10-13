From: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Tue, 13 Oct 2009 08:28:52 -0700
Message-ID: <ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
    <20091009121602.5ec86dfb@tlielax.poochiereds.net>
    <1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
    <20091010090039.4dfd1dfb@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from caiajhbihbdd.dreamhost.com ([208.97.187.133]:42976 "EHLO
	webmail2.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753294AbZJMP3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 11:29:30 -0400
In-Reply-To: <20091010090039.4dfd1dfb-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> said:
>> Just to be clear - you mean doable to a coder who might like to improve
>> on
>> gssd/kernel credential separation, rather than a non-coding sysadmin who
>> needs with work within the current NFS/gssd framework?
>>
>
> Correct, that's what I mean. It'll mean modifying kernel and rpc.gssd
> code.

Thanks for confirming.  Skipping back a little:

>> > No, gssd (the client side daemon) will search /tmp for anything that
>> > looks like a credcache for the right user, verify that it is a
>> > credcache and then pick the one with the latest TGT expiration.

Kevin Coffman on the NFS4 list actually implied this used simple mtime
rather than actually scanning /tmp/krb5cc_uid* for ccache files with the
latest TGT expiration, which is how I originally read your statement. 
This seemingly would make a difference in an environment with a batch job
with a long lifetime ticket and subsequent interactive login generating a
separate ccache file with a shorter lifetime but newer mtime.

I'm not a coder but I scanned krb5_util.c in the gssd code, and it *seems*
to me it only looks at mtime, although what you suggest would be more
optimal.  Could you confirm whether it's scanning ccache files for longest
TGT, or just using mtime?



