Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54003 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752602AbcLEWEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Dec 2016 17:04:25 -0500
From: NeilBrown <neilb@suse.com>
To: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 06 Dec 2016 09:04:15 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Subject: Re: [PATCH] SUNRPC: fix refcounting problems with auth_gss messages.
In-Reply-To: <CAN-5tyHrWMj54cvj3PVO+8Yxk+0NK9ey=X7VU6WXKv-mswh-xw@mail.gmail.com>
References: <87oa0r584c.fsf@notabene.neil.brown.name> <CAN-5tyHrWMj54cvj3PVO+8Yxk+0NK9ey=X7VU6WXKv-mswh-xw@mail.gmail.com>
Message-ID: <877f7e58yo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Dec 06 2016, Olga Kornievskaia wrote:

> On Sun, Dec 4, 2016 at 11:10 PM, NeilBrown <neilb@suse.com> wrote:
>>
>> There are two problems with refcounting of auth_gss messages.
>>
>> First, the reference on the pipe->pipe list (taken by a call
>> to rpc_queue_upcall()) is not counted.  It seems to be
>> assumed that a message in pipe->pipe will always also be in
>> pipe->in_downcall, where it is correctly reference counted.
>>
>> However there is no guaranty of this.  I have a report of a
>> NULL dereferences in rpc_pipe_read() which suggests a msg
>> that has been freed is still on the pipe->pipe list.
>>
>> One way I imagine this might happen is:
>> - message is queued for uid=U and auth->service=S1
>> - rpc.gssd reads this message and starts processing.
>>   This removes the message from pipe->pipe
>> - message is queued for uid=U and auth->service=S2
>> - rpc.gssd replies to the first message. gss_pipe_downcall()
>>   calls __gss_find_upcall(pipe, U, NULL) and it finds the
>>   *second* message, as new messages are placed at the head
>>   of ->in_downcall, and the service type is not checked.
>
> Correct "service" was/is not a part of the protocol between the kernel
> and gssd. So that's why the kernel can't match what's coming from gssd
> to a particular waiting upcall.
>
>> - This second message is removed from ->in_downcall and freed
>>   by gss_release_msg() (even though it is still on pipe->pipe)
>> - rpc.gssd tries to read another message, and dereferences a pointer
>>   to this message that has just been freed.
>
> Agreed. This is a problem.
>
> Doesn't the problem still exist even with this patch because
> gss_add_msg() adds the msg onto the in_downcall() list? So gssd in
> __gss_fin_upcall() can find the 2nd upcall even before the 2nd msg is
> added to the pipe->pipe()?

The use-after-free problem is solved I think.  It doesn't really make
any difference if the down-call arrives before or after
rpc_queue_upcall() is called.  The msg will still not be freed before it
is removed from both lists.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhF5F8ACgkQOeye3VZi
gbkJQxAAusJDhDmymvgqBAnRdz3tONKws3KwEj64PRL0KiBfWcO7qlr5vI4tfSbh
UZe0F2jsyWqL3iZ4hs9j6FEohZSvfPPItczD1Fz+NXfoNzmFoDNGkOST8kKnclWJ
G57COilQckeonx/pqWscDjtq66V/zoywSxzMEENaHPcRDFVApyHIG3OqYudP+Gt0
5hdKI+OW/BzlqffoN2CIQBqIYAeoDG3rgyeiZkAx5i9YDmI5kGkhV1DtQSGynWWj
iA2U/Q8pcD/RDl7Oj1fCcb/lPbFofjaXQ0lJ/QdRf9CVCntRi42cz+o45urK/PBS
O1/+DH0jEUKX1EYY8acONuyWWcOT6hAWTZszod3oa0ZP0iFFDC11y/2r+zInijIR
ymmfC86eEZpFUl+UzJgax26dR1wogpTVWIXnDg5Z7TdHlQJrPIILrsvRb+iodb2V
XJ5Os8XJ1bb7p8SvFlJsBfwaD0KxtraKLhOMCYe+p0ocCzXWBy25nBvm772R4OfK
FgTcUXe+PGhnWYl1kLguaN0vqj5Fcyg8nee8AA5HtcKNe+AOcsbfThl++hW54RIU
ZTC6x81jcRnMPHoHs9QNN58l/YNuYehuUds5B6vZS7csEG34GgYNf2L9/ZICabw3
R7L1sa80huW80TIWVQypWXWkdWK0NPsTjLA/0KLFz7atrPT0W1I=
=nuxW
-----END PGP SIGNATURE-----
--=-=-=--
