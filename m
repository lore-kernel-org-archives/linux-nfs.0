From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: possible module refcount leak with auth_gss
Date: Tue, 9 Dec 2008 18:21:08 -0500
Message-ID: <4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
References: <20081208102855.30081708@tleilax.poochiereds.net>
	 <20081208173706.GE16628@fieldses.org>
	 <20081209153849.6605559a@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f13.google.com ([209.85.218.13]:33240 "EHLO
	mail-bw0-f13.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbYLIX1n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2008 18:27:43 -0500
Received: by bwz6 with SMTP id 6so534052bwz.13
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2008 15:27:41 -0800 (PST)
In-Reply-To: <20081209153849.6605559a-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 9, 2008 at 3:38 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Mon, 8 Dec 2008 12:37:06 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
>> On Mon, Dec 08, 2008 at 10:28:55AM -0500, Jeff Layton wrote:
>> > We had someone report a bug against Fedora that they were seeing very
>> > high module reference counts for some krb5 related modules on his nfs
>> > server. For instance:
>> >
>> > # lsmod
>> > Module                  Size  Used by
>> > des_generic            25216  52736
>> > cbc                    12160  52736
>> > rpcsec_gss_krb5        15632  26370
>> >
>> > ...the cbc and des_generic each have roughly 2 module references per
>> > rpcsec_gss_krb5 refcount so I'm assuming that the "lynchpin" here is
>> > the rpcsec_gss_krb5 refcount which seems to be increasing w/o bound.
>>
>> You may want to see this discussion:
>>
>>       http://marc.info/?t=122819524700001&r=1&w=2
>>
>> And these patches:
>>
>>       http://marc.info/?l=linux-nfs&m=122843371318602&w=2
>>
>
> Doh! I saw that discussion and didn't make the connection. Thanks for
> pointing that out.
>
>> In addition to increasing the timeouts on those cache entries, perhaps
>> we could flush the contexts on rmmod?  Or change the reference counting
>> somehow--e.g., take a reference only in the presence of export cache
>> entries that mention krb5, and destroy contexts when the last such goes
>> away?
>>
>
> That sounds like a better scheme than what we have currently. As it stands
> now, you can't just unplug the module -- you have to wait for the entries
> in the cache to time out.
>
> FWIW, I tested out Kevin's patches and it still didn't seem to help. The
> refcounts never seemed to go down (even after several hours). How long
> should the context live in the cache with those patches? Until the krb5
> ticket expires? I'll leave the box in this state until around this time
> tomorrow to be sure (that's when the ticket expires).

Yes, that should be the normal expiration with my patches.  The
default ticket lifetime is 10 hours I believe, but that is
configurable by realm (and service).  You can shorten the lifetime for
testing by setting an /etc/krb5.conf option.  This example should
limit lifetimes to 5 minutes (300 seconds) for testing purposes.

[libdefaults]
ticket_lifetime = 300s

K.C.
