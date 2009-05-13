From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
	over NFS
Date: Wed, 13 May 2009 12:20:57 -0400
Message-ID: <b4ff356f0905130920v184ab529mb52a4346d4c77c14@mail.gmail.com>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:54863 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755415AbZEMQVJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 12:21:09 -0400
In-Reply-To: <x49y6t1rqw0.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I believe what you are seeing is how well TCP autotuning performs.
What old NFS code was doing is disabling autotuning and instead using
#nfsd thread to scale TCP recv window. You are providing an example of
where setting TCP buffer sizes outperforms TCP autotuning. While this
is a valid example, there is also an alternative example of where old
NFS design hurts performance.

On Wed, May 13, 2009 at 10:58 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
>
>> (obvious cc's added...)
>>
>> It's an iozone performance regression.
>>
>> On Tue, 12 May 2009 23:29:30 -0400 Jeff Moyer <jmoyer@redhat.com> wr=
ote:
>>
>>> Jens Axboe <jens.axboe@oracle.com> writes:
>>>
>>> > On Mon, May 11 2009, Jeff Moyer wrote:
>>> >> Jens Axboe <jens.axboe@oracle.com> writes:
>>> >>
>>> >> > On Fri, May 08 2009, Andrew Morton wrote:
>>> >> >> On Thu, 23 Apr 2009 10:01:58 -0400
>>> >> >> Jeff Moyer <jmoyer@redhat.com> wrote:
>>> >> >>
>>> >> >> > Hi,
>>> >> >> >
>>> >> >> > I've been working on CFQ improvements for interleaved I/Os =
between
>>> >> >> > processes, and noticed a regression in performance when usi=
ng the
>>> >> >> > deadline I/O scheduler. =A0The test uses a server configure=
d with a cciss
>>> >> >> > array and 1Gb/s ethernet.
>>> >> >> >
>>> >> >> > The iozone command line was:
>>> >> >> > =A0 iozone -s 2000000 -r 64 -f /mnt/test/testfile -i 1 -w
>>> >> >> >
>>> >> >> > The numbers in the nfsd's row represent the number of nfsd =
"threads".
>>> >> >> > These numbers (in MB/s) represent the average of 5 runs.
>>> >> >> >
>>> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0v2.6.29
>>> >> >> >
>>> >> >> > nfsd's =A0| =A0 1 =A0 =A0| =A02 =A0 | =A0 4 =A0 | =A0 8
>>> >> >> > --------+---------------+-------+------
>>> >> >> > deadline| 43207 | 67436 | 96289 | 107590
>>> >> >> >
>>> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 2.6.30-rc1
>>> >> >> >
>>> >> >> > nfsd's =A0| =A0 1 =A0 | =A0 2 =A0 | =A0 4 =A0 | =A0 8
>>> >> >> > --------+---------------+-------+------
>>> >> >> > deadline| 43732 | 68059 | 76659 | 83231
>>> >> >> >
>>> >> >> > =A0 =A0 2.6.30-rc3.block-for-linus
>>> >> >> >
>>> >> >> > nfsd's =A0| =A0 1 =A0 | =A0 2 =A0 | =A0 4 =A0 | =A0 8
>>> >> >> > --------+---------------+-------+------
>>> >> >> > deadline| 46102 | 71151 | 83120 | 82330
>>> >> >> >
>>> >> >> >
>>> >> >> > Notice the drop for 4 and 8 threads. =A0It may be worth not=
ing that the
>>> >> >> > default number of NFSD threads is 8.
>
> Just following up with numbers:
>
> =A02.6.30-rc4
>
> nfsd's =A0| =A0 8
> --------+------
> cfq =A0 =A0 | 51632 =A0 (49791 52436 52308 51488 52141)
> deadline| 65558 =A0 (41675 42559 74820 87518 81221)
>
> =A0 2.6.30-rc4 reverting the sunrpc "fix"
>
> nfsd's =A0| =A0 8
> --------+------
> cfq =A0 =A0 | =A082513 =A0(81650 82762 83147 82935 82073)
> deadline| 107827 =A0(109730 106077 107175 108524 107632)
>
> The numbers in parenthesis are the individual runs. =A0Notice how
> 2.6.30-rc4 has some pretty wide variations for deadline.
>
> Cheers,
> Jeff
>
>>> >> >> I guess we should ask Rafael to add this to the post-2.6.29 r=
egression
>>> >> >> list.
>>> >> >
>>> >> > I agree. It'd be nice to bisect this one down, I'm guessing so=
me mm
>>> >> > change has caused this writeout regression.
>>> >>
>>> >> It's not writeout, it's a read test.
>>> >
>>> > Doh sorry, I even ran these tests as well a few weeks back. So pe=
rhaps
>>> > some read-ahead change, I didn't look into it. FWIW, on a single =
SATA
>>> > drive here, it didn't show any difference.
>>>
>>> OK, I bisected this to the following commit. =A0The mount is done u=
sing
>>> NFSv3, by the way.
>>>
>>> commit 47a14ef1af48c696b214ac168f056ddc79793d0e
>>> Author: Olga Kornievskaia <aglo@citi.umich.edu>
>>> Date: =A0 Tue Oct 21 14:13:47 2008 -0400
>>>
>>> =A0 =A0 svcrpc: take advantage of tcp autotuning
>>>
>>> =A0 =A0 Allow the NFSv4 server to make use of TCP autotuning behavi=
our, which
>>> =A0 =A0 was previously disabled by setting the sk_userlocks variabl=
e.
>>>
>>> =A0 =A0 Set the receive buffers to be big enough to receive the who=
le RPC
>>> =A0 =A0 request, and set this for the listening socket, not the acc=
ept socket.
>>>
>>> =A0 =A0 Remove the code that readjusts the receive/send buffer size=
s for the
>>> =A0 =A0 accepted socket. Previously this code was used to influence=
 the TCP
>>> =A0 =A0 window management behaviour, which is no longer needed when=
 autotuning
>>> =A0 =A0 is enabled.
>>>
>>> =A0 =A0 This can improve IO bandwidth on networks with high bandwid=
th-delay
>>> =A0 =A0 products, where a large tcp window is required. =A0It also =
simplifies
>>> =A0 =A0 performance tuning, since getting adequate tcp buffers prev=
iously
>>> =A0 =A0 required increasing the number of nfsd threads.
>>>
>>> =A0 =A0 Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
>>> =A0 =A0 Cc: Jim Rees <rees@umich.edu>
>>> =A0 =A0 Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>>
>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>> index 5763e64..7a2a90f 100644
>>> --- a/net/sunrpc/svcsock.c
>>> +++ b/net/sunrpc/svcsock.c
>>> @@ -345,7 +345,6 @@ static void svc_sock_setbufsize(struct socket *=
sock, unsigned int snd,
>>> =A0 =A0 =A0lock_sock(sock->sk);
>>> =A0 =A0 =A0sock->sk->sk_sndbuf =3D snd * 2;
>>> =A0 =A0 =A0sock->sk->sk_rcvbuf =3D rcv * 2;
>>> - =A0 =A0sock->sk->sk_userlocks |=3D SOCK_SNDBUF_LOCK|SOCK_RCVBUF_L=
OCK;
>>> =A0 =A0 =A0release_sock(sock->sk);
>>> =A0#endif
>>> =A0}
>>> @@ -797,23 +796,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *r=
qstp)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0test_bit(XPT_CONN, &svsk->sk_xprt.xpt_fl=
ags),
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0test_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_f=
lags));
>>>
>>> - =A0 =A0if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_fla=
gs))
>>> - =A0 =A0 =A0 =A0 =A0 =A0/* sndbuf needs to have room for one reque=
st
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * per thread, otherwise we can stall even=
 when the
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * network isn't a bottleneck.
>>> - =A0 =A0 =A0 =A0 =A0 =A0 *
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * We count all threads rather than thread=
s in a
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * particular pool, which provides an uppe=
r bound
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * on the number of threads which will acc=
ess the socket.
>>> - =A0 =A0 =A0 =A0 =A0 =A0 *
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * rcvbuf just needs to be able to hold a =
few requests.
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * Normally they will be removed from the =
queue
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * as soon a a complete request arrives.
>>> - =A0 =A0 =A0 =A0 =A0 =A0 */
>>> - =A0 =A0 =A0 =A0 =A0 =A0svc_sock_setbufsize(svsk->sk_sock,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(s=
erv->sv_nrthreads+3) * serv->sv_max_mesg,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03 =
* serv->sv_max_mesg);
>>> -
>>> =A0 =A0 =A0clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>>>
>>> =A0 =A0 =A0/* Receive data. If we haven't got the record length yet=
, get
>>> @@ -1061,15 +1043,6 @@ static void svc_tcp_init(struct svc_sock *sv=
sk, struct svc_serv *serv)
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_sk(sk)->nonagle |=3D TCP_NAGLE_OFF;
>>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0/* initialise setting must have enough spa=
ce to
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * receive and respond to one request.
>>> - =A0 =A0 =A0 =A0 =A0 =A0 * svc_tcp_recvfrom will re-adjust if nece=
ssary
>>> - =A0 =A0 =A0 =A0 =A0 =A0 */
>>> - =A0 =A0 =A0 =A0 =A0 =A0svc_sock_setbufsize(svsk->sk_sock,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03 =
* svsk->sk_xprt.xpt_server->sv_max_mesg,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03 =
* svsk->sk_xprt.xpt_server->sv_max_mesg);
>>> -
>>> - =A0 =A0 =A0 =A0 =A0 =A0set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_fl=
ags);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(XPT_DATA, &svsk->sk_xprt.xpt_fla=
gs);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk->sk_state !=3D TCP_ESTABLISHED)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(XPT_CLOSE, &svsk=
->sk_xprt.xpt_flags);
>>> @@ -1140,8 +1113,14 @@ static struct svc_sock *svc_setup_socket(str=
uct svc_serv *serv,
>>> =A0 =A0 =A0/* Initialize the socket */
>>> =A0 =A0 =A0if (sock->type =3D=3D SOCK_DGRAM)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0svc_udp_init(svsk, serv);
>>> - =A0 =A0else
>>> + =A0 =A0else {
>>> + =A0 =A0 =A0 =A0 =A0 =A0/* initialise setting must have enough spa=
ce to
>>> + =A0 =A0 =A0 =A0 =A0 =A0 * receive and respond to one request.
>>> + =A0 =A0 =A0 =A0 =A0 =A0 */
>>> + =A0 =A0 =A0 =A0 =A0 =A0svc_sock_setbufsize(svsk->sk_sock, 4 * ser=
v->sv_max_mesg,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A04 * serv->sv_max_mesg);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0svc_tcp_init(svsk, serv);
>>> + =A0 =A0}
>>>
>>> =A0 =A0 =A0/*
>>> =A0 =A0 =A0 * We start one listener per sv_serv. =A0We want AF_INET
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
>
