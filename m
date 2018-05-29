Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:48658 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966362AbeE2UD5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 16:03:57 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180529195628.GB16759@fieldses.org>
Date: Tue, 29 May 2018 16:03:46 -0400
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1768D584-0BF8-4155-92A7-52F9CC44544C@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
 <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com>
 <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
 <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com>
 <CAN-5tyHLEm3SQ5_ayDr6_TECpQndN_haKSyodf7Ls61RbLR2_g@mail.gmail.com>
 <E54CA1D0-00E7-4EEF-B77F-78B65AF2FC08@oracle.com>
 <CAN-5tyH7gCyZ=-11TaYC3-WhYcB5n+W3Ua=TdDq=PZk24n+DbQ@mail.gmail.com>
 <EFDDE2C2-8E09-4F7A-B95A-785EA48E4804@oracle.com>
 <CAN-5tyGu++ULeUZKtZH=ZjUwqLNrcaZ4dSjH=iHXe0fCeudajA@mail.gmail.com>
 <58E2765B-6238-479D-968A-0FE2F5F01928@oracle.com>
 <20180529195628.GB16759@fieldses.org>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 29, 2018, at 3:56 PM, bfields@fieldses.org wrote:
> 
> On Tue, May 22, 2018 at 03:36:12PM -0700, Chuck Lever wrote:
>>> On May 22, 2018, at 3:11 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>> If an AUTH_UNIX client can tamper with a lease established
>>>> by an AUTH_GSS client, that's a pretty serious server bug.
>>>> 
>>>> Which server implementation is this?
>>> 
>>> This is linux 4.16-rc1.
>> 
>> Would it be easy for you confirm if two AUTH_GSS clients are
>> appropriately protected from each other? It would be good to
>> file a bug on bugzilla.linux-nfs.org to document the full
>> extent of the badness.
> 
> If you try a setclientid with a client name matching an
> already-established client with state, then nfsd4_setclientid() should
> be returning CLID_INUSE:
> 
> 	if (conf && client_has_state(conf)) {
> 		...
> 		status = nfserr_clid_inuse;
> 		...
> 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
> 			...
> 			goto out;
> 		}
> 	}
> 
> So if you're seeing SETCLIENTID succeed then maybe same_creds() or
> client_has_state() is failing.
> 
> Maybe client_has_state()?--that will fail (and allow the setclientid) if
> the v4.0 client doesn't currently have any opens or delegations.
> 
> I think that's correct: 
> 
> 	https://tools.ietf.org/html/rfc7530#section-9.1.2
> 
> 	when the server gets a SETCLIENTID for a client ID that
> 	currently has no state, or it has state but the lease has
> 	expired, rather than returning NFS4ERR_CLID_INUSE, the server
> 	MUST allow the SETCLIENTID and confirm the new client ID if
> 	followed by the appropriate SETCLIENTID_CONFIRM.
> 
> That's left out of the later breakdown of cases in 16.33.5,
> unfortunately.

That prevents certain denial of service attacks. A client can't
lose state because of this. However, it can do a SETCLIENTID
then later be prevented from doing its first OPEN?


--
Chuck Lever



