Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:36547 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753951Ab2CSSvF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:51:05 -0400
Message-ID: <4F678016.9050803@rath.org>
Date: Mon, 19 Mar 2012 14:51:02 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs@vger.kernel.org, nfsv4@ietf.org
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
References: <1085412836.1228438.1332175460830.JavaMail.root@erie.cs.uoguelph.ca> <1802632483.1230802.1332176807484.JavaMail.root@erie.cs.uoguelph.ca> <20120319173656.GA23670@fieldses.org> <126867CF-7CAA-4E3D-A9D6-2A5FE30A7DB4@oracle.com> <20120319182712.GB23670@fieldses.org> <A39DDC79-274A-427F-9887-28DD74BA56ED@oracle.com> <20120319183955.GC23670@fieldses.org>
In-Reply-To: <20120319183955.GC23670@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:
> > On Mon, Mar 19, 2012 at 01:06:47PM -0400, Rick Macklem wrote:
>> >> I wrote:
>>> >> > J. Bruce Fields wrote:
>>>> >> > > On Mon, Mar 12, 2012 at 05:27:08PM -0400, J. Bruce Fields wrote:
>>>>> >> > > > On Mon, Mar 12, 2012 at 05:14:16PM -0400, Chuck Lever wrote:
>>>>>> >> > > > > IMO, the server should do a comparison of the nfs_client_id4
>>>>>> >> > > > > strings, and nothing else.
>>>>> >> > > >
>>>>> >> > > > We're supposed to return CLID_INUSE when we see a setclientid
>>>>> >> > > > from a "different" client using the same string, to keep
>>>>> >> > > > clients from doing mischief with other clients' state (either
>>>>> >> > > > maliciously or, as in this case, accidentally).
>>>>> >> > > >
>>>>> >> > > > "Different" here is defined as "not having the same principal".
>>>>> >> > > > I know what that means in the krb5 case, but I'm less certain
>>>>> >> > > > in the auth_sys case.
>>>> >> > >
>>>> >> > > Cc'ing the ietf list. Is it reasonable for a server to expect
>>>> >> > > setclientid's to come from the same client IP address at least in
>>>> >> > > the auth_sys case, or could that break multi-homed clients?
>>>> >> > >
>>> >> > I think that even a dhcp lease renewal might result in a different
>>> >> > client IP, if the client has been partitioned from the dhcp server
>>> >> > for a while.
> >
> > Yeah, but by that point the client's v4 lease is probably expired
> > anyway so the client's not likely to be bothered by the NFS4ERR_INUSE.
> >
>>> >> > I'm not convinced that different client IP# implies different
>>> >> > client. (Even "same ip# implies same client" might not be true, if
>>> >> > the dhcp server assigned the IP# to another machine while the
>>> >> > client was partitioned from the dhcp server, I think? I haven't
>>> >> > looked at current dhcp implementations, but it seems conceivable to
>>> >> > me.)
>>> >> > 
>> >> Oh, and what about the case of 2 clients that are sitting behind the
>> >> same NAT gateway? (I think they'd both be seen as having the client
>> >> host ip# of the gateway, but with different TCP connections on
>> >> different client port#s.)
> >
> > Well, sure, but all I'm proposing here is returning NFS4ERR_INUSE in the
> > case where we get setclientid's with the same client-provided id.

At least in the case that sparked this discussion, it would already be
enough to return NFS4ERR_INUSE only if the client id is being reassigned
*and* has a 0.0.0.0 (aka autodetection failed) value.


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
