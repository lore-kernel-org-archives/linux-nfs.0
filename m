Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blade3.isti.cnr.it ([194.119.192.19]:56772 "EHLO
	BLADE3.ISTI.CNR.IT" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706Ab0K2Wsh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 17:48:37 -0500
Received: from SCRIPT-SPFWL-DAEMON.mx.isti.cnr.it by mx.isti.cnr.it
 (PMDF V6.5 #31825) id <01NUUI24WZOWLKRHSU@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 23:47:27 +0100 (MET)
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it (PMDF V6.5 #31825)
 id <01NUUI23HPSGLS5SU7@mx.isti.cnr.it> for linux-nfs@vger.kernel.org; Mon,
 29 Nov 2010 23:47:25 +0100 (MET)
Received: from [151.82.44.231] by mx.isti.cnr.it (PMDF V6.5 #31826)
 with ESMTPSA id <01NUUI20AJA2LPPCPJ@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 23:47:22 +0100 (MET)
Date: Mon, 29 Nov 2010 23:47:20 +0100
From: Spelic <spelic@shiftmail.org>
Subject: Re: NFSv4 behaviour on unknown users
In-reply-to: <20101129195010.GA6423@hostway.ca>
To: linux-nfs@vger.kernel.org
Message-id: <4CF42D78.3010604@shiftmail.org>
Content-type: text/plain; format=flowed; charset=ISO-8859-1
References: <4CF3E3AD.2040502@shiftmail.org> <20101129195010.GA6423@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/29/2010 08:50 PM, Simon Kirby wrote:
> ...
> I tried to write the NFSv4 spec people, but didn't get any reply.  I can
> see maybe why they would want to do this by default, but it's not like
> people don't already have years of experience with how NFSv3 and earlier
> worked, and I still think should at least be a way to request that
> behaviour.
>    

Yeah!!!
currently it sucks... er...
I don't understand... never before I came across a "new version" of a 
software or a protocol which allows to do many fewer things than the 
older version. This sucks. Lots of use cases for NFS here are totally lost.

I'm thinking that even if I'd setup LDAP for everything here, things 
would not be easy, because we have server1 which has certain users and 
groups, server2+server3 which are for a different project and have 
different users and groups etc... and now we need to have the NFS server 
understand all those sets of users simultaneously, but the various 
servers only need to understand theirs and the other people should not 
be able to log in!
Maybe it's possible (I don't know how), but looks like a major headache. 
And now we probably cannot even have more than one LDAP server any 
longer: all LDAP probably needs to be centralized on a single machine 
which is where the NFS server(s) authenticate... it looks like a real 
problem for the independence of projects... and I really fear to think 
of what will happen if that machine fails!

I'd be glad to go back to NFS version 3 but we need nfs on infiniband 
rdma now, and afaik it's only available in version 4.

If it's still possible to change the specs or break them, well... you 
sure have my vote!

Thank you
S.
