Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:43220 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869AbaIZWfk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 18:35:40 -0400
Received: by mail-vc0-f175.google.com with SMTP id hy4so2473618vcb.6
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2014 15:35:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSdizkiykfThL2z4ozbFkaoFWGnS2_O9VLj749ZDUnxeQ@mail.gmail.com>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
	<20140926183949.GC27412@fieldses.org>
	<20140926145446.21a99698@tlielax.poochiereds.net>
	<20140926194616.GE27412@fieldses.org>
	<CAABAsM664Ce0JhBa=uK9+srsNB4_Ww4LLTymfOvcr1aM3g2X=g@mail.gmail.com>
	<20140926204549.GF27412@fieldses.org>
	<CAHQdGtR7uWW7s=ug=1_7n6uf_vU885d9Vc8W7kzaw4ncmdPi6w@mail.gmail.com>
	<20140926214743.GH27412@fieldses.org>
	<CAHQdGtSdizkiykfThL2z4ozbFkaoFWGnS2_O9VLj749ZDUnxeQ@mail.gmail.com>
Date: Fri, 26 Sep 2014 18:35:39 -0400
Message-ID: <CAHQdGtQ=TaBJ+NoVWctskZr3epBFkNBYdCHVhVRh6aos-GQiiA@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 6:17 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Fri, Sep 26, 2014 at 5:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Fri, Sep 26, 2014 at 04:58:47PM -0400, Trond Myklebust wrote:
>>> On Fri, Sep 26, 2014 at 4:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> > On Fri, Sep 26, 2014 at 04:37:23PM -0400, Trond Myklebust wrote:
>>> >> On Fri, Sep 26, 2014 at 3:46 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> >> >
>>> >> > As I understand it, the rule for the client is: you're allowed to
>>> >> > reclaim only the set locks that you held previously, where "the set of
>>> >> > locks you held previously" is "the set of locks held by the clientid
>>> >> > which last managed to send a reclaim OPEN or OPEN_CONFIRM".  So for
>>> >> > example once client1 sends that unrelated OPEN reclaim it's giving up on
>>> >> > anything else it doesn't manage to reclaim this time around.
>>> >>
>>> >> The rule for the client is very simple: "You may attempt to reclaim
>>> >> any locks that were held immediately prior to the reboot of the
>>> >> server."
>>> >> It doesn't matter how those locks were established (ordinary OPEN,
>>> >> delegated open, reclaim open, LOCK, reclaim lock...).
>>> >>
>>> >> However if the server reboots and the client did not manage to
>>> >> re-establish a lease (SETCLIENTID+SETCLIENTID_CONFIRM and/or
>>> >> EXCHANGE_ID+CREATE_SESSION) before the second reboot, then it is the
>>> >> server's responsibility to block that client from reclaiming any
>>> >> locks, since the client has no way to know how many times the server
>>> >> has rebooted.
>>> >> Ditto, of course, if the client tries to reclaim any locks outside the
>>> >> grace period and the server isn't tracking whether or not those locks
>>> >> have been handed out to another client.
>>> >
>>> > Agreed with everything except:
>>> >
>>> >         (SETCLIENTID+SETCLIENTID_CONFIRM and/or
>>> >         EXCHANGE_ID+CREATE_SESSION)
>>> >
>>> > If I remember correctly: RFC 5661 says the point where this happens is
>>> > actually RECLAIM_COMPLETE.  RFC 3530 was more vague but suggested first
>>> > OPEN reclaim or OPEN_CONFIRM, and 3530bis makes that explicit.
>>> >
>>> > But the client can choose an earlier point without violating the
>>> > protocol--it means it will decline reclaiming some things it could have,
>>> > but that's safer than the reverse mistake.
>>> >
>>>
>>> Where is this documented? I'm not seeing it.
>>
>> It's more vague than I remembered:
>>
>> http://tools.ietf.org/html/rfc5661#section-8.4.3
>>
>>         The server will set this for any client record in stable
>>         storage where the client has not done a suitable
>>         RECLAIM_COMPLETE (global or file system-specific depending on
>>         the target of the lock request) before it grants any new (i.e.,
>>         not reclaimed) lock to any client.
>
> Yes, I read that. Then I read this:
>
>    For the second edge condition, after the server restarts for a second
>    time, the indication that the client had not completed its reclaims
>    at the time at which the grace period ended means that the server
>    must reject a reclaim from client A with the error NFS4ERR_NO_GRACE.
>
> This text is just plain wrong, and we should fix it in an errata.
> There is absolutely NO edge case condition for those locks that were
> successfully reclaimed after the first reboot. There is absolutely no
> reason why the client shouldn't be able to reclaim those locks after
> reboot number 2.
>
> All the absence of the RECLAIM_COMPLETE tells the server is that the
> client MAY have held more locks; what is the server supposed to do
> with that information? It's not the server that is responsible for
> reclaiming locks.
>

Sigh, the information in RFC3530bis is still confused.

This makes sense:
   o  a timestamp that is updated the first time after a server boot or
      reboot the client acquires byte-range locking, share reservation,
      or delegation state on the server.  The timestamp need not be
      updated on subsequent lock requests until the server reboots.
....
This does not:
   For the second edge condition, after the server reboots for a second
   time, the record that the client had an unexpired record lock, share
   reservation, or delegation established before the server's previous
   incarnation means that the server must reject a reclaim from client A
   with the error NFS4ERR_NO_GRACE or NFS4ERR_RECLAIM_BAD.

Tom?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
