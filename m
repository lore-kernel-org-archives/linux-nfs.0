From: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Fri, 9 Oct 2009 10:05:25 -0700
Message-ID: <9fc711a4c6b4682ba847cd51ca62f86d.squirrel@webmail.rainiday.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	<20091009121602.5ec86dfb@tlielax.poochiereds.net>
	<f99e65f7b2fe66fc32dee931fd6bd525.squirrel@webmail.rainiday.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58316 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933451AbZJIRG6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 13:06:58 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MwIv5-0002ou-R6
	for linux-nfs@vger.kernel.org; Sat, 10 Oct 2009 04:06:19 +1100
In-Reply-To: <f99e65f7b2fe66fc32dee931fd6bd525.squirrel-2RFepEojUI30fF+2cCIZ11aTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> No, gssd (the client side daemon) will search /tmp for anything that
>> looks like a credcache for the right user, verify that it is a
>> credcache and then pick the one with the latest TGT expiration.
>
>> You're correct that NFS ignores $KRB5CCNAME. It uses the above (less
>> than optimal) heuristic instead.
>
> Thanks for explaining this Jeff - this does accord with what I see - which
> of course leaves my batch job system unpredictable.
>
>> Probably doable, but not trivial. IIRC, the kernel tracks credentials
>> by uid. You'd need to determine some way to split that up so that each
>> "session" has separate credentials. Once you do that, you'll have to
>> have the kernel pass enough info to the upcall for it to determine what
>> credcache it should use and modify gssd to use the new info accordingly.
>
> Just to be clear - you mean doable to a coder who might like to improve on
> gssd/kernel credential separation, rather than a non-coding sysadmin who
> needs with work within the current NFS/gssd framework?
>



------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

